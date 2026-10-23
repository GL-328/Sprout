import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/game_config.dart';
import '../data/db/app_database.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/models/app_settings.dart';
import 'clock.dart';

/// Overridden in `main.dart` once the config has been loaded.
final gameConfigProvider = Provider<GameConfig>((ref) => throw UnimplementedError('gameConfigProvider not set'));

/// Overridden in `main.dart` (and in tests with an in-memory database).
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('databaseProvider not set'));

final clockProvider = Provider<Clock>((ref) => const Clock());

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

/// Settings read before the first frame, so the theme is right immediately.
final initialSettingsProvider = Provider<AppSettings>((ref) => const AppSettings());

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialSettingsProvider);

  Future<void> update(AppSettings Function(AppSettings s) change) async {
    state = change(state);
    await ref.read(settingsRepositoryProvider).save(state);
  }
}
