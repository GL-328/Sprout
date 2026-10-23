import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/data/repositories/settings_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepository(db);
  });

  tearDown(() => db.close());

  test('fresh install has gentle defaults', () async {
    final s = await repo.load();
    expect(s.onboardingDone, isFalse);
    expect(s.soundOn, isFalse, reason: 'sound is off by default');
    expect(s.remindersOn, isFalse, reason: 'reminders are opt-in');
  });

  test('settings round-trip through the database', () async {
    const saved = AppSettings(
      name: 'Robin',
      onboardingDone: true,
      focusAreas: {QuestCategory.sleep, QuestCategory.foodWater},
      theme: ThemePreference.dark,
      accent: AccentChoice.lilac,
      soundOn: true,
      reducedMotion: true,
      remindersOn: true,
      checkInReminderMinutes: 8 * 60 + 30,
    );
    await repo.save(saved);
    final loaded = await repo.load();
    expect(loaded.toEntries(), saved.toEntries());
  });

  test('single values can be stored', () async {
    expect(await repo.readValue('x'), isNull);
    await repo.writeValue('x', '1');
    await repo.writeValue('x', '2');
    expect(await repo.readValue('x'), '2');
  });
}
