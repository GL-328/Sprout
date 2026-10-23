import 'package:yaml/yaml.dart';

import '../domain/models/enums.dart';

/// Typed view of `assets/config/game_config.yaml`.
///
/// Pure Dart: parse with [GameConfig.parse], then call [validate] to get a
/// list of human-readable problems (empty when the file is fine).
class GameConfig {
  const GameConfig({
    required this.questsPerSeed,
    required this.maxCountedCompletionsPerDay,
    required this.undoSeconds,
    required this.difficultyPoints,
    required this.rarityTiers,
    required this.unlockedEnvironmentBias,
    required this.categoryFamilies,
    required this.families,
    required this.seedBagCap,
    required this.compostCoins,
    required this.environments,
    required this.species,
    required this.visitors,
    required this.daysPerSeason,
    required this.cosmetics,
    required this.mysteryPacks,
    required this.recipes,
    required this.starterSeed,
  });

  final int questsPerSeed;
  final int maxCountedCompletionsPerDay;
  final int undoSeconds;
  final Map<Difficulty, int> difficultyPoints;

  /// Sorted by ascending [RarityTier.minPoints].
  final List<RarityTier> rarityTiers;
  final double unlockedEnvironmentBias;
  final Map<QuestCategory, String> categoryFamilies;
  final Map<String, FamilyConfig> families;
  final int seedBagCap;
  final Map<Rarity, int> compostCoins;

  /// In unlock order. The first is the free starting plot.
  final List<EnvironmentConfig> environments;
  final Map<String, SpeciesConfig> species;
  final Map<String, VisitorConfig> visitors;
  final int daysPerSeason;
  final Map<String, CosmeticConfig> cosmetics;
  final Map<String, MysteryPackConfig> mysteryPacks;
  final Map<String, RecipeConfig> recipes;
  final String starterSeed;

  EnvironmentConfig get startingEnvironment => environments.first;

  EnvironmentConfig environment(String id) => environments.firstWhere((e) => e.id == id);

  SpeciesConfig speciesById(String id) {
    final s = species[id];
    if (s == null) throw ArgumentError('Unknown species "$id"');
    return s;
  }

  Iterable<SpeciesConfig> speciesInFamily(String familyId) => species.values.where((s) => s.family == familyId);

  Iterable<SpeciesConfig> speciesForEnvironment(String envId) =>
      species.values.where((s) => s.environments.contains(envId));

