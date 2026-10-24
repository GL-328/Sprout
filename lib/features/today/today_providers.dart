import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/services/progress_service.dart';
import '../../domain/logic/quest_schedule.dart';
import '../../domain/models/quest.dart';
import '../../domain/models/seed.dart';

final questsProvider = StreamProvider<List<Quest>>((ref) => ref.watch(questRepositoryProvider).watchQuests());

final todayCompletionsProvider = StreamProvider<List<Completion>>((ref) {
  final day = ref.watch(todayKeyProvider);
  return ref.watch(questRepositoryProvider).watchCompletionsOn(day);
});

final everCompletedProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(questRepositoryProvider).watchEverCompletedQuestIds(),
);

final dayMarksProvider = StreamProvider<Map<String, DayMarkKind>>((ref) {
  final day = ref.watch(todayKeyProvider);
  return ref.watch(questRepositoryProvider).watchDayMarks(day);
});

final meterProvider = StreamProvider<MeterState>((ref) {
  ref.watch(todayKeyProvider);
  return ref.watch(progressServiceProvider).watchMeter();
});

final seedBagProvider = StreamProvider<List<Seed>>((ref) => ref.watch(seedRepositoryProvider).watchBag());

/// What the Today screen shows.
class TodayView {
  const TodayView({required this.todo, required this.later, required this.done, required this.skipped});

  final List<Quest> todo;
  final List<Quest> later;
  final List<Completion> done;
  final List<Quest> skipped;
}

final todayViewProvider = Provider<AsyncValue<TodayView>>((ref) {
  final quests = ref.watch(questsProvider);
  final done = ref.watch(todayCompletionsProvider);
  final ever = ref.watch(everCompletedProvider);
  final marks = ref.watch(dayMarksProvider);
  if (quests is AsyncLoading || done is AsyncLoading || ever is AsyncLoading || marks is AsyncLoading) {
    return const AsyncLoading();
  }
  final now = ref.watch(nowProvider).value ?? ref.watch(clockProvider).now();
  final doneToday = done.value ?? const [];
  final doneIds = {for (final c in doneToday) c.questId};
  final markMap = marks.value ?? const {};
  final due = [
    for (final q in quests.value ?? const <Quest>[])
      if (isQuestDueOn(q, now, everCompleted: (ever.value ?? const {}).contains(q.id) && !doneIds.contains(q.id))) q,
  ];
  final open = due.where((q) => !doneIds.contains(q.id)).toList();
  return AsyncData(
    TodayView(
      todo: open.where((q) => markMap[q.id] == null).toList(),
      later: open.where((q) => markMap[q.id] == DayMarkKind.later).toList(),
      skipped: open.where((q) => markMap[q.id] == DayMarkKind.skip).toList(),
      done: doneToday,
    ),
  );
});
