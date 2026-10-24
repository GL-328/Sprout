import 'dart:math';

import '../../config/game_config.dart';
import '../models/enums.dart';

class RolledSeed {
  const RolledSeed(this.speciesId, this.rarity);

  final String speciesId;
  final Rarity rarity;
}

/// The quest facts the roller needs, oldest first.
typedef MeterQuest = ({QuestCategory category, Difficulty difficulty});

/// Decides which seed a filled meter gives.
class SeedRoller {
  SeedRoller(this.config, [Random? random]) : _random = random ?? Random();

  final GameConfig config;
  final Random _random;

  /// The most common category among [quests]. Ties go to whichever of the
  /// tied categories appeared most recently.
  QuestCategory dominantCategory(List<MeterQuest> quests) {
    assert(quests.isNotEmpty);
    final counts = <QuestCategory, int>{};
    final lastSeen = <QuestCategory, int>{};
    for (final (i, q) in quests.indexed) {
      counts[q.category] = (counts[q.category] ?? 0) + 1;
      lastSeen[q.category] = i;
    }
    final best = counts.values.reduce(max);
    return counts.keys.where((c) => counts[c] == best).reduce((a, b) => lastSeen[a]! > lastSeen[b]! ? a : b);
  }

  int difficultyPoints(List<MeterQuest> quests) =>
      quests.fold(0, (sum, q) => sum + (config.difficultyPoints[q.difficulty] ?? 1));

  /// Rarity odds for a total of [points].
  Map<Rarity, double> oddsFor(int points) {
    var tier = config.rarityTiers.first;
    for (final t in config.rarityTiers) {
      if (points >= t.minPoints) tier = t;
    }
    return tier.odds;
  }

  Rarity rollRarity(Map<Rarity, double> odds) {
    var roll = _random.nextDouble();
    for (final r in Rarity.values) {
      final p = odds[r] ?? 0;
      if (roll < p) return r;
      roll -= p;
    }
    return Rarity.values.lastWhere((r) => (odds[r] ?? 0) > 0, orElse: () => Rarity.common);
  }

  /// Picks a species of [familyId] with [rarity]. If the family has none of
  /// that rarity, steps down (rare, uncommon, common) until one exists.
  /// Species that fit an unlocked plot are more likely.
  RolledSeed pickSpecies(String familyId, Rarity rarity, Set<String> unlockedEnvironments) {
    final family = config.speciesInFamily(familyId).toList();
    var r = rarity;
    while (true) {
      final candidates = family.where((s) => s.rarity == r).toList();
      if (candidates.isNotEmpty) {
        final weights = [
          for (final s in candidates)
            s.environments.any(unlockedEnvironments.contains) ? config.unlockedEnvironmentBias : 1.0,
        ];
        var roll = _random.nextDouble() * weights.fold(0.0, (a, b) => a + b);
        for (final (i, s) in candidates.indexed) {
          if (roll < weights[i]) return RolledSeed(s.id, s.rarity);
          roll -= weights[i];
        }
        return RolledSeed(candidates.last.id, candidates.last.rarity);
      }
      if (r == Rarity.common) {
        final any = family.isNotEmpty ? family.first : config.species.values.first;
        return RolledSeed(any.id, any.rarity);
      }
      r = Rarity.values[r.index - 1];
    }
  }

  /// The seed earned by the quests that filled the meter.
  RolledSeed rollForQuests(List<MeterQuest> quests, Set<String> unlockedEnvironments) {
    final family = config.categoryFamilies[dominantCategory(quests)]!;
    final rarity = rollRarity(oddsFor(difficultyPoints(quests)));
    return pickSpecies(family, rarity, unlockedEnvironments);
  }

  /// A mystery pack seed: any species, rarity from the pack's odds.
  RolledSeed rollMystery(Map<Rarity, double> odds, Set<String> unlockedEnvironments) {
    final rarity = rollRarity(odds);
    final families = config.families.keys.toList();
    return pickSpecies(families[_random.nextInt(families.length)], rarity, unlockedEnvironments);
  }
}
