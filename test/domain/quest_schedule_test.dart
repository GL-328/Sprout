import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/greeting.dart';
import 'package:sprout/domain/logic/quest_schedule.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/domain/models/quest.dart';

Quest q({RepeatKind repeat = RepeatKind.daily, Set<int> days = const {}, bool show = true, bool archived = false}) =>
    Quest(
      id: 'q',
      title: 'Q',
      category: QuestCategory.home,
      difficulty: Difficulty.small,
      repeat: repeat,
      weekdays: days,
      showOnToday: show,
      archived: archived,
      createdAt: DateTime(2026),
    );

void main() {
  final monday = DateTime(2026, 3, 2);
  final saturday = DateTime(2026, 3, 7);

  test('daily quests show every day', () {
    expect(isQuestDueOn(q(), monday, everCompleted: true), isTrue);
  });

  test('weekday quests show only on their days', () {
    final quest = q(repeat: RepeatKind.weekdays, days: {1, 3, 5});
    expect(isQuestDueOn(quest, monday, everCompleted: false), isTrue);
    expect(isQuestDueOn(quest, saturday, everCompleted: false), isFalse);
  });

  test('one-off quests stay until done once', () {
    expect(isQuestDueOn(q(repeat: RepeatKind.once), monday, everCompleted: false), isTrue);
    expect(isQuestDueOn(q(repeat: RepeatKind.once), monday, everCompleted: true), isFalse);
  });

  test('hidden and archived quests never show', () {
    expect(isQuestDueOn(q(show: false), monday, everCompleted: false), isFalse);
    expect(isQuestDueOn(q(archived: true), monday, everCompleted: false), isFalse);
  });

  test('weekday labels', () {
    expect(weekdaysLabel({1, 2, 3, 4, 5}), 'Weekdays');
    expect(weekdaysLabel({6, 7}), 'Weekends');
    expect(weekdaysLabel({1, 3}), 'Mon, Wed');
    expect(weekdaysLabel({1, 2, 3, 4, 5, 6, 7}), 'Every day');
  });

  test('greetings follow the time of day', () {
    expect(greetingFor(DateTime(2026, 1, 1, 8), 'Robin'), 'Good morning, Robin');
    expect(greetingFor(DateTime(2026, 1, 1, 14), ''), 'Good afternoon');
    expect(greetingFor(DateTime(2026, 1, 1, 19), 'Robin'), 'Good evening, Robin');
    expect(greetingFor(DateTime(2026, 1, 1, 2), 'Robin'), 'Peaceful night, Robin');
  });

  test('settings survive unknown or missing values', () {
    final s = AppSettings.fromEntries({'theme': 'neon', 'focus_areas': 'sleep,unknown', 'accent': 'sage'});
    expect(s.theme, ThemePreference.system);
    expect(s.focusAreas, {QuestCategory.sleep});
    expect(s.accent, AccentChoice.sage);
  });
}