  static GameConfig parse(String yamlSource) {
    final root = _map(loadYaml(yamlSource), 'root');
    final quests = _map(root['quests'], 'quests');
    final seedBag = _map(root['seed_bag'], 'seed_bag');

    final envMap = _map(root['environments'], 'environments');
    final environments = <EnvironmentConfig>[
      for (final e in envMap.entries)
        EnvironmentConfig._fromYaml(e.key as String, _map(e.value, 'environments.${e.key}')),
    ];

    final tiers = [
      for (final (i, t) in _list(root['rarity_tiers'], 'rarity_tiers').indexed)
        RarityTier._fromYaml(_map(t, 'rarity_tiers[$i]')),
    ]..sort((a, b) => a.minPoints.compareTo(b.minPoints));

    return GameConfig(
      questsPerSeed: _int(quests['quests_per_seed'], 'quests.quests_per_seed'),
      maxCountedCompletionsPerDay: _int(
        quests['max_counted_completions_per_day'],
        'quests.max_counted_completions_per_day',
      ),
      undoSeconds: _int(quests['undo_seconds'], 'quests.undo_seconds'),
      difficultyPoints: {
        for (final e in _map(quests['difficulty_points'], 'quests.difficulty_points').entries)
          Difficulty.fromId(e.key as String): _int(e.value, 'difficulty_points.${e.key}'),
      },
      rarityTiers: tiers,
      unlockedEnvironmentBias: _double(root['unlocked_environment_bias'], 'unlocked_environment_bias'),
      categoryFamilies: {
        for (final e in _map(root['category_families'], 'category_families').entries)
          QuestCategory.fromId(e.key as String): e.value as String,
      },
      families: {
        for (final e in _map(root['families'], 'families').entries)
          e.key as String: FamilyConfig._fromYaml(e.key as String, _map(e.value, 'families.${e.key}')),
      },
      seedBagCap: _int(seedBag['cap'], 'seed_bag.cap'),
      compostCoins: _rarityIntMap(seedBag['compost_coins'], 'seed_bag.compost_coins'),
      environments: environments,
      species: {
        for (final e in _map(root['species'], 'species').entries)
          e.key as String: SpeciesConfig._fromYaml(e.key as String, _map(e.value, 'species.${e.key}')),
      },
      visitors: {
        for (final e in _map(root['visitors'], 'visitors').entries)
          e.key as String: VisitorConfig._fromYaml(e.key as String, _map(e.value, 'visitors.${e.key}')),
      },
      daysPerSeason: _int(_map(root['seasons'], 'seasons')['days_per_season'], 'seasons.days_per_season'),
      cosmetics: {
        for (final e in _map(root['cosmetics'], 'cosmetics').entries)
          e.key as String: CosmeticConfig._fromYaml(e.key as String, _map(e.value, 'cosmetics.${e.key}')),
      },
      mysteryPacks: {
        for (final e in _map(root['mystery_packs'], 'mystery_packs').entries)
          e.key as String: MysteryPackConfig._fromYaml(e.key as String, _map(e.value, 'mystery_packs.${e.key}')),
      },
      recipes: {
        for (final e in _map(root['recipes'], 'recipes').entries)
          e.key as String: RecipeConfig._fromYaml(e.key as String, _map(e.value, 'recipes.${e.key}')),
      },
      starterSeed: root['starter_seed'] as String,
    );
  }

