import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../config/game_config.dart';
import '../../core/clock.dart';
import '../../domain/logic/seed_meter.dart';
import '../../domain/logic/seed_roller.dart';
import '../../domain/models/quest.dart';
import '../../domain/models/seed.dart';
import '../db/app_database.dart';
import '../repositories/counters_repository.dart';
import '../repositories/mappers.dart';
import '../repositories/seed_repository.dart';

class CompletionResult {
  const CompletionResult({required this.completionId, required this.counted, this.seed});

  final String completionId;
  final bool counted;

  /// Set when this completion filled the meter.
  final Seed? seed;
}

/// Snapshot of the Seed Meter.
class MeterState {
  const MeterState({required this.filled, required this.countedToday, required this.questsPerSeed});

  final int filled;
  final int countedToday;
  final int questsPerSeed;
}

/// Completing and undoing quests, and turning a full meter into a seed.
class ProgressService {
  ProgressService(this._db, this._config, this._clock, this._seeds, this._counters, this._roller);

  final AppDatabase _db;
  final GameConfig _config;
  final Clock _clock;
  final SeedRepository _seeds;
  final CountersRepository _counters;
  final SeedRoller _roller;
  static const _uuid = Uuid();

  SeedMeterRules get rules => SeedMeterRules(_config);

  Future<int> _countedOn(String day) async {
    final count = _db.completions.id.count();
    final row =
        await (_db.selectOnly(_db.completions)
              ..addColumns([count])
              ..where(_db.completions.day.equals(day) & _db.completions.counted.equals(true)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<CompletionResult> complete(Quest quest) => _db.transaction(() async {
    final now = _clock.now();
    final day = dayKey(now);
    final counted = rules.countsTowardMeter(await _countedOn(day));
    final id = _uuid.v4();
    await _db
        .into(_db.completions)
        .insert(
          CompletionsCompanion.insert(
            id: id,
            questId: Value(quest.id),
            title: quest.title,
            category: quest.category.id,
            difficulty: quest.difficulty.id,
            completedAt: now,
            day: day,
            counted: counted,
          ),
        );
    await (_db.delete(_db.dayMarks)..where((t) => t.questId.equals(quest.id) & t.day.equals(day))).go();
    await _counters.add(CounterKeys.questsCompleted, 1);

    Seed? seed;
    if (counted) {
      final open =
          await (_db.select(_db.completions)
                ..where((t) => t.counted.equals(true) & t.seedId.isNull())
                ..orderBy([(t) => OrderingTerm(expression: t.completedAt)]))
              .get();
      if (open.length >= _config.questsPerSeed) {
        final batch = open.take(_config.questsPerSeed).map(completionFromRow).toList();
        final rolled = _roller.rollForQuests([
          for (final c in batch) (category: c.category, difficulty: c.difficulty),
        ], await _seeds.unlockedEnvironments());
        seed = await _seeds.add(rolled.speciesId, rolled.rarity, SeedSource.quests);
        await (_db.update(
          _db.completions,
        )..where((t) => t.id.isIn(batch.map((c) => c.id)))).write(CompletionsCompanion(seedId: Value(seed.id)));
        await _counters.add(CounterKeys.seedsEarned, 1);
      }
    }
    return CompletionResult(completionId: id, counted: counted, seed: seed);
  });

  /// Takes back a completion. If it had just earned a seed, the seed goes too
  /// and the meter goes back to how it was.
  Future<void> undo(String completionId) => _db.transaction(() async {
    final row = await (_db.select(_db.completions)..where((t) => t.id.equals(completionId))).getSingleOrNull();
    if (row == null) return;
    final seedId = row.seedId;
    if (seedId != null) {
      final seed = await _seeds.get(seedId);
      if (seed != null && seed.state == SeedState.bag) {
        await _seeds.delete(seedId);
        await (_db.update(
          _db.completions,
        )..where((t) => t.seedId.equals(seedId))).write(const CompletionsCompanion(seedId: Value(null)));
        await _counters.add(CounterKeys.seedsEarned, -1);
      }
    }
    await (_db.delete(_db.completions)..where((t) => t.id.equals(completionId))).go();
    await _counters.add(CounterKeys.questsCompleted, -1);
  });

  Stream<MeterState> watchMeter() {
    final today = dayKey(_clock.now());
    return (_db.select(
      _db.completions,
    )..where((t) => t.counted.equals(true) & (t.seedId.isNull() | t.day.equals(today)))).watch().map((rows) {
      final open = rows.where((r) => r.seedId == null).length;
      final countedToday = rows.where((r) => r.day == today).length;
      return MeterState(filled: rules.filled(open), countedToday: countedToday, questsPerSeed: _config.questsPerSeed);
    });
  }
}
