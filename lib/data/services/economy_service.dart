import 'package:drift/drift.dart';

import '../../config/game_config.dart';
import '../../core/clock.dart';
import '../../domain/logic/seed_roller.dart';
import '../../domain/models/seed.dart';
import '../db/app_database.dart';
import '../repositories/counters_repository.dart';
import '../repositories/seed_repository.dart';
import '../repositories/settings_repository.dart';
import 'garden_service.dart';

/// Settings key for when the visitor lure from a recipe ends (ISO time).
const visitorLureUntilKey = 'visitor_lure_until';

class RecipeOutcome {
  const RecipeOutcome(this.message);

  final String message;
}

/// Coins, selling, buying and recipes.
class EconomyService {
  EconomyService(
    this._db,
    this._config,
    this._clock,
    this._seeds,
    this._counters,
    this._garden,
    this._settings,
    this._roller,
  );

  final AppDatabase _db;
  final GameConfig _config;
  final Clock _clock;
  final SeedRepository _seeds;
  final CountersRepository _counters;
  final GardenService _garden;
  final SettingsRepository _settings;
  final SeedRoller _roller;

  Future<int> coins() => _counters.get(CounterKeys.coins);

  Future<void> _spend(int price) async {
    if (await coins() < price) {
      throw const GardenException('Not quite enough coins yet. Your garden will get you there.');
    }
    await _counters.add(CounterKeys.coins, -price);
  }

  Future<void> _earn(int amount) async {
    await _counters.add(CounterKeys.coins, amount);
    await _counters.add(CounterKeys.coinsEarned, amount);
  }

  /// Sells [quantity] fruit of [speciesId]. Returns coins earned.
  Future<int> sellFruit(String speciesId, int quantity) => _db.transaction(() async {
    if (quantity <= 0) return 0;
    await _garden.addToInventory(speciesId, -quantity);
    final earned = _config.speciesById(speciesId).fruit.sellPrice * quantity;
    await _earn(earned);
    await _counters.add(CounterKeys.fruitSold, quantity);
    return earned;
  });

  /// Composts a spare seed for a few coins.
  Future<int> compostSeed(String seedId) => _db.transaction(() async {
    final seed = await _seeds.get(seedId);
    if (seed == null || seed.state != SeedState.bag) return 0;
    await _seeds.setState(seedId, SeedState.composted);
    final coins = _config.compostCoins[seed.rarity] ?? 0;
    await _earn(coins);
    return coins;
  });

  Future<void> unlockPlot(String envId) => _db.transaction(() async {
    if ((await _seeds.unlockedEnvironments()).contains(envId)) return;
    await _spend(_config.environment(envId).price);
    await _seeds.ensurePlot(envId);
  });

  Future<void> buyCosmetic(String cosmeticId) => _db.transaction(() async {
    final owned = await (_db.select(
      _db.ownedCosmetics,
    )..where((t) => t.cosmeticId.equals(cosmeticId))).getSingleOrNull();
    if (owned != null) return;
    await _spend(_config.cosmetics[cosmeticId]!.price);
    await _db
        .into(_db.ownedCosmetics)
        .insert(OwnedCosmeticsCompanion.insert(cosmeticId: cosmeticId, boughtAt: _clock.now()));
  });

  /// Places an owned cosmetic in a plot, replacing any of the same kind.
  /// Pass `null` as [cosmeticId] to clear [kind] in that plot.
  Future<void> placeCosmetic(String envId, String kind, String? cosmeticId) async {
    if (cosmeticId == null) {
      await (_db.delete(_db.plotCosmetics)..where((t) => t.envId.equals(envId) & t.kind.equals(kind))).go();
    } else {
      await _db
          .into(_db.plotCosmetics)
          .insertOnConflictUpdate(PlotCosmeticsCompanion.insert(envId: envId, kind: kind, cosmeticId: cosmeticId));
    }
  }

  Stream<Set<String>> watchOwnedCosmetics() =>
      _db.select(_db.ownedCosmetics).watch().map((rows) => {for (final r in rows) r.cosmeticId});

  /// envId -> kind -> cosmeticId.
  Stream<Map<String, Map<String, String>>> watchPlacedCosmetics() => _db.select(_db.plotCosmetics).watch().map((rows) {
    final out = <String, Map<String, String>>{};
    for (final r in rows) {
      (out[r.envId] ??= {})[r.kind] = r.cosmeticId;
    }
    return out;
  });

  /// Buys a mystery pack. Returns the seeds inside.
  Future<List<Seed>> buyMysteryPack(String packId) => _db.transaction(() async {
    final pack = _config.mysteryPacks[packId]!;
    if (await _seeds.bagCount() + pack.seeds > _config.seedBagCap) {
      throw const GardenException('Your Seed Bag is full. Plant or compost a few seeds first.');
    }
    await _spend(pack.price);
    final unlocked = await _seeds.unlockedEnvironments();
    return [
      for (var i = 0; i < pack.seeds; i++)
        await () async {
          final rolled = _roller.rollMystery(pack.odds, unlocked);
          return _seeds.add(rolled.speciesId, rolled.rarity, SeedSource.mysteryPack);
        }(),
    ];
  });

  bool canCook(RecipeConfig recipe, Map<String, int> inventory) =>
      recipe.ingredients.entries.every((e) => (inventory[e.key] ?? 0) >= e.value);

  Future<RecipeOutcome> cook(String recipeId) => _db.transaction(() async {
    final recipe = _config.recipes[recipeId]!;
    if (!canCook(recipe, await _garden.inventory())) {
      throw const GardenException("You'll need a little more fruit for this one.");
    }
    for (final e in recipe.ingredients.entries) {
      await _garden.addToInventory(e.key, -e.value);
    }
    await _counters.add(CounterKeys.recipesMade, 1);
    final effect = recipe.effect;
    switch (effect.type) {
      case RecipeEffectType.coins:
        await _earn(effect.amount);
        return RecipeOutcome('${recipe.name} made! +${effect.amount} coins');
      case RecipeEffectType.growthBoost:
        await _garden.boostGrowth(Duration(hours: effect.hours));
        return RecipeOutcome('${recipe.name} made! Every plant jumped ${effect.hours} hours ahead');
      case RecipeEffectType.visitorLure:
        final until = _clock.now().add(Duration(hours: effect.hours));
        await _settings.writeValue(visitorLureUntilKey, until.toIso8601String());
        return RecipeOutcome('${recipe.name} made! Visitors are extra curious for ${effect.hours} hours');
    }
  });

  /// Gives a visitor its favourite fruit. Returns the thank-you coins.
  Future<int> feedVisitor(String visitorId) => _db.transaction(() async {
    final v = _config.visitors[visitorId]!;
    await _garden.addToInventory(v.favouriteFruit, -1);
    await _earn(v.thanksCoins);
    await _db.customUpdate(
      'UPDATE visitors_seen SET times_fed = times_fed + 1 WHERE visitor_id = ?',
      variables: [Variable.withString(visitorId)],
      updates: {_db.visitorsSeen},
    );
    return v.thanksCoins;
  });

  /// Records visitors that showed up. New ones go in the Journal.
  Future<void> recordVisitors(Iterable<String> visitorIds) async {
    for (final id in visitorIds) {
      await _db
          .into(_db.visitorsSeen)
          .insert(
            VisitorsSeenCompanion.insert(visitorId: id, firstSeenAt: _clock.now()),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Stream<Map<String, VisitorSeenRow>> watchVisitorsSeen() =>
      _db.select(_db.visitorsSeen).watch().map((rows) => {for (final r in rows) r.visitorId: r});
}