  /// Checks that the rules make sense together. Returns an empty list if so.
  List<String> validate() {
    final problems = <String>[];
    void check(bool ok, String message) {
      if (!ok) problems.add(message);
    }

    final envIds = environments.map((e) => e.id).toSet();

    check(questsPerSeed > 0, 'quests_per_seed must be at least 1');
    check(
      maxCountedCompletionsPerDay >= questsPerSeed,
      'max_counted_completions_per_day should be at least quests_per_seed',
    );
    check(undoSeconds > 0, 'undo_seconds must be positive');
    for (final d in Difficulty.values) {
      check(difficultyPoints.containsKey(d), 'difficulty_points is missing "${d.id}"');
    }

    check(rarityTiers.isNotEmpty, 'rarity_tiers needs at least one tier');
    final minPossible = questsPerSeed * (difficultyPoints[Difficulty.small] ?? 1);
    check(
      rarityTiers.isNotEmpty && rarityTiers.first.minPoints <= minPossible,
      'the lowest rarity tier must start at or below $minPossible points',
    );
    for (final t in rarityTiers) {
      check(_oddsSumToOne(t.odds.values), 'rarity tier ${t.minPoints}: odds must add up to 1.0');
    }

    for (final c in QuestCategory.values) {
      final family = categoryFamilies[c];
      check(family != null, 'category_families is missing "${c.id}"');
      if (family != null) {
        check(families.containsKey(family), 'category "${c.id}" points to unknown family "$family"');
        check(
          speciesInFamily(family).any((s) => s.rarity == Rarity.common),
          'family "$family" needs at least one common species',
        );
      }
    }

    for (final r in Rarity.values) {
      check(compostCoins.containsKey(r), 'seed_bag.compost_coins is missing "${r.id}"');
    }
    check(seedBagCap > 0, 'seed_bag.cap must be positive');

    check(environments.isNotEmpty, 'at least one environment is needed');
    if (environments.isNotEmpty) {
      check(environments.first.price == 0, 'the first environment must be free (price: 0)');
    }
    for (var i = 1; i < environments.length; i++) {
      check(
        environments[i].price >= environments[i - 1].price,
        'environment prices should rise: "${environments[i].id}" is cheaper than the one before',
      );
    }
    for (final e in environments) {
      check(e.slots > 0, 'environment "${e.id}" needs at least one slot');
      check(speciesForEnvironment(e.id).isNotEmpty, 'nothing can grow in environment "${e.id}"');
    }

    for (final s in species.values) {
      check(families.containsKey(s.family), 'species "${s.id}" has unknown family "${s.family}"');
      check(s.environments.isNotEmpty, 'species "${s.id}" needs at least one environment');
      for (final env in s.environments) {
        check(envIds.contains(env), 'species "${s.id}" lists unknown environment "$env"');
      }
      check(s.growthMinutes.values.every((m) => m > 0), 'species "${s.id}" growth times must be positive');
      check(s.fruit.timerMinutes > 0, 'species "${s.id}" fruit timer must be positive');
      check(s.fruit.perHarvest > 0, 'species "${s.id}" per_harvest must be positive');
      check(s.fruit.maxStoredHarvests > 0, 'species "${s.id}" max_stored_harvests must be positive');
      check(s.fruit.sellPrice >= 0, 'species "${s.id}" sell_price cannot be negative');
    }

    for (final v in visitors.values) {
      for (final env in v.environments) {
        check(envIds.contains(env), 'visitor "${v.id}" lists unknown environment "$env"');
      }
      check(v.chance > 0 && v.chance <= 1, 'visitor "${v.id}" chance must be between 0 and 1');
      check(
        species.containsKey(v.favouriteFruit),
        'visitor "${v.id}" favourite_fruit "${v.favouriteFruit}" is not a species',
      );
    }

    check(daysPerSeason > 0, 'seasons.days_per_season must be positive');

    for (final c in cosmetics.values) {
      check(c.price >= 0, 'cosmetic "${c.id}" price cannot be negative');
    }
    for (final p in mysteryPacks.values) {
      check(_oddsSumToOne(p.odds.values), 'mystery pack "${p.id}" odds must add up to 1.0');
      check(p.seeds > 0, 'mystery pack "${p.id}" must give at least one seed');
    }
    for (final r in recipes.values) {
      check(r.ingredients.isNotEmpty, 'recipe "${r.id}" needs ingredients');
      for (final i in r.ingredients.keys) {
        check(species.containsKey(i), 'recipe "${r.id}" uses unknown fruit "$i"');
      }
    }

    check(species.containsKey(starterSeed), 'starter_seed "$starterSeed" is not a species');
    if (species.containsKey(starterSeed) && environments.isNotEmpty) {
      check(
        species[starterSeed]!.environments.contains(environments.first.id),
        'starter_seed must be able to grow in the first environment',
      );
    }
    return problems;
  }
}

class RarityTier {
  const RarityTier({required this.minPoints, required this.odds});

  factory RarityTier._fromYaml(Map y) => RarityTier(
    minPoints: _int(y['min_points'], 'rarity_tiers.min_points'),
    odds: _rarityDoubleMap(y['odds'], 'rarity_tiers.odds'),
  );

  final int minPoints;
  final Map<Rarity, double> odds;
}

class FamilyConfig {
  const FamilyConfig({required this.id, required this.name, required this.emoji});

  factory FamilyConfig._fromYaml(String id, Map y) =>
      FamilyConfig(id: id, name: y['name'] as String, emoji: y['emoji'] as String);

  final String id;
  final String name;
  final String emoji;
}

class EnvironmentConfig {
  const EnvironmentConfig({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.slots,
    required this.description,
  });

  factory EnvironmentConfig._fromYaml(String id, Map y) => EnvironmentConfig(
    id: id,
    name: y['name'] as String,
    emoji: y['emoji'] as String,
    price: _int(y['price'], 'environments.$id.price'),
    slots: _int(y['slots'], 'environments.$id.slots'),
    description: y['description'] as String? ?? '',
  );

  final String id;
  final String name;
  final String emoji;
  final int price;
  final int slots;
  final String description;
}

