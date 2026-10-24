import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/data/services/backup_service.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';

import 'test_env.dart';

void main() {
  late TestEnv env;

  setUp(() async {
    env = TestEnv();
    await env.garden.ensureStartingPlot();
  });

  tearDown(() => env.close());

  Future<void> fill(TestEnv e) async {
    final q = await e.quests.create(title: 'Stretch', category: QuestCategory.movement, difficulty: Difficulty.medium);
    for (var i = 0; i < 3; i++) {
      await e.progress.complete(q);
    }
    await e.garden.grantStarterSeed(plant: true);
    await e.counters.add(CounterKeys.coins, 42);
    await e.wellbeing.setMood('2026-03-02', 4, 'sunny walk');
    await e.wellbeing.addContact('Sam', '0123', 'best friend');
    await e.settings.save(const AppSettings(name: 'Robin', onboardingDone: true));
  }

  test('export then import restores everything', () async {
    await fill(env);
    final json = await env.backup.exportJson();

    final other = TestEnv();
    addTearDown(other.close);
    await other.backup.importJson(json);

    expect(await other.counters.get(CounterKeys.coins), 42);
    expect((await other.quests.watchQuests().first).single.title, 'Stretch');
    expect((await other.quests.watchHistory().first), hasLength(3));
    expect(await other.seeds.bagCount(), 1);
    expect((await other.garden.watchPlants('meadow').first).single.speciesId, 'giant_sunflower');
    expect((await other.wellbeing.watchMood('2026-03-02').first)!.note, 'sunny walk');
    expect((await other.wellbeing.watchContacts().first).single.name, 'Sam');
    expect((await other.settings.load()).name, 'Robin');
    expect(
      (await other.quests.watchHistory().first).first.completedAt,
      (await env.quests.watchHistory().first).first.completedAt,
    );
  });

  test('a file that is not a backup changes nothing', () async {
    await fill(env);
    for (final bad in ['not json', '{"app":"other"}', '[]']) {
      expect(() => env.backup.importJson(bad), throwsA(isA<BackupException>()));
    }
    expect(await env.counters.get(CounterKeys.coins), 42);
  });

  test('delete all starts fresh', () async {
    await fill(env);
    await env.backup.deleteAll();
    expect(await env.counters.get(CounterKeys.coins), 0);
    expect(await env.quests.watchQuests().first, isEmpty);
    expect((await env.settings.load()).onboardingDone, isFalse);
    expect(await env.seeds.unlockedEnvironments(), isEmpty);
  });
}
