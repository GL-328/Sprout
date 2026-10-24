import '../models/app_settings.dart';
import '../models/quest.dart';

/// One repeating reminder to schedule.
class ReminderPlan {
  const ReminderPlan({required this.id, required this.title, required this.body, required this.minutes, this.weekday});

  final int id;
  final String title;
  final String body;

  /// Minutes after midnight.
  final int minutes;

  /// ISO weekday for weekly reminders; null means every day.
  final int? weekday;
}

const checkInReminderId = 1;

/// Every reminder that should exist, given the settings and quests.
/// Nothing is scheduled unless the user turned reminders on.
List<ReminderPlan> planReminders(AppSettings settings, List<Quest> quests) {
  if (!settings.remindersOn) return const [];
  final plans = <ReminderPlan>[
    ReminderPlan(
      id: checkInReminderId,
      title: 'Your garden says hi',
      body: 'Want to take a moment to check in? No pressure at all.',
      minutes: settings.checkInReminderMinutes,
    ),
  ];
  for (final (i, q) in quests.indexed) {
    if (!q.reminderOn || q.archived || !q.showOnToday || q.reminderMinutes == null) continue;
    const body = 'A gentle nudge, only if it feels right today.';
    final base = 1000 + i * 10;
    if (q.repeat == RepeatKind.weekdays) {
      for (final d in q.weekdays) {
        plans.add(ReminderPlan(id: base + d, title: q.title, body: body, minutes: q.reminderMinutes!, weekday: d));
      }
    } else {
      plans.add(ReminderPlan(id: base, title: q.title, body: body, minutes: q.reminderMinutes!));
    }
  }
  return plans;
}
