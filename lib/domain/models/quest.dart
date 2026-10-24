import 'enums.dart';

enum RepeatKind {
  once('once', 'Just once'),
  daily('daily', 'Every day'),
  weekdays('weekdays', 'Some days');

  const RepeatKind(this.id, this.label);

  final String id;
  final String label;

  static RepeatKind fromId(String id) => values.firstWhere((r) => r.id == id, orElse: () => RepeatKind.daily);
}

/// A self-care quest on the user's own list.
class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    this.notes = '',
    this.repeat = RepeatKind.daily,
    this.weekdays = const {},
    this.premadeKey,
    this.showOnToday = true,
    this.archived = false,
    this.reminderOn = false,
    this.reminderMinutes,
    required this.createdAt,
  });

  final String id;
  final String title;
  final QuestCategory category;
  final Difficulty difficulty;
  final String notes;
  final RepeatKind repeat;

  /// ISO weekdays (1 = Monday ... 7 = Sunday). Used when [repeat] is weekdays.
  final Set<int> weekdays;

  /// Set when the quest came from the premade library.
  final String? premadeKey;

  /// Whether the quest appears on the Today screen.
  final bool showOnToday;
  final bool archived;
  final bool reminderOn;

  /// Reminder time in minutes after midnight.
  final int? reminderMinutes;
  final DateTime createdAt;

  Quest copyWith({
    String? title,
    QuestCategory? category,
    Difficulty? difficulty,
    String? notes,
    RepeatKind? repeat,
    Set<int>? weekdays,
    bool? showOnToday,
    bool? archived,
    bool? reminderOn,
    int? Function()? reminderMinutes,
  }) => Quest(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    notes: notes ?? this.notes,
    repeat: repeat ?? this.repeat,
    weekdays: weekdays ?? this.weekdays,
    premadeKey: premadeKey,
    showOnToday: showOnToday ?? this.showOnToday,
    archived: archived ?? this.archived,
    reminderOn: reminderOn ?? this.reminderOn,
    reminderMinutes: reminderMinutes != null ? reminderMinutes() : this.reminderMinutes,
    createdAt: createdAt,
  );
}

/// A finished quest, kept for history and the Seed Meter.
class Completion {
  const Completion({
    required this.id,
    required this.questId,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.completedAt,
    required this.day,
    required this.counted,
    this.seedId,
  });

  final String id;
  final String? questId;

  /// Snapshot of the quest at completion time, so history survives edits.
  final String title;
  final QuestCategory category;
  final Difficulty difficulty;
  final DateTime completedAt;

  /// Local calendar day, `yyyy-mm-dd`.
  final String day;

  /// Whether this completion filled a dot on the Seed Meter.
  final bool counted;

  /// The seed this completion helped earn, once its meter cycle closed.
  final String? seedId;
}

/// Per-day markers for a quest on the Today screen.
enum DayMarkKind { skip, later }
