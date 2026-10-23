/// Source of "now". Game logic takes a [Clock] instead of calling
/// [DateTime.now] directly so tests can control time.
class Clock {
  const Clock();

  DateTime now() => DateTime.now();
}

/// A clock that only moves when told to. For tests.
class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void set(DateTime value) => _now = value;

  void advance(Duration by) => _now = _now.add(by);
}

/// The calendar day a moment falls on, as `yyyy-mm-dd` in local time.
/// Used as a stable key for "today" in the database.
String dayKey(DateTime t) {
  final local = t.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)}';
}
