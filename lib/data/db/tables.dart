import 'package:drift/drift.dart';

/// Simple key/value store for preferences and small bits of app state.
@DataClassName('SettingRow')
class SettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Named whole-number counters: coins and lifetime stats.
@DataClassName('CounterRow')
class Counters extends Table {
  TextColumn get key => text()();
  IntColumn get value => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('QuestRow')
class Quests extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  TextColumn get difficulty => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get repeat => text()();

  /// Comma-separated ISO weekdays, e.g. "1,3,5".
  TextColumn get weekdays => text().withDefault(const Constant(''))();
  TextColumn get premadeKey => text().nullable()();
  BoolColumn get showOnToday => boolean().withDefault(const Constant(true))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  BoolColumn get reminderOn => boolean().withDefault(const Constant(false))();
  IntColumn get reminderMinutes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CompletionRow')
class Completions extends Table {
  TextColumn get id => text()();
  TextColumn get questId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  TextColumn get difficulty => text()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get day => text()();
  BoolColumn get counted => boolean()();
  TextColumn get seedId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// "Skip" or "do it later" for a quest on one day.
@DataClassName('DayMarkRow')
class DayMarks extends Table {
  TextColumn get questId => text()();
  TextColumn get day => text()();
  TextColumn get kind => text()();

  @override
  Set<Column> get primaryKey => {questId, day};
}

@DataClassName('SeedRow')
class Seeds extends Table {
  TextColumn get id => text()();
  TextColumn get speciesId => text()();
  TextColumn get rarity => text()();
  TextColumn get source => text()();
  DateTimeColumn get earnedAt => dateTime()();
  TextColumn get state => text().withDefault(const Constant('bag'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Unlocked garden plots.
@DataClassName('PlotRow')
class Plots extends Table {
  TextColumn get envId => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {envId};
}

/// Planted plants. Uprooted plants stay as keepsakes with [uprootedAt] set.
@DataClassName('PlantRow')
class Plants extends Table {
  TextColumn get id => text()();
  TextColumn get envId => text()();
  IntColumn get slot => integer()();
  TextColumn get speciesId => text()();
  TextColumn get rarity => text()();
  DateTimeColumn get plantedAt => dateTime()();

  /// When the current fruit timer started. Null until the plant first matures.
  DateTimeColumn get fruitAnchorAt => dateTime().nullable()();
  IntColumn get harvests => integer().withDefault(const Constant(0))();
  DateTimeColumn get uprootedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Fruit in the basket, keyed by species id.
@DataClassName('InventoryRow')
class Inventory extends Table {
  TextColumn get itemId => text()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {itemId};
}

@DataClassName('OwnedCosmeticRow')
class OwnedCosmetics extends Table {
  TextColumn get cosmeticId => text()();
  DateTimeColumn get boughtAt => dateTime()();

  @override
  Set<Column> get primaryKey => {cosmeticId};
}

/// Which cosmetic is placed in each plot, one per kind.
@DataClassName('PlotCosmeticRow')
class PlotCosmetics extends Table {
  TextColumn get envId => text()();
  TextColumn get kind => text()();
  TextColumn get cosmeticId => text()();

  @override
  Set<Column> get primaryKey => {envId, kind};
}

@DataClassName('VisitorSeenRow')
class VisitorsSeen extends Table {
  TextColumn get visitorId => text()();
  DateTimeColumn get firstSeenAt => dateTime()();
  IntColumn get timesSeen => integer().withDefault(const Constant(1))();
  IntColumn get timesFed => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {visitorId};
}

@DataClassName('MoodRow')
class Moods extends Table {
  TextColumn get day => text()();
  IntColumn get value => integer()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {day};
}

/// The user's own helpful contacts and resources.
@DataClassName('ContactRow')
class Contacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get detail => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
}

@DataClassName('RestDayRow')
class RestDays extends Table {
  TextColumn get day => text()();

  @override
  Set<Column> get primaryKey => {day};
}
