import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/game_config.dart';
import '../data/db/app_database.dart';
import '../data/repositories/counters_repository.dart';
import '../data/repositories/quest_repository.dart';
import '../data/repositories/seed_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/wellbeing_repository.dart';
import '../data/services/backup_service.dart';
import '../data/services/economy_service.dart';
import '../data/services/garden_service.dart';
import '../data/services/progress_service.dart';
import '../domain/logic/reminders.dart';
import '../domain/logic/seed_roller.dart';
import '../domain/models/app_settings.dart';
import 'clock.dart';
import 'notifications_service.dart';
import 'sound_service.dart';
import 'updater.dart';

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

  /// Re-reads settings from the database, after an import or a reset.
  Future<void> reload() async {
    state = await ref.read(settingsRepositoryProvider).load();
  }
}

final countersRepositoryProvider = Provider<CountersRepository>(
  (ref) => CountersRepository(ref.watch(databaseProvider)),
);

final questRepositoryProvider = Provider<QuestRepository>(
  (ref) => QuestRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final seedRepositoryProvider = Provider<SeedRepository>(
  (ref) => SeedRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final seedRollerProvider = Provider<SeedRoller>((ref) => SeedRoller(ref.watch(gameConfigProvider)));

final progressServiceProvider = Provider<ProgressService>(
  (ref) => ProgressService(
    ref.watch(databaseProvider),
    ref.watch(gameConfigProvider),
    ref.watch(clockProvider),
    ref.watch(seedRepositoryProvider),
    ref.watch(countersRepositoryProvider),
    ref.watch(seedRollerProvider),
  ),
);

/// "Now", refreshed every minute so growth timers and "today" stay current.
final nowProvider = StreamProvider<DateTime>((ref) async* {
  final clock = ref.watch(clockProvider);
  yield clock.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => clock.now());
});

/// Today's day key (`yyyy-mm-dd`). Changes at midnight.
final todayKeyProvider = Provider<String>((ref) {
  final now = ref.watch(nowProvider).value ?? ref.watch(clockProvider).now();
  return dayKey(now);
});

/// The platform notification scheduler. Overridden with a no-op in tests.
final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) => LocalNotificationScheduler());

/// Re-schedules reminder notifications. Invalidate it after quests or
/// reminder settings change.
final reminderSyncProvider = FutureProvider<void>((ref) async {
  final settings = ref.watch(settingsProvider);
  final quests = await ref.read(questRepositoryProvider).watchQuests(includeArchived: false).first;
  try {
    await ref.read(reminderSchedulerProvider).replaceAll(planReminders(settings, quests));
  } catch (e) {
    // Reminders are a nice-to-have; never break the app over them.
    debugPrint('Could not schedule reminders: $e');
  }
});

final gardenServiceProvider = Provider<GardenService>(
  (ref) => GardenService(
    ref.watch(databaseProvider),
    ref.watch(gameConfigProvider),
    ref.watch(clockProvider),
    ref.watch(seedRepositoryProvider),
    ref.watch(countersRepositoryProvider),
  ),
);

final economyServiceProvider = Provider<EconomyService>(
  (ref) => EconomyService(
    ref.watch(databaseProvider),
    ref.watch(gameConfigProvider),
    ref.watch(clockProvider),
    ref.watch(seedRepositoryProvider),
    ref.watch(countersRepositoryProvider),
    ref.watch(gardenServiceProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(seedRollerProvider),
  ),
);

final wellbeingRepositoryProvider = Provider<WellbeingRepository>(
  (ref) => WellbeingRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

/// Soft sounds, following the "Sounds" setting. Silent in tests.
final soundServiceProvider = Provider<SoundService>((ref) {
  final service = AudioSoundService(enabled: ref.read(settingsProvider).soundOn);
  ref.listen(settingsProvider.select((s) => s.soundOn), (_, on) => service.setEnabled(on));
  return service;
});

/// Self-updates from GitHub Releases. A no-op in tests.
final updaterProvider = Provider<Updater>((ref) => GitHubReleaseUpdater());

/// Settings key for when updates were last checked (ISO time).
const lastUpdateCheckKey = 'last_update_check';