class FruitConfig {
  const FruitConfig({
    required this.name,
    required this.emoji,
    required this.timerMinutes,
    required this.perHarvest,
    required this.maxStoredHarvests,
    required this.sellPrice,
  });

  factory FruitConfig._fromYaml(String speciesId, Map y) => FruitConfig(
    name: y['name'] as String,
    emoji: y['emoji'] as String,
    timerMinutes: _int(y['timer_minutes'], 'species.$speciesId.fruit.timer_minutes'),
    perHarvest: _int(y['per_harvest'], 'species.$speciesId.fruit.per_harvest'),
    maxStoredHarvests: _int(y['max_stored_harvests'], 'species.$speciesId.fruit.max_stored_harvests'),
    sellPrice: _int(y['sell_price'], 'species.$speciesId.fruit.sell_price'),
  );

  final String name;
  final String emoji;
  final int timerMinutes;
  final int perHarvest;
  final int maxStoredHarvests;
  final int sellPrice;

  Duration get timer => Duration(minutes: timerMinutes);
}

class SpeciesConfig {
  const SpeciesConfig({
    required this.id,
    required this.name,
    required this.family,
    required this.rarity,
    required this.environments,
    required this.growthMinutes,
    required this.fruit,
  });

  factory SpeciesConfig._fromYaml(String id, Map y) {
    final growth = _map(y['growth_minutes'], 'species.$id.growth_minutes');
    return SpeciesConfig(
      id: id,
      name: y['name'] as String,
      family: y['family'] as String,
      rarity: Rarity.fromId(y['rarity'] as String),
      environments: [for (final e in _list(y['environments'], 'species.$id.environments')) e as String],
      growthMinutes: {
        GrowthStage.seed: _int(growth['seed'], 'species.$id.growth_minutes.seed'),
        GrowthStage.sprout: _int(growth['sprout'], 'species.$id.growth_minutes.sprout'),
        GrowthStage.young: _int(growth['young'], 'species.$id.growth_minutes.young'),
      },
      fruit: FruitConfig._fromYaml(id, _map(y['fruit'], 'species.$id.fruit')),
    );
  }

  final String id;
  final String name;
  final String family;
  final Rarity rarity;
  final List<String> environments;

  /// Minutes spent in seed, sprout and young before moving on.
  final Map<GrowthStage, int> growthMinutes;
  final FruitConfig fruit;

  Duration stageDuration(GrowthStage stage) => Duration(minutes: growthMinutes[stage] ?? 0);

  /// Time from planting until the plant is mature.
  Duration get timeToMature => Duration(minutes: growthMinutes.values.fold(0, (sum, m) => sum + m));
}

class VisitorConfig {
  const VisitorConfig({
    required this.id,
    required this.name,
    required this.emoji,
    required this.environments,
    required this.minMaturePlants,
    required this.minStreakDays,
    required this.timeOfDay,
    required this.chance,
    required this.favouriteFruit,
    required this.thanksCoins,
  });

  factory VisitorConfig._fromYaml(String id, Map y) => VisitorConfig(
    id: id,
    name: y['name'] as String,
    emoji: y['emoji'] as String,
    environments: [for (final e in _list(y['environments'], 'visitors.$id.environments')) e as String],
    minMaturePlants: _int(y['min_mature_plants'], 'visitors.$id.min_mature_plants'),
    minStreakDays: _int(y['min_streak_days'], 'visitors.$id.min_streak_days'),
    timeOfDay: TimeOfDayKind.fromId(y['time_of_day'] as String),
    chance: _double(y['chance'], 'visitors.$id.chance'),
    favouriteFruit: y['favourite_fruit'] as String,
    thanksCoins: _int(y['thanks_coins'], 'visitors.$id.thanks_coins'),
  );

  final String id;
  final String name;
  final String emoji;

  /// Empty means any environment.
  final List<String> environments;
  final int minMaturePlants;
  final int minStreakDays;
  final TimeOfDayKind timeOfDay;
  final double chance;
  final String favouriteFruit;
  final int thanksCoins;
}

