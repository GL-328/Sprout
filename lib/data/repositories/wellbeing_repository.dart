import 'package:drift/drift.dart';

import '../../core/clock.dart';
import '../db/app_database.dart';

class MoodEntry {
  const MoodEntry({required this.day, required this.value, required this.note});

  final String day;

  /// 1 (having a hard time) to 5 (great).
  final int value;
  final String note;
}

class HelpContact {
  const HelpContact({required this.id, required this.name, required this.detail, required this.note});

  final int id;
  final String name;
  final String detail;
  final String note;
}

/// Moods, rest days and the user's own helpful contacts.
class WellbeingRepository {
  WellbeingRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  MoodEntry _mood(MoodRow r) => MoodEntry(day: r.day, value: r.value, note: r.note);

  Stream<MoodEntry?> watchMood(String day) => (_db.select(
    _db.moods,
  )..where((t) => t.day.equals(day))).watchSingleOrNull().map((r) => r == null ? null : _mood(r));

  Stream<Map<String, MoodEntry>> watchMoods() =>
      _db.select(_db.moods).watch().map((rows) => {for (final r in rows) r.day: _mood(r)});

  Future<void> setMood(String day, int value, String note) => _db
      .into(_db.moods)
      .insertOnConflictUpdate(
        MoodsCompanion.insert(day: day, value: value, note: Value(note), createdAt: _clock.now()),
      );

  Future<void> clearMood(String day) => (_db.delete(_db.moods)..where((t) => t.day.equals(day))).go();

  Stream<Set<String>> watchRestDays() => _db.select(_db.restDays).watch().map((rows) => {for (final r in rows) r.day});

  Future<void> setRestDay(String day, bool rest) async {
    if (rest) {
      await _db.into(_db.restDays).insert(RestDaysCompanion.insert(day: day), mode: InsertMode.insertOrIgnore);
    } else {
      await (_db.delete(_db.restDays)..where((t) => t.day.equals(day))).go();
    }
  }

  /// Days with at least one completed quest or a rest day.
  Stream<Set<String>> watchActiveDays() {
    final q = _db.selectOnly(_db.completions, distinct: true)..addColumns([_db.completions.day]);
    return q.watch().asyncMap((rows) async {
      final rest = {for (final r in await _db.select(_db.restDays).get()) r.day};
      return {for (final r in rows) r.read(_db.completions.day)!, ...rest};
    });
  }

  Stream<List<HelpContact>> watchContacts() => _db
      .select(_db.contacts)
      .watch()
      .map((rows) => [for (final r in rows) HelpContact(id: r.id, name: r.name, detail: r.detail, note: r.note)]);

  Future<void> addContact(String name, String detail, String note) =>
      _db.into(_db.contacts).insert(ContactsCompanion.insert(name: name, detail: Value(detail), note: Value(note)));

  Future<void> updateContact(HelpContact c) => (_db.update(_db.contacts)..where((t) => t.id.equals(c.id))).write(
    ContactsCompanion(name: Value(c.name), detail: Value(c.detail), note: Value(c.note)),
  );

  Future<void> deleteContact(int id) => (_db.delete(_db.contacts)..where((t) => t.id.equals(id))).go();

  String today() => dayKey(_clock.now());
}
