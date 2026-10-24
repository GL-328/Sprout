import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/config_loader.dart';
import 'core/providers.dart';
import 'data/db/app_database.dart';
import 'core/clock.dart';
import 'data/repositories/seed_repository.dart';
import 'data/repositories/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final config = await loadGameConfig();
  final db = AppDatabase();
  final settings = await SettingsRepository(db).load();
  await SeedRepository(db, const Clock()).ensurePlot(config.startingEnvironment.id);

  runApp(
    ProviderScope(
      overrides: [
        gameConfigProvider.overrideWithValue(config),
        databaseProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(settings),
      ],
      child: const SproutApp(),
    ),
  );
}