class CosmeticConfig {
  const CosmeticConfig({
    required this.id,
    required this.name,
    required this.emoji,
    required this.kind,
    required this.price,
  });

  factory CosmeticConfig._fromYaml(String id, Map y) => CosmeticConfig(
    id: id,
    name: y['name'] as String,
    emoji: y['emoji'] as String,
    kind: y['kind'] as String,
    price: _int(y['price'], 'cosmetics.$id.price'),
  );

  final String id;
  final String name;
  final String emoji;
  final String kind;
  final int price;
}

class MysteryPackConfig {
  const MysteryPackConfig({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.seeds,
    required this.odds,
  });

  factory MysteryPackConfig._fromYaml(String id, Map y) => MysteryPackConfig(
    id: id,
    name: y['name'] as String,
    emoji: y['emoji'] as String,
    price: _int(y['price'], 'mystery_packs.$id.price'),
    seeds: _int(y['seeds'], 'mystery_packs.$id.seeds'),
    odds: _rarityDoubleMap(y['odds'], 'mystery_packs.$id.odds'),
  );

  final String id;
  final String name;
  final String emoji;
  final int price;
  final int seeds;
  final Map<Rarity, double> odds;
}

class RecipeConfig {
  const RecipeConfig({
    required this.id,
    required this.name,
    required this.emoji,
    required this.ingredients,
    required this.effect,
  });

  factory RecipeConfig._fromYaml(String id, Map y) => RecipeConfig(
    id: id,
    name: y['name'] as String,
    emoji: y['emoji'] as String,
    ingredients: {
      for (final e in _map(y['ingredients'], 'recipes.$id.ingredients').entries)
        e.key as String: _int(e.value, 'recipes.$id.ingredients.${e.key}'),
    },
    effect: RecipeEffect._fromYaml(_map(y['effect'], 'recipes.$id.effect')),
  );

  final String id;
  final String name;
  final String emoji;

  /// Species id (its fruit) to quantity.
  final Map<String, int> ingredients;
  final RecipeEffect effect;
}

enum RecipeEffectType { coins, growthBoost, visitorLure }

class RecipeEffect {
  const RecipeEffect({required this.type, this.amount = 0, this.multiplier = 1, this.hours = 0});

  factory RecipeEffect._fromYaml(Map y) {
    final type = switch (y['type']) {
      'coins' => RecipeEffectType.coins,
      'growth_boost' => RecipeEffectType.growthBoost,
      'visitor_lure' => RecipeEffectType.visitorLure,
      final other => throw FormatException('Unknown recipe effect type "$other"'),
    };
    return RecipeEffect(
      type: type,
      amount: (y['amount'] as num?)?.toInt() ?? 0,
      multiplier: (y['multiplier'] as num?)?.toDouble() ?? 1,
      hours: (y['hours'] as num?)?.toInt() ?? 0,
    );
  }

  final RecipeEffectType type;
  final int amount;
  final double multiplier;
  final int hours;
}

bool _oddsSumToOne(Iterable<double> odds) => (odds.fold(0.0, (a, b) => a + b) - 1).abs() < 0.001;

Map _map(Object? v, String path) {
  if (v is Map) return v;
  throw FormatException('"$path" should be a map of values');
}

List _list(Object? v, String path) {
  if (v is List) return v;
  throw FormatException('"$path" should be a list');
}

int _int(Object? v, String path) {
  if (v is int) return v;
  throw FormatException('"$path" should be a whole number');
}

double _double(Object? v, String path) {
  if (v is num) return v.toDouble();
  throw FormatException('"$path" should be a number');
}

Map<Rarity, int> _rarityIntMap(Object? v, String path) => {
  for (final e in _map(v, path).entries) Rarity.fromId(e.key as String): _int(e.value, '$path.${e.key}'),
};

Map<Rarity, double> _rarityDoubleMap(Object? v, String path) => {
  for (final e in _map(v, path).entries) Rarity.fromId(e.key as String): _double(e.value, '$path.${e.key}'),
};
