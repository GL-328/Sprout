import '../../core/clock.dart';

/// Days in a row of caring for yourself, counting rest days. Today doesn't
/// need to be done yet for the streak to continue. Missing a day never
/// "breaks" anything: the count just starts again, quietly.
int gentleStreak({required Set<String> activeDays, required DateTime now}) {
  var day = DateTime(now.year, now.month, now.day);
  if (!activeDays.contains(dayKey(day))) day = day.subtract(const Duration(days: 1));
  var count = 0;
  while (activeDays.contains(dayKey(day))) {
    count++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return count;
}
