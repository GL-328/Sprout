import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/app.dart';
import 'package:sprout/config/game_config.dart';
import 'package:sprout/core/providers.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/domain/models/app_settings.dart';

final testConfig = GameConfig.parse(File('assets/config/game_config.yaml').readAsStringSync());

/// The real app wired to an in-memory database.
Widget testApp(AppDatabase db, {AppSettings settings = const AppSettings()}) => ProviderScope(
  overrides: [
    gameConfigProvider.overrideWithValue(testConfig),
    databaseProvider.overrideWithValue(db),
    initialSettingsProvider.overrideWithValue(settings),
  ],
  child: const SproutApp(),
);

AppDatabase memoryDb() => AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
