import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sprout/config/game_config.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/data/repositories/quest_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/data/services/garden_service.dart';
import 'package:sprout/data/services/progress_service.dart';
import 'package:sprout/domain/logic/seed_roller.dart';

/// Real services over an in-memory database and a fake clock.
class TestEnv {
  TestEnv({DateTime? start, int seed = 1})
    : clock = FakeClock(start ?? DateTime(2026, 3, 2, 9)),
      db = AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true)) {
    seeds = SeedRepository(db, clock);
    counters = CountersRepository(db);
    quests = QuestRepository(db, clock);
    progress = ProgressService(db, config, clock, seeds, counters, SeedRoller(config, Random(seed)));
    garden = GardenService(db, config, clock, seeds, counters);
  }

  static final config = GameConfig.parse(File('assets/config/game_config.yaml').readAsStringSync());

  final FakeClock clock;
  final AppDatabase db;
  late final SeedRepository seeds;
  late final CountersRepository counters;
  late final QuestRepository quests;
  late final ProgressService progress;
  late final GardenService garden;

  Future<void> close() => db.close();
}
