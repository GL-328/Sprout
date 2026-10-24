import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/domain/logic/ben.dart';

void main() {
  final raw = jsonDecode(File('assets/content/ben_lines.json').readAsStringSync()) as Map<String, dynamic>;
  final lines = BenLines.fromJson(raw);

  test('every line has a known type and is short', () {
    const known = {'fact', 'greeting', 'tip', 'encourage', 'buy', 'sell', 'compost', 'unlock', 'no_coins'};
    for (final l in (raw['lines'] as List).cast<Map>()) {
      expect(known, contains(l['type']), reason: '$l');
      expect((l['text'] as String).length, lessThanOrEqualTo(110), reason: l['text'] as String);
    }
  });

  test('there is plenty to say', () {
    expect(lines.of(BenLineType.fact).length, greaterThanOrEqualTo(110));
    expect(lines.of(BenLineType.greeting).length, greaterThanOrEqualTo(35));
    expect(lines.of(BenLineType.encourage).length, greaterThanOrEqualTo(18));
    for (final t in [BenLineType.buy, BenLineType.sell, BenLineType.compost, BenLineType.unlock, BenLineType.noCoins]) {
      expect(lines.of(t), isNotEmpty, reason: '$t');
    }
  });

  test('no lines are repeated', () {
    final all = [for (final l in (raw['lines'] as List).cast<Map>()) l['text']];
    expect(all.toSet().length, all.length);
  });

  test('Ben never pressures anyone', () {
    final banned = RegExp(
      r'buy now|(?<!no )hurry|limited time|last chance|don.t miss|only today|you should buy',
      caseSensitive: false,
    );
    for (final l in (raw['lines'] as List).cast<Map>()) {
      expect(banned.hasMatch(l['text'] as String), isFalse, reason: l['text'] as String);
    }
  });

  test('fact of the day is stable all day and changes the next day', () {
    final morning = lines.factOfTheDay(DateTime(2026, 5, 1, 7));
    final night = lines.factOfTheDay(DateTime(2026, 5, 1, 23, 59));
    final tomorrow = lines.factOfTheDay(DateTime(2026, 5, 2, 0, 1));
    expect(morning, night);
    expect(tomorrow, isNot(morning));
  });

  test('tapping Ben never repeats the same line twice in a row', () {
    final random = Random(1);
    String? previous;
    for (var i = 0; i < 300; i++) {
      final next = lines.chat(random, previous: previous);
      expect(next, isNot(previous));
      previous = next;
    }
  });
}
