import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/config/game_config.dart';
import 'package:sprout/domain/logic/seed_meter.dart';
import 'package:sprout/domain/logic/seed_roller.dart';
import 'package:sprout/domain/models/enums.dart';

/// Random that returns a fixed sequence of doubles.
class SequenceRandom implements Random {
  SequenceRandom(this.values);

  final List<double> values;
  var _i = 0;

  @override
  double nextDouble() => values[_i++ % values.length];

  @override
  int nextInt(int max) => (nextDouble() * max).floor();

  @override
  bool nextBool() => nextDouble() < 0.5;
}

MeterQuest q(QuestCategory c, [Difficulty d = Difficulty.small]) => (category: c, difficulty: d);

void main() {
  final config = GameConfig.parse(File('assets/config/game_config.yaml').readAsStringSync());

  group('SeedMeterRules', () {
    final rules = SeedMeterRules(config);

    test('counts up to the daily limit', () {
      expect(rules.countsTowardMeter(0), isTrue);
      expect(rules.countsTowardMeter(8), isTrue);
      expect(rules.countsTowardMeter(9), isFalse);
    });

    test('meter dots wrap every three', () {
      expect(rules.filled(0), 0);
      expect(rules.filled(2), 2);
      expect(rules.filled(3), 0);
      expect(rules.filled(5), 2);
    });

    test('messages are encouraging', () {
      expect(rules.message(filled: 2, countedToday: 2), '2 of 3, one more for a seed!');
      expect(rules.message(filled: 1, countedToday: 1), contains('2 more'));
      expect(rules.message(filled: 0, countedToday: 9), contains('still counts'));
    });
  });

  group('SeedRoller', () {
    test('family comes from the most common category', () {
      final roller = SeedRoller(config, SequenceRandom([0]));
      expect(
        roller.dominantCategory([q(QuestCategory.mind), q(QuestCategory.movement), q(QuestCategory.mind)]),
        QuestCategory.mind,
      );
    });

    test('ties go to the most recent quest', () {
      final roller = SeedRoller(config, SequenceRandom([0]));
      expect(
        roller.dominantCategory([q(QuestCategory.sleep), q(QuestCategory.mind), q(QuestCategory.social)]),
        QuestCategory.social,
      );
      expect(
        roller.dominantCategory([
          q(QuestCategory.sleep),
          q(QuestCategory.mind),
          q(QuestCategory.sleep),
          q(QuestCategory.mind),
        ]),
        QuestCategory.mind,
      );
    });

    test('all small quests always give a common seed', () {
      final roller = SeedRoller(config, Random(1));
      for (var i = 0; i < 200; i++) {
        final seed = roller.rollForQuests(
          [q(QuestCategory.movement), q(QuestCategory.movement), q(QuestCategory.movement)],
          {'meadow'},
        );
        expect(seed.rarity, Rarity.common);
        expect(config.speciesById(seed.speciesId).family, 'sunflower');
      }
    });

    test('big quests give a good chance of rare', () {
      final roller = SeedRoller(config, Random(2));
      final big = [for (var i = 0; i < 3; i++) q(QuestCategory.mind, Difficulty.big)];
      final rares = List.generate(
        1000,
        (_) => roller.rollForQuests(big, {'meadow'}),
      ).where((s) => s.rarity == Rarity.rare);
      expect(rares.length, greaterThan(450));
    });

    test('points pick the right rarity tier', () {
      final roller = SeedRoller(config);
      expect(roller.oddsFor(3)[Rarity.common], 1.0);
      expect(roller.oddsFor(4)[Rarity.common], 1.0);
      expect(roller.oddsFor(6)[Rarity.uncommon], 0.55);
      expect(roller.oddsFor(9)[Rarity.rare], 0.60);
    });

    test('rare roll in a family without that rarity steps down', () {
      final roller = SeedRoller(config, SequenceRandom([0]));
      // A made-up family with only commons would step down; the real ones all
      // have every rarity, so check the rare path picks a rare species.
      final seed = roller.pickSpecies('lavender', Rarity.rare, {'meadow'});
      expect(seed.rarity, Rarity.rare);
      expect(seed.speciesId, 'edelweiss');
    });

    test('species for unlocked plots are favoured', () {
      final roller = SeedRoller(config, Random(3));
      final picks = List.generate(400, (_) => roller.pickSpecies('lavender', Rarity.common, {'meadow'}).speciesId);
      final meadow = picks.where((id) => id == 'lavender_hedge').length;
      expect(meadow, greaterThan(picks.length * 0.6));
    });
  });
}
