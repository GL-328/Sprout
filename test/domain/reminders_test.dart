import 'package:flutter_test/flutter_test.dart';
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
    final plans = planReminders(const AppSettings(remindersOn: true, checkInReminderMinutes: 540), [
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
    final plans = planReminders(const AppSettings(remindersOn: true), [quest('a')]);
    for (final p in plans) {
      expect(
        '${p.title} ${p.body}'.toLowerCase(),
        isNot(anyOf(contains('overdue'), contains('missed'), contains('late'))),
      );
    }
  });
}
