/// Core enums shared by game logic, storage and UI.
///
/// Each enum has a stable [id] that is stored in the database, used in the
/// game config file and in exported JSON. Never rename an id.
library;

enum QuestCategory {
  sleep('sleep', 'Sleep'),
  movement('movement', 'Movement'),
  mind('mind', 'Mind'),
  social('social', 'Social'),
  home('home', 'Home'),
  foodWater('food_water', 'Food and water'),
  studyWork('study_work', 'Study/Work');

  const QuestCategory(this.id, this.label);

  final String id;
  final String label;

  static QuestCategory fromId(String id) =>
      values.firstWhere((c) => c.id == id, orElse: () => throw FormatException('Unknown quest category "$id"'));
}

enum Difficulty {
  small('small', 'Small'),
  medium('medium', 'Medium'),
  big('big', 'Big');

  const Difficulty(this.id, this.label);

  final String id;
  final String label;

  static Difficulty fromId(String id) =>
      values.firstWhere((d) => d.id == id, orElse: () => throw FormatException('Unknown difficulty "$id"'));
}

enum Rarity {
  common('common', 'Common'),
  uncommon('uncommon', 'Uncommon'),
  rare('rare', 'Rare');

  const Rarity(this.id, this.label);

  final String id;
  final String label;

  static Rarity fromId(String id) =>
      values.firstWhere((r) => r.id == id, orElse: () => throw FormatException('Unknown rarity "$id"'));
}

/// Stages a plant moves through. After [mature] a plant never changes stage
/// again except to show [fruiting] while a harvest is waiting.
enum GrowthStage {
  seed('seed', 'Seed'),
  sprout('sprout', 'Sprout'),
  young('young', 'Young'),
  mature('mature', 'Mature'),
  fruiting('fruiting', 'Fruiting');

  const GrowthStage(this.id, this.label);

  final String id;
  final String label;
}

enum TimeOfDayKind {
  any('any'),
  day('day'),
  night('night');

  const TimeOfDayKind(this.id);

  final String id;

  static TimeOfDayKind fromId(String id) =>
      values.firstWhere((t) => t.id == id, orElse: () => throw FormatException('Unknown time_of_day "$id"'));
}
