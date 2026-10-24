import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../config/game_config.dart';
import '../../core/clock.dart';
import '../../domain/logic/growth.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/seed.dart';
import '../db/app_database.dart';
import '../repositories/counters_repository.dart';
import '../repositories/mappers.dart';
import '../repositories/seed_repository.dart';

class GardenException implements Exception {
  const GardenException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HarvestResult {
  const HarvestResult({required this.speciesId, required this.fruit});

  final String speciesId;
  final int fruit;
}

/// Planting, harvesting and moving on plants.
class GardenService {
  GardenService(this._db, this._config, this._clock, this._seeds, this._counters);

  final AppDatabase _db;
  final GameConfig _config;
  final Clock _clock;
  final SeedRepository _seeds;
  final CountersRepository _counters;
  static const _uuid = Uuid();

  /// Makes sure the free starting plot exists.
  Future<void> ensureStartingPlot() => _seeds.ensurePlot(_config.startingEnvironment.id);

  /// The free seed from onboarding. Planted straight away, or left in the bag.
  Future<void> grantStarterSeed({required bool plant}) async {
    await ensureStartingPlot();
    final species = _config.speciesById(_config.starterSeed);
    final seed = await _seeds.add(species.id, species.rarity, SeedSource.starter);
    await _counters.add(CounterKeys.seedsEarned, 1);
    if (plant) {
      final slot = await firstFreeSlot(_config.startingEnvironment.id);
      if (slot != null) await plantSeed(seed.id, _config.startingEnvironment.id, slot);
    }
  }

  Stream<List<Plant>> watchPlants(String envId) =>
      (_db.select(_db.plants)
            ..where((t) => t.envId.equals(envId) & t.uprootedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.slot)]))
          .watch()
          .map((rows) => rows.map(plantFromRow).toList());

  Stream<List<Plant>> watchAllPlants() =>
      (_db.select(_db.plants)..orderBy([(t) => OrderingTerm(expression: t.plantedAt, mode: OrderingMode.desc)]))
          .watch()
          .map((rows) => rows.map(plantFromRow).toList());

  Future<List<Plant>> activePlants() async =>
      (await (_db.select(_db.plants)..where((t) => t.uprootedAt.isNull())).get()).map(plantFromRow).toList();

  Future<int?> firstFreeSlot(String envId) async {
    final used = {
      for (final r in await (_db.select(_db.plants)..where((t) => t.envId.equals(envId) & t.uprootedAt.isNull())).get())
        r.slot,
    };
    for (var i = 0; i < _config.environment(envId).slots; i++) {
      if (!used.contains(i)) return i;
    }
    return null;
  }

  Future<Plant> plantSeed(String seedId, String envId, int slot) => _db.transaction(() async {
    final seed = await _seeds.get(seedId);
    if (seed == null || seed.state != SeedState.bag) throw const GardenException('That seed is no longer in your bag.');
    final species = _config.speciesById(seed.speciesId);
    if (!species.environments.contains(envId)) {
      throw GardenException('${species.name} would rather grow somewhere else.');
    }
    if (!(await _seeds.unlockedEnvironments()).contains(envId)) {
      throw const GardenException('That plot is still locked.');
    }
    if (slot < 0 || slot >= _config.environment(envId).slots) throw const GardenException('No such spot.');
    final taken = await (_db.select(
      _db.plants,
    )..where((t) => t.envId.equals(envId) & t.slot.equals(slot) & t.uprootedAt.isNull())).getSingleOrNull();
    if (taken != null) throw const GardenException('Something is already growing there.');

    final plant = Plant(
      id: _uuid.v4(),
      envId: envId,
      slot: slot,
      speciesId: species.id,
      rarity: seed.rarity,
      plantedAt: _clock.now(),
    );
    await _db
        .into(_db.plants)
        .insert(
          PlantsCompanion.insert(
            id: plant.id,
            envId: envId,
            slot: slot,
            speciesId: plant.speciesId,
            rarity: plant.rarity.id,
            plantedAt: plant.plantedAt,
          ),
        );
    await _seeds.setState(seedId, SeedState.planted);
    await _counters.add(CounterKeys.plantsGrown, 1);
    return plant;
  });

  Future<HarvestResult> harvest(String plantId) => _db.transaction(() async {
    final row = await (_db.select(_db.plants)..where((t) => t.id.equals(plantId))).getSingle();
    final species = _config.speciesById(row.speciesId);
    final outcome = Growth.harvest(
      species,
      plantedAt: row.plantedAt,
      fruitAnchor: row.fruitAnchorAt,
      now: _clock.now(),
    );
    if (outcome.fruit == 0) return HarvestResult(speciesId: species.id, fruit: 0);
    await (_db.update(_db.plants)..where((t) => t.id.equals(plantId))).write(
      PlantsCompanion(fruitAnchorAt: Value(outcome.newAnchor), harvests: Value(row.harvests + outcome.harvests)),
    );
    await addToInventory(species.id, outcome.fruit);
    await _counters.add(CounterKeys.fruitHarvested, outcome.fruit);
    return HarvestResult(speciesId: species.id, fruit: outcome.fruit);
  });

  /// Moves a plant on: it becomes a keepsake in the Journal and frees its slot.
  Future<void> moveOn(String plantId) => (_db.update(
    _db.plants,
  )..where((t) => t.id.equals(plantId))).write(PlantsCompanion(uprootedAt: Value(_clock.now())));

  /// Every plant jumps [by] ahead in growth and fruiting.
  Future<void> boostGrowth(Duration by) => _db.transaction(() async {
    for (final p in await activePlants()) {
      final species = _config.speciesById(p.speciesId);
      final now = _clock.now();
      final status = Growth.status(species, plantedAt: p.plantedAt, fruitAnchor: p.fruitAnchorAt, now: now);
      await (_db.update(_db.plants)..where((t) => t.id.equals(p.id))).write(
        PlantsCompanion(
          plantedAt: Value(p.plantedAt.subtract(by)),
          // Only fruit timers that are already running move forward.
          fruitAnchorAt: Value(status.isMature ? (p.fruitAnchorAt ?? status.maturedAt).subtract(by) : null),
        ),
      );
    }
  });

  // --- Fruit basket ----------------------------------------------------------

  Stream<Map<String, int>> watchInventory() => _db
      .select(_db.inventory)
      .watch()
      .map(
        (rows) => {
          for (final r in rows)
            if (r.quantity > 0) r.itemId: r.quantity,
        },
      );

  Future<Map<String, int>> inventory() async => {
    for (final r in await _db.select(_db.inventory).get()) r.itemId: r.quantity,
  };

  Future<void> addToInventory(String itemId, int delta) async {
    final current = (await inventory())[itemId] ?? 0;
    final next = current + delta;
    if (next < 0) throw const GardenException("You don't have enough of that fruit.");
    await _db.into(_db.inventory).insertOnConflictUpdate(InventoryCompanion.insert(itemId: itemId, quantity: next));
  }
}
