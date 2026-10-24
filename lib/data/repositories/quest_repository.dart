import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/clock.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/quest.dart';
import '../db/app_database.dart';
import '../premade/premade_quests.dart';
import 'mappers.dart';

class QuestRepository {
  QuestRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;
  static const _uuid = Uuid();

  Stream<List<Quest>> watchQuests({bool includeArchived = true}) {
    final q = _db.select(_db.quests)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder), (t) => OrderingTerm(expression: t.createdAt)]);
    if (!includeArchived) q.where((t) => t.archived.equals(false));
    return q.watch().map((rows) => rows.map(questFromRow).toList());
  }

  Future<Quest?> getQuest(String id) async {
    final row = await (_db.select(_db.quests)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : questFromRow(row);
  }

  Future<int> _nextSortOrder() async {
    final max = _db.quests.sortOrder.max();
    final row = await (_db.selectOnly(_db.quests)..addColumns([max])).getSingle();
    return (row.read(max) ?? 0) + 1;
  }

  /// Creates a new quest. [Quest.id] and [Quest.createdAt] are filled in.
  Future<Quest> create({
    required String title,
    required QuestCategory category,
    required Difficulty difficulty,
    String notes = '',
    RepeatKind repeat = RepeatKind.daily,
    Set<int> weekdays = const {},
    String? premadeKey,
    bool reminderOn = false,
    int? reminderMinutes,
  }) async {
    final quest = Quest(
      id: _uuid.v4(),
      title: title,
      category: category,
      difficulty: difficulty,
      notes: notes,
      repeat: repeat,
      weekdays: weekdays,
      premadeKey: premadeKey,
      reminderOn: reminderOn,
      reminderMinutes: reminderMinutes,
      createdAt: _clock.now(),
    );
    await _db.into(_db.quests).insert(questToCompanion(quest, sortOrder: await _nextSortOrder()));
    return quest;
  }

  /// Adds a premade quest to the user's list (or brings back an archived copy).
  Future<Quest> addPremade(PremadeQuest p) async {
    final existing = await (_db.select(_db.quests)..where((t) => t.premadeKey.equals(p.key))).getSingleOrNull();
    if (existing != null) {
      final q = questFromRow(existing).copyWith(archived: false, showOnToday: true);
      await update(q);
      return q;
    }
    return create(
      title: p.title,
      category: p.category,
      difficulty: p.difficulty,
      notes: p.description,
      premadeKey: p.key,
    );
  }

  Future<void> update(Quest q) async {
    await (_db.update(_db.quests)..where((t) => t.id.equals(q.id))).write(
      QuestsCompanion(
        title: Value(q.title),
        category: Value(q.category.id),
        difficulty: Value(q.difficulty.id),
        notes: Value(q.notes),
        repeat: Value(q.repeat.id),
        weekdays: Value((q.weekdays.toList()..sort()).join(',')),
        showOnToday: Value(q.showOnToday),
        archived: Value(q.archived),
        reminderOn: Value(q.reminderOn),
        reminderMinutes: Value(q.reminderMinutes),
      ),
    );
  }

  Future<void> setArchived(String id, bool archived) =>
      (_db.update(_db.quests)..where((t) => t.id.equals(id))).write(QuestsCompanion(archived: Value(archived)));

  Future<void> setShowOnToday(String id, bool show) =>
      (_db.update(_db.quests)..where((t) => t.id.equals(id))).write(QuestsCompanion(showOnToday: Value(show)));

  /// Deletes a quest. Its past completions stay in history.
  Future<void> delete(String id) => _db.transaction(() async {
    await (_db.delete(_db.dayMarks)..where((t) => t.questId.equals(id))).go();
    await (_db.update(
      _db.completions,
    )..where((t) => t.questId.equals(id))).write(const CompletionsCompanion(questId: Value(null)));
    await (_db.delete(_db.quests)..where((t) => t.id.equals(id))).go();
  });

  // --- Completions and day marks -------------------------------------------

  Stream<List<Completion>> watchCompletionsOn(String day) =>
      (_db.select(_db.completions)
            ..where((t) => t.day.equals(day))
            ..orderBy([(t) => OrderingTerm(expression: t.completedAt)]))
          .watch()
          .map((rows) => rows.map(completionFromRow).toList());

  Stream<List<Completion>> watchHistory({int limit = 300}) =>
      (_db.select(_db.completions)
            ..orderBy([(t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc)])
            ..limit(limit))
          .watch()
          .map((rows) => rows.map(completionFromRow).toList());

  /// Ids of quests that have been completed at least once.
  Stream<Set<String>> watchEverCompletedQuestIds() {
    final q = _db.selectOnly(_db.completions, distinct: true)
      ..addColumns([_db.completions.questId])
      ..where(_db.completions.questId.isNotNull());
    return q.watch().map((rows) => {for (final r in rows) r.read(_db.completions.questId)!});
  }

  Stream<Map<String, DayMarkKind>> watchDayMarks(String day) =>
      (_db.select(_db.dayMarks)..where((t) => t.day.equals(day))).watch().map(
        (rows) => {for (final r in rows) r.questId: DayMarkKind.values.byName(r.kind)},
      );

  Future<void> setDayMark(String questId, String day, DayMarkKind? kind) async {
    if (kind == null) {
      await (_db.delete(_db.dayMarks)..where((t) => t.questId.equals(questId) & t.day.equals(day))).go();
    } else {
      await _db
          .into(_db.dayMarks)
          .insertOnConflictUpdate(DayMarksCompanion.insert(questId: questId, day: day, kind: kind.name));
    }
  }

  String today() => dayKey(_clock.now());
}
