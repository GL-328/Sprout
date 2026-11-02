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
    expect(s.musicOn, isFalse, reason: 'music is off by default');
    expect(s.remindersOn, isFalse, reason: 'reminders are opt-in');
    expect(s.autoUpdate, isTrue, reason: 'updates are on unless turned off');
  });

  test('settings round-trip through the database', () async {
    const saved = AppSettings(
      name: 'Robin',
      onboardingDone: true,
      focusAreas: {QuestCategory.sleep, QuestCategory.foodWater},
      theme: ThemePreference.dark,
      accent: AccentChoice.lilac,
      soundOn: true,
      musicOn: true,
      reducedMotion: true,
      remindersOn: true,
      notifyQuests: true,
      notifyFruit: true,
      notifyGrown: true,
      checkInReminderMinutes: 8 * 60 + 30,
      autoUpdate: false,
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

  test('anyone with reminders on before keeps their quest reminders', () async {
    await repo.writeValue('reminders_on', 'true');
    final s = await repo.load();
    expect(s.remindersOn, isTrue);
    expect(s.notifyQuests, isTrue);
    expect(s.notifyFruit || s.notifyGrown, isFalse, reason: 'the new garden ones start off');
  });
}
