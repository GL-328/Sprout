import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/clock.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/seed.dart';
import '../db/app_database.dart';
import 'mappers.dart';

class SeedRepository {
  SeedRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;
  static const _uuid = Uuid();

  Stream<List<Seed>> watchBag() =>
      (_db.select(_db.seeds)
            ..where((t) => t.state.equals(SeedState.bag.name))
            ..orderBy([(t) => OrderingTerm(expression: t.earnedAt, mode: OrderingMode.desc)]))
          .watch()
          .map((rows) => rows.map(seedFromRow).toList());

  Future<int> bagCount() async {
    final count = _db.seeds.id.count();
    final row =
        await (_db.selectOnly(_db.seeds)
              ..addColumns([count])
              ..where(_db.seeds.state.equals(SeedState.bag.name)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<Seed?> get(String id) async {
    final row = await (_db.select(_db.seeds)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : seedFromRow(row);
  }

  Future<Seed> add(String speciesId, Rarity rarity, SeedSource source) async {
    final seed = Seed(id: _uuid.v4(), speciesId: speciesId, rarity: rarity, source: source, earnedAt: _clock.now());
    await _db
        .into(_db.seeds)
        .insert(
          SeedsCompanion.insert(
            id: seed.id,
            speciesId: speciesId,
            rarity: rarity.id,
            source: source.name,
            earnedAt: seed.earnedAt,
          ),
        );
    return seed;
  }

  Future<void> setState(String id, SeedState state) =>
      (_db.update(_db.seeds)..where((t) => t.id.equals(id))).write(SeedsCompanion(state: Value(state.name)));

  Future<void> delete(String id) => (_db.delete(_db.seeds)..where((t) => t.id.equals(id))).go();

  /// Environments the user has unlocked.
  Future<Set<String>> unlockedEnvironments() async => {for (final r in await _db.select(_db.plots).get()) r.envId};

  Stream<Set<String>> watchUnlockedEnvironments() =>
      _db.select(_db.plots).watch().map((rows) => {for (final r in rows) r.envId});

  Future<void> ensurePlot(String envId) => _db
      .into(_db.plots)
      .insert(
        PlotsCompanion.insert(envId: envId, unlockedAt: _clock.now()),
        mode: InsertMode.insertOrIgnore,
      );
}
