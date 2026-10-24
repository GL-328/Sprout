import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/domain/logic/friends.dart';
import 'package:sprout/domain/models/enums.dart';

void main() {
  test('friend codes are 8 characters without 0, O, 1 or I', () {
    final random = math.Random(1);
    for (var i = 0; i < 200; i++) {
      final code = generateFriendCode(random);
      expect(code.length, 8);
      expect(code, isNot(matches(RegExp('[01OI]'))));
      expect(normalizeFriendCode(code), code);
    }
  });

  test('typed codes are tidied, and wrong ones rejected', () {
    expect(normalizeFriendCode(' abcd-efgh '), 'ABCDEFGH');
    expect(normalizeFriendCode('ABCD EFGH'), 'ABCDEFGH');
    expect(normalizeFriendCode('ABCDEFG'), isNull, reason: 'too short');
    expect(normalizeFriendCode('ABCDEFGO'), isNull, reason: 'O is never used');
    expect(normalizeFriendCode('ABCDEFG1'), isNull, reason: '1 is never used');
    expect(formatFriendCode('ABCDEFGH'), 'ABCD-EFGH');
  });

  test('display names are checked gently', () {
    expect(checkDisplayName('  Robin  ').name, 'Robin');
    expect(checkDisplayName('Mary   Jo').name, 'Mary Jo');
    expect(checkDisplayName('').problem, isNotNull);
    expect(checkDisplayName('A' * 21).problem, isNotNull);
    expect(checkDisplayName('<script>').problem, isNotNull);
    expect(checkDisplayName('you idiot').problem, isNotNull);
    expect(checkDisplayName('Zoë').name, 'Zoë');
  });

  test('a visit has one id per friend per day', () {
    expect(visitId('u1', DateTime(2026, 3, 4, 9)), 'u1_20260304');
    expect(visitId('u1', DateTime(2026, 3, 4, 23)), visitId('u1', DateTime(2026, 3, 4, 1)));
    expect(visitId('u1', DateTime(2026, 3, 5)), isNot(visitId('u1', DateTime(2026, 3, 4))));
  });

  test('the garden snapshot round-trips and holds nothing else', () {
    const snapshot = GardenSnapshot([
      SnapshotPlot(
        env: 'meadow',
        slots: [SnapshotSlot(slot: 0, species: 'apple_tree', stage: GrowthStage.fruiting)],
        decor: {'bench': 'wooden_bench'},
      ),
    ]);
    final json = snapshot.toJson();
    expect(json.keys, ['plots']);
    expect((json['plots']! as List).single, {
      'env': 'meadow',
      'slots': [
        {'slot': 0, 'species': 'apple_tree', 'stage': 'fruiting'},
      ],
      'decor': {'bench': 'wooden_bench'},
    });
    final back = GardenSnapshot.fromJson(json);
    expect(back.plots.single.slots.single.stage, GrowthStage.fruiting);
  });

  test('broken or oversized snapshots are read safely', () {
    expect(GardenSnapshot.fromJson(null).plots, isEmpty);
    expect(GardenSnapshot.fromJson({'plots': 'nope'}).plots, isEmpty);
    final big = {
      'plots': [
        for (var i = 0; i < 50; i++) {'env': 'meadow', 'slots': [], 'decor': {}},
      ],
    };
    expect(GardenSnapshot.fromJson(big).plots.length, 12);
    final odd = GardenSnapshot.fromJson({
      'plots': [
        {
          'env': 'meadow',
          'slots': [
            {'slot': 'x', 'species': 1},
            {'slot': 1, 'species': 'oak', 'stage': 'young'},
          ],
        },
      ],
    });
    expect(odd.plots.single.slots.single.species, 'oak');
  });
}
