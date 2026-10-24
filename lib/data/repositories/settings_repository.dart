import '../../domain/models/app_settings.dart';
import '../db/app_database.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<AppSettings> load() async {
    final rows = await _db.select(_db.settingsEntries).get();
    return AppSettings.fromEntries({for (final r in rows) r.key: r.value});
  }

  Stream<AppSettings> watch() => _db
      .select(_db.settingsEntries)
      .watch()
      .map((rows) => AppSettings.fromEntries({for (final r in rows) r.key: r.value}));

  Future<void> save(AppSettings settings) => _db.batch((b) {
    b.insertAllOnConflictUpdate(_db.settingsEntries, [
      for (final e in settings.toEntries().entries) SettingsEntriesCompanion.insert(key: e.key, value: e.value),
    ]);
  });

  Future<String?> readValue(String key) async {
    final row = await (_db.select(_db.settingsEntries)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeValue(String key, String value) =>
      _db.into(_db.settingsEntries).insertOnConflictUpdate(SettingsEntriesCompanion.insert(key: key, value: value));
}
