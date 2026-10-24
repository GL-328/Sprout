import '../models/quest.dart';

/// Whether [quest] belongs on the Today screen on [date].
///
/// One-off quests stay until they're done once. Archived or hidden quests
/// never show.
bool isQuestDueOn(Quest quest, DateTime date, {required bool everCompleted}) {
  if (quest.archived || !quest.showOnToday) return false;
  return switch (quest.repeat) {
    RepeatKind.once => !everCompleted,
    RepeatKind.daily => true,
    RepeatKind.weekdays => quest.weekdays.contains(date.weekday),
  };
}

String weekdaysLabel(Set<int> days) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  if (days.length == 7) return 'Every day';
  if (days.isEmpty) return 'No days picked';
  final sorted = days.toList()..sort();
  if (sorted.join() == '12345') return 'Weekdays';
  if (sorted.join() == '67') return 'Weekends';
  return sorted.map((d) => names[d - 1]).join(', ');
}
