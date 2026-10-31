import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/data/services/economy_service.dart';
import 'package:sprout/data/services/garden_service.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/domain/models/seed.dart';

import 'test_env.dart';

void main() {
  late TestEnv env;

  setUp(() async {
    env = TestEnv();
    await env.garden.ensureStartingPlot();
  });

  tearDown(() => env.close());

  Future<int> coins() => env.counters.get(CounterKeys.coins);

  test('selling fruit gives coins by species price', () async {
    await env.garden.addToInventory('apple_tree', 4);
    final earned = await env.economy.sellFruit('apple_tree', 3);
    expect(earned, 3 * TestEnv.config.speciesById('apple_tree').fruit.sellPrice);
    expect(await coins(), earned);
    expect((await env.garden.inventory())['apple_tree'], 1);
    expect(() => env.economy.sellFruit('apple_tree', 5), throwsA(isA<GardenException>()));
  });

  test('composting gives coins by rarity', () async {
    final seed = await env.seeds.add('oak', Rarity.uncommon, SeedSource.quests);
    expect(await env.economy.compostSeed(seed.id), TestEnv.config.compostCoins[Rarity.uncommon]);
    expect(await env.seeds.bagCount(), 0);
    expect(await env.economy.compostSeed(seed.id), 0, reason: 'cannot compost twice');
  });

  test('plots cost coins and unlock new plants', () async {
    expect(() => env.economy.unlockPlot('forest'), throwsA(isA<GardenException>()));
    await env.counters.add(CounterKeys.coins, 200);
    await env.economy.unlockPlot('forest');
    expect(await coins(), 50);
    expect(await env.seeds.unlockedEnvironments(), containsAll(['meadow', 'forest']));

    final oak = await env.seeds.add('oak', Rarity.uncommon, SeedSource.quests);
    await env.garden.plantSeed(oak.id, 'forest', 0);
  });

  test('cosmetics are bought once and placed one per kind', () async {
    await env.counters.add(CounterKeys.coins, 500);
    await env.economy.buyCosmetic('paper_lantern');
    await env.economy.buyCosmetic('paper_lantern');
    expect(await coins(), 500 - 60);
    await env.economy.placeCosmetic('meadow', 'lantern', 'paper_lantern');
    await env.economy.buyCosmetic('fairy_lights');
    await env.economy.placeCosmetic('meadow', 'lantern', 'fairy_lights');
    expect((await env.economy.watchPlacedCosmetics().first)['meadow'], {'lantern': 'fairy_lights'});
  });

  test('mystery packs cost coins and respect the bag cap', () async {
    await env.counters.add(CounterKeys.coins, 1000);
    final seeds = await env.economy.buyMysteryPack('small_pack');
    expect(seeds, hasLength(1));
    expect(seeds.single.source, SeedSource.mysteryPack);

    for (var i = await env.seeds.bagCount(); i < TestEnv.config.seedBagCap; i++) {
      await env.seeds.add('apple_tree', Rarity.common, SeedSource.quests);
    }
    expect(() => env.economy.buyMysteryPack('small_pack'), throwsA(isA<GardenException>()));
  });

  test('recipes use fruit and apply their effect', () async {
    await env.garden.addToInventory('apple_tree', 2);
    await env.garden.addToInventory('berry_bush', 2);
    final out = await env.economy.cook('fruit_salad');
    expect(out.message, contains('coins'));
    expect(await coins(), 35);
    expect(await env.garden.inventory(), {'apple_tree': 0, 'berry_bush': 0});
    expect(() => env.economy.cook('fruit_salad'), throwsA(isA<GardenException>()));

    await env.garden.addToInventory('lavender_hedge', 2);
    await env.economy.cook('calming_tea');
    expect(await env.settings.readValue(visitorLureUntilKey), isNotNull);
  });

  test('each recipe can be made once a day, so boosts cannot loop into endless coins', () async {
    Future<void> stock() async {
      await env.garden.addToInventory('cacao', 2);
      await env.garden.addToInventory('coconut_palm', 1);
    }

    await stock();
    await env.economy.cook('hot_cocoa');
    expect(await env.economy.watchRecipesMadeToday().first, {'hot_cocoa'});

    // Plenty of fruit again, but not until tomorrow.
    await stock();
    await expectLater(env.economy.cook('hot_cocoa'), throwsA(isA<GardenException>()));
    expect((await env.garden.inventory())['cacao'], 2, reason: 'nothing is used up when it says no');

    // Another recipe is still fine today.
    await env.garden.addToInventory('lavender_hedge', 2);
    await env.economy.cook('calming_tea');

    env.clock.advance(const Duration(days: 1));
    await env.economy.cook('hot_cocoa');
    expect(await env.economy.watchRecipesMadeToday().first, {'hot_cocoa'});
  });

  test('feeding a visitor uses its favourite fruit', () async {
    await env.economy.recordVisitors(['butterfly']);
    await env.garden.addToInventory('lavender_hedge', 1);
    expect(await env.economy.feedVisitor('butterfly'), TestEnv.config.visitors['butterfly']!.thanksCoins);
    expect((await env.economy.watchVisitorsSeen().first)['butterfly']!.timesFed, 1);
    expect(() => env.economy.feedVisitor('butterfly'), throwsA(isA<GardenException>()));
  });
}
