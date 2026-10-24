import 'dart:convert';

import '../../core/clock.dart';
import '../db/app_database.dart';

class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Exports every table to JSON and restores it again. Also wipes all data.
class BackupService {
  BackupService(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  static const formatVersion = 1;

  Future<String> exportJson() async {
    final tables = <String, List<Map<String, Object?>>>{};
    for (final t in _db.allTables) {
      final rows = await _db.customSelect('SELECT * FROM "${t.actualTableName}"', readsFrom: {t}).get();
      tables[t.actualTableName] = [for (final r in rows) r.data];
    }
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'sprout',
      'format': formatVersion,
      'schema': _db.schemaVersion,
      'exportedAt': _clock.now().toIso8601String(),
      'tables': tables,
    });
  }

  /// Replaces all data with the backup in [json]. Nothing changes if the
  /// backup can't be read.
  Future<void> importJson(String json) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      throw const BackupException("That file doesn't look like a Sprout backup.");
    }
    if (decoded is! Map || decoded['app'] != 'sprout' || decoded['tables'] is! Map) {
      throw const BackupException("That file doesn't look like a Sprout backup.");
    }
    if ((decoded['format'] as num? ?? 0) > formatVersion) {
      throw const BackupException('This backup is from a newer version of Sprout. Please update the app first.');
    }
    final tables = decoded['tables'] as Map;
    await _db.transaction(() async {
      for (final t in _db.allTables) {
        await _db.customStatement('DELETE FROM "${t.actualTableName}"');
        final rows = tables[t.actualTableName];
        if (rows is! List) continue;
        final known = {for (final c in t.$columns) c.name};
        for (final row in rows.whereType<Map>()) {
          final entries = row.entries.where((e) => known.contains(e.key)).toList();
          if (entries.isEmpty) continue;
          final columns = entries.map((e) => '"${e.key}"').join(', ');
          final marks = List.filled(entries.length, '?').join(', ');
          await _db.customStatement('INSERT OR REPLACE INTO "${t.actualTableName}" ($columns) VALUES ($marks)', [
            for (final e in entries) e.value,
          ]);
        }
      }
    });
    _db.markTablesUpdated(_db.allTables);
  }

  /// Deletes everything. The app starts fresh, from onboarding.
  Future<void> deleteAll() async {
    await _db.transaction(() async {
      for (final t in _db.allTables) {
        await _db.customStatement('DELETE FROM "${t.actualTableName}"');
      }
    });
    _db.markTablesUpdated(_db.allTables);
  }
}
