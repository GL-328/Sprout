import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/config/game_config.dart';
import 'package:sprout/domain/logic/growth.dart';
import 'package:sprout/domain/models/plant.dart';
import 'package:sprout/domain/logic/reminders.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/domain/models/quest.dart';

Quest quest(
  String id, {
  bool reminder = true,
  RepeatKind repeat = RepeatKind.daily,
  Set<int> days = const {},
  bool archived = false,
}) => Quest(
  id: id,
  title: 'Quest $id',
  category: QuestCategory.mind,
  difficulty: Difficulty.small,
  repeat: repeat,
  weekdays: days,
  reminderOn: reminder,
  reminderMinutes: 600,
  archived: archived,
  createdAt: DateTime(2026),
);

void main() {
  test('nothing is scheduled while reminders are off', () {
    expect(planReminders(const AppSettings(), [quest('a')]), isEmpty);
  });

  test('check-in plus each quest reminder the user turned on', () {
    final plans = planReminders(const AppSettings(remindersOn: true, notifyQuests: true, checkInReminderMinutes: 540), [
      quest('a'),
      quest('b', reminder: false),
      quest('c', archived: true),
      quest('d', repeat: RepeatKind.weekdays, days: {1, 3}),
    ]);
    expect(plans.first.id, checkInReminderId);
    expect(plans.first.minutes, 540);
    expect(plans.where((p) => p.title == 'Quest a'), hasLength(1));
    expect(plans.where((p) => p.title == 'Quest b'), isEmpty);
    expect(plans.where((p) => p.title == 'Quest c'), isEmpty);
    expect(plans.where((p) => p.title == 'Quest d').map((p) => p.weekday), [1, 3]);
    expect(plans.map((p) => p.id).toSet(), hasLength(plans.length), reason: 'ids are unique');
  });

  test('reminder wording is gentle', () {
    final plans = planReminders(const AppSettings(remindersOn: true, notifyQuests: true), [quest('a')]);
    for (final p in plans) {
      expect(
        '${p.title} ${p.body}'.toLowerCase(),
        isNot(anyOf(contains('overdue'), contains('missed'), contains('late'))),
      );
    }
  });

  test('check-in and quest reminders are separate choices', () {
    final checkInOnly = planReminders(const AppSettings(remindersOn: true), [quest('a')]);
    expect(checkInOnly.map((p) => p.id), [checkInReminderId]);
    final questsOnly = planReminders(const AppSettings(notifyQuests: true), [quest('a')]);
    expect(questsOnly.map((p) => p.title), ['Quest a']);
  });

  group('garden notifications', () {
    final config = GameConfig.parse(File('assets/config/game_config.yaml').readAsStringSync());
    final planted = DateTime(2026, 3, 2, 9);
    final sunflower = config.speciesById('giant_sunflower');
    Plant plant({DateTime? at, String id = 'p'}) => Plant(
      id: id,
      envId: 'meadow',
      slot: 0,
      speciesId: sunflower.id,
      rarity: sunflower.rarity,
      plantedAt: at ?? planted,
    );
    const both = AppSettings(notifyFruit: true, notifyGrown: true);

    test('nothing unless turned on', () {
      expect(planGardenNotices(const AppSettings(), config, [plant()], planted), isEmpty);
    });

    test('a growing plant: fully grown, at the moment it matures', () {
      final notices = planGardenNotices(both, config, [plant()], planted.add(const Duration(minutes: 30)));
      expect(notices, hasLength(1));
      final status = Growth.status(sunflower, plantedAt: planted, now: planted);
      expect(notices.single.at, status.maturedAt);
      expect(notices.single.title, contains('fully grown'));
      expect(planGardenNotices(const AppSettings(notifyFruit: true), config, [plant()], planted), isEmpty);
    });

    test('a grown plant: fruit ready, when the next harvest is', () {
      final grown = Growth.status(sunflower, plantedAt: planted, now: planted).maturedAt;
      final now = grown.add(const Duration(minutes: 1));
      final notices = planGardenNotices(both, config, [plant()], now);
      expect(notices, hasLength(1));
      expect(notices.single.title, contains(sunflower.fruit.name));
      final status = Growth.status(sunflower, plantedAt: planted, now: now);
      expect(notices.single.at, now.add(status.untilNextHarvest!));
      expect(planGardenNotices(const AppSettings(notifyGrown: true), config, [plant()], now), isEmpty);
    });

    test('fruit already waiting is not news, and every plant gets its own id', () {
      final later = planted.add(const Duration(days: 2));
      expect(planGardenNotices(both, config, [plant()], later), isEmpty);
      final two = planGardenNotices(both, config, [plant(), plant(id: 'q', at: later)], later);
      expect(two.map((n) => n.id).toSet(), hasLength(two.length));
      expect(two.every((n) => n.id >= gardenNoticeBaseId), isTrue);
    });
  });
}
