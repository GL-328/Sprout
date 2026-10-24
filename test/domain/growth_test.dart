import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/config/game_config.dart';
import 'package:sprout/domain/logic/growth.dart';
import 'package:sprout/domain/models/enums.dart';

void main() {
  final config = GameConfig.parse(File('assets/config/game_config.yaml').readAsStringSync());
  final sunflower = config.speciesById('giant_sunflower'); // 20 + 60 + 150 min, fruit every 150 min, 3 stored
  final planted = DateTime(2026, 1, 1, 8);

  GrowthStatus at(Duration d, {DateTime? anchor}) =>
      Growth.status(sunflower, plantedAt: planted, fruitAnchor: anchor, now: planted.add(d));

  test('moves through the stages in real time', () {
    expect(at(Duration.zero).stage, GrowthStage.seed);
    expect(at(const Duration(minutes: 19)).stage, GrowthStage.seed);
    expect(at(const Duration(minutes: 20)).stage, GrowthStage.sprout);
    expect(at(const Duration(minutes: 80)).stage, GrowthStage.young);
    expect(at(const Duration(minutes: 230)).stage, GrowthStage.mature);
  });

  test('reports time left in the stage', () {
    expect(at(const Duration(minutes: 30)).untilNextStage, const Duration(minutes: 50));
    expect(at(const Duration(minutes: 230)).untilNextStage, isNull);
  });

  test('fruit becomes ready after the timer and builds up to the cap', () {
    expect(at(const Duration(minutes: 230 + 149)).readyHarvests, 0);
    expect(at(const Duration(minutes: 230 + 150)).readyHarvests, 1);
    expect(at(const Duration(minutes: 230 + 150)).stage, GrowthStage.fruiting);
    expect(at(const Duration(minutes: 230 + 310)).readyHarvests, 2);
    expect(at(const Duration(days: 30)).readyHarvests, 3, reason: 'capped, never wasted or wilted');
    expect(at(const Duration(days: 30)).untilNextHarvest, isNull);
  });

  test('harvesting collects everything and keeps partial progress', () {
    final now = planted.add(const Duration(minutes: 230 + 150 * 2 + 30));
    final h = Growth.harvest(sunflower, plantedAt: planted, now: now);
    expect(h.harvests, 2);
    expect(h.fruit, 2 * sunflower.fruit.perHarvest);
    final after = Growth.status(sunflower, plantedAt: planted, fruitAnchor: h.newAnchor, now: now);
    expect(after.readyHarvests, 0);
    expect(after.untilNextHarvest, const Duration(minutes: 120));
  });

  test('harvesting a full basket restarts the timer', () {
    final now = planted.add(const Duration(days: 5));
    final h = Growth.harvest(sunflower, plantedAt: planted, now: now);
    expect(h.harvests, 3);
    expect(h.newAnchor, now);
  });

  test('nothing to harvest before fruit is ready', () {
    final h = Growth.harvest(sunflower, plantedAt: planted, now: planted.add(const Duration(minutes: 10)));
    expect(h.fruit, 0);
  });

  test('rare plants take a day or more', () {
    for (final s in config.species.values.where((s) => s.rarity == Rarity.rare)) {
      expect(s.timeToMature, greaterThanOrEqualTo(const Duration(hours: 24)), reason: s.id);
    }
    for (final s in config.species.values.where((s) => s.rarity == Rarity.common)) {
      expect(s.timeToMature, lessThan(const Duration(hours: 8)), reason: s.id);
    }
  });

  test('friendly durations', () {
    expect(friendlyDuration(const Duration(seconds: 20)), 'under a minute');
    expect(friendlyDuration(const Duration(minutes: 45)), '45m');
    expect(friendlyDuration(const Duration(hours: 3, minutes: 20)), '3h 20m');
    expect(friendlyDuration(const Duration(days: 1, hours: 2)), '1d 2h');
  });
}
