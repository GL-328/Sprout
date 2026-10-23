import 'package:drift/drift.dart';

/// Simple key/value store for preferences and small bits of app state.
class SettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
