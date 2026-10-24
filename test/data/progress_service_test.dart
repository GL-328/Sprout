import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/domain/models/quest.dart';

import 'test_env.dart';

void main() {
  late TestEnv env;
  late Quest walk;

  setUp(() async {
    env = TestEnv();
    await env.garden.ensureStartingPlot();
    walk = await env.quests.create(title: 'Walk', category: QuestCategory.movement, difficulty: Difficulty.small);
  });

  tearDown(() => env.close());

  Future<int> bagSize() => env.seeds.bagCount();

  test('every third completion earns one seed', () async {
    final a = await env.progress.complete(walk);
    final b = await env.progress.complete(walk);
    expect(a.seed, isNull);
    expect(b.seed, isNull);
    expect((await env.progress.watchMeter().first).filled, 2);

    final c = await env.progress.complete(walk);
    expect(c.seed, isNotNull);
    expect(c.seed!.rarity, Rarity.common);
    expect(TestEnv.config.speciesById(c.seed!.speciesId).family, 'sunflower');
    expect(await bagSize(), 1);
    expect((await env.progress.watchMeter().first).filled, 0);
    expect(await env.counters.get(CounterKeys.seedsEarned), 1);
  });

  test('meter carries over between days', () async {
    await env.progress.complete(walk);
    await env.progress.complete(walk);
    env.clock.advance(const Duration(days: 3));
    final c = await env.progress.complete(walk);
    expect(c.seed, isNotNull);
  });

  test('only the daily limit fills the meter; extra quests still count as done', () async {
    final results = [for (var i = 0; i < 11; i++) await env.progress.complete(walk)];
    expect(results.where((r) => r.counted).length, 9);
    expect(results.where((r) => r.seed != null).length, 3);
    expect(results.last.counted, isFalse);
    expect(await env.counters.get(CounterKeys.questsCompleted), 11);
    expect(await bagSize(), 3);

    env.clock.advance(const Duration(days: 1));
    expect((await env.progress.complete(walk)).counted, isTrue, reason: 'a new day, a fresh meter');
  });

  test('undo rolls back the meter', () async {
    await env.progress.complete(walk);
    final b = await env.progress.complete(walk);
    await env.progress.undo(b.completionId);
    expect((await env.progress.watchMeter().first).filled, 1);
    expect(await env.counters.get(CounterKeys.questsCompleted), 1);
  });

  test('undoing the completion that earned a seed removes the seed', () async {
    await env.progress.complete(walk);
    await env.progress.complete(walk);
    final c = await env.progress.complete(walk);
    expect(await bagSize(), 1);

    await env.progress.undo(c.completionId);
    expect(await bagSize(), 0);
    expect((await env.progress.watchMeter().first).filled, 2);
    expect(await env.counters.get(CounterKeys.seedsEarned), 0);

    final again = await env.progress.complete(walk);
    expect(again.seed, isNotNull, reason: 'the meter refills normally');
  });

  test('undo frees a slot in the daily limit', () async {
    final results = [for (var i = 0; i < 9; i++) await env.progress.complete(walk)];
    await env.progress.undo(results.last.completionId);
    expect((await env.progress.complete(walk)).counted, isTrue);
  });

  test('deleting a quest keeps its history', () async {
    await env.progress.complete(walk);
    await env.quests.delete(walk.id);
    final history = await env.quests.watchHistory().first;
    expect(history.single.title, 'Walk');
    expect(history.single.questId, isNull);
  });

  test('starter quests come from focus areas', () async {
    await env.quests.addStarterQuests({QuestCategory.sleep});
    await env.quests.addStarterQuests({QuestCategory.sleep});
    final all = await env.quests.watchQuests().first;
    expect(all.where((q) => q.category == QuestCategory.sleep).length, 2, reason: 'no duplicates');
  });
}
