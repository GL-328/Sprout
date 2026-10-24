import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/config/game_config.dart';
import 'package:sprout/domain/logic/seasons.dart';
import 'package:sprout/domain/logic/streaks.dart';
import 'package:sprout/domain/logic/visitors.dart';

void main() {
  final config = GameConfig.parse(File('assets/config/game_config.yaml').readAsStringSync());

  test('seasons turn slowly from the unlock day', () {
    final start = DateTime(2026, 1, 1);
    Season at(int days) => seasonFor(
      unlockedAt: start,
      now: start.add(Duration(days: days)),
      daysPerSeason: 7,
    );
    expect(at(0), Season.spring);
    expect(at(6), Season.spring);
    expect(at(7), Season.summer);
    expect(at(21), Season.winter);
    expect(at(28), Season.spring);
  });

  test('gentle streak counts rest days and does not need today yet', () {
    final now = DateTime(2026, 3, 10, 9);
    expect(gentleStreak(activeDays: {'2026-03-09', '2026-03-08', '2026-03-07'}, now: now), 3);
    expect(gentleStreak(activeDays: {'2026-03-10', '2026-03-09'}, now: now), 2);
    expect(gentleStreak(activeDays: {'2026-03-07'}, now: now), 0);
    expect(gentleStreak(activeDays: const {}, now: now), 0);
  });

  test('visitors need the right plot, plants, streak and time', () {
    final frog = config.visitors['frog']!;
    final hedgehog = config.visitors['hedgehog']!;
    const pond = VisitorContext(envId: 'wetland', maturePlants: 1, streakDays: 0, isNight: false);
    expect(visitorEligible(frog, pond), isTrue);
    expect(
      visitorEligible(frog, const VisitorContext(envId: 'meadow', maturePlants: 3, streakDays: 9, isNight: false)),
      isFalse,
    );
    expect(
      visitorEligible(hedgehog, const VisitorContext(envId: 'meadow', maturePlants: 2, streakDays: 5, isNight: true)),
      isTrue,
    );
    expect(
      visitorEligible(hedgehog, const VisitorContext(envId: 'meadow', maturePlants: 2, streakDays: 5, isNight: false)),
      isFalse,
    );
    expect(
      visitorEligible(hedgehog, const VisitorContext(envId: 'meadow', maturePlants: 2, streakDays: 1, isNight: true)),
      isFalse,
    );
  });

  test('an empty garden has no visitors; a thriving one usually does', () {
    const empty = VisitorContext(envId: 'meadow', maturePlants: 0, streakDays: 0, isNight: false);
    expect(visitorsPresent(config, empty, 1), isEmpty);
    const thriving = VisitorContext(envId: 'meadow', maturePlants: 3, streakDays: 5, isNight: false);
    final counts = [for (var s = 0; s < 50; s++) visitorsPresent(config, thriving, s).length];
    expect(counts.where((c) => c > 0).length, greaterThan(40));
    expect(counts.every((c) => c <= 3), isTrue);
  });

  test('visitors stay put within a few hours', () {
    final a = visitorSeed('meadow', DateTime(2026, 1, 1, 9, 5));
    final b = visitorSeed('meadow', DateTime(2026, 1, 1, 10, 55));
    expect(a, b);
  });
}
