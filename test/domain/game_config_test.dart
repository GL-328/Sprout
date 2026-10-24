import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/config/game_config.dart';
import 'package:sprout/domain/models/enums.dart';

void main() {
  late GameConfig config;

  setUpAll(() {
    config = GameConfig.parse(File('assets/config/game_config.yaml').readAsStringSync());
  });

  test('bundled game config is valid', () {
    expect(config.validate(), isEmpty);
  });

  test('core rules match the design', () {
    expect(config.questsPerSeed, 3);
    expect(config.maxCountedCompletionsPerDay, 9);
    expect(config.startingEnvironment.id, 'meadow');
    expect(config.startingEnvironment.slots, 3);
    expect(config.environments, hasLength(7));
    expect(config.species, hasLength(28));
  });

  test('every environment has four native species', () {
    for (final env in config.environments) {
      expect(config.speciesForEnvironment(env.id).length, greaterThanOrEqualTo(4), reason: env.id);
    }
  });

  test('every quest category maps to a family with all rarities', () {
    for (final c in QuestCategory.values) {
      final family = config.categoryFamilies[c]!;
      final rarities = config.speciesInFamily(family).map((s) => s.rarity).toSet();
      expect(rarities, containsAll(Rarity.values), reason: family);
    }
  });

  test('validation catches mistakes', () {
    final broken = File('assets/config/game_config.yaml')
        .readAsStringSync()
        .replaceFirst('environments: [meadow, orchard]', 'environments: [moon]')
        .replaceFirst('odds: { common: 1.0 }', 'odds: { common: 0.5 }');
    final problems = GameConfig.parse(broken).validate();
    expect(problems, contains(contains('unknown environment "moon"')));
    expect(problems, contains(contains('odds must add up to 1.0')));
  });
}
