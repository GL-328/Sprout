import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Keys for [CountersRepository].
abstract final class CounterKeys {
  static const coins = 'coins';
  static const questsCompleted = 'quests_completed';
  static const seedsEarned = 'seeds_earned';
  static const fruitHarvested = 'fruit_harvested';
  static const fruitSold = 'fruit_sold';
  static const coinsEarned = 'coins_earned';
  static const plantsGrown = 'plants_grown';
  static const recipesMade = 'recipes_made';
}

class CountersRepository {
  CountersRepository(this._db);

  final AppDatabase _db;

  Future<int> get(String key) async {
    final row = await (_db.select(_db.counters)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value ?? 0;
  }

  Stream<int> watch(String key) =>
      (_db.select(_db.counters)..where((t) => t.key.equals(key))).watchSingleOrNull().map((r) => r?.value ?? 0);

  Stream<Map<String, int>> watchAll() =>
      _db.select(_db.counters).watch().map((rows) => {for (final r in rows) r.key: r.value});

  /// Adds [delta] (may be negative). Never goes below zero.
  Future<int> add(String key, int delta) => _db.transaction(() async {
    final next = (await get(key) + delta).clamp(0, 1 << 52);
    await _db.into(_db.counters).insertOnConflictUpdate(CountersCompanion.insert(key: key, value: Value(next)));
    return next;
  });
}
