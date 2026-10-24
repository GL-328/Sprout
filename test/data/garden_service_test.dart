import 'package:flutter_test/flutter_test.dart';
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

  test('the starter seed can be planted in the Meadow', () async {
    await env.garden.grantStarterSeed(plant: true);
    final plants = await env.garden.watchPlants('meadow').first;
    expect(plants.single.speciesId, 'giant_sunflower');
    expect(await env.seeds.bagCount(), 0);
  });

  test('skipping onboarding leaves the starter seed in the bag', () async {
    await env.garden.grantStarterSeed(plant: false);
    expect(await env.seeds.bagCount(), 1);
  });

  test('plants only grow in suitable, unlocked plots with free slots', () async {
    final oak = await env.seeds.add('oak', Rarity.uncommon, SeedSource.quests);
    expect(() => env.garden.plantSeed(oak.id, 'meadow', 0), throwsA(isA<GardenException>()));
    expect(() => env.garden.plantSeed(oak.id, 'forest', 0), throwsA(isA<GardenException>()), reason: 'locked');

    final a = await env.seeds.add('apple_tree', Rarity.common, SeedSource.quests);
    final b = await env.seeds.add('berry_bush', Rarity.common, SeedSource.quests);
    await env.garden.plantSeed(a.id, 'meadow', 0);
    expect(() => env.garden.plantSeed(b.id, 'meadow', 0), throwsA(isA<GardenException>()), reason: 'taken');
    expect(() => env.garden.plantSeed(b.id, 'meadow', 3), throwsA(isA<GardenException>()), reason: 'only 3 slots');
  });

  test('mature plants fruit repeatedly while the app is closed', () async {
    final seed = await env.seeds.add('berry_bush', Rarity.common, SeedSource.quests);
    final plant = await env.garden.plantSeed(seed.id, 'meadow', 1);
    expect((await env.garden.harvest(plant.id)).fruit, 0);

    env.clock.advance(const Duration(days: 2));
    final first = await env.garden.harvest(plant.id);
    expect(first.fruit, 3 * 3, reason: '3 stored harvests of 3 berries');

    env.clock.advance(const Duration(minutes: 120));
    expect((await env.garden.harvest(plant.id)).fruit, 3);
    expect((await env.garden.inventory())['berry_bush'], 12);
  });

  test('moving on frees the slot and keeps a keepsake', () async {
    final seed = await env.seeds.add('apple_tree', Rarity.common, SeedSource.quests);
    final plant = await env.garden.plantSeed(seed.id, 'meadow', 0);
    await env.garden.moveOn(plant.id);
    expect(await env.garden.watchPlants('meadow').first, isEmpty);
    expect((await env.garden.watchAllPlants().first).single.isKeepsake, isTrue);
    expect(await env.garden.firstFreeSlot('meadow'), 1);
  });

  test('new plants go in the middle spot first, then outwards', () async {
    expect(await env.garden.firstFreeSlot('meadow'), 1);
    final a = await env.seeds.add('apple_tree', Rarity.common, SeedSource.quests);
    await env.garden.plantSeed(a.id, 'meadow', 1);
    expect(await env.garden.firstFreeSlot('meadow'), 0);
    final b = await env.seeds.add('apple_tree', Rarity.common, SeedSource.quests);
    await env.garden.plantSeed(b.id, 'meadow', 0);
    expect(await env.garden.firstFreeSlot('meadow'), 2);
  });

  test('growth boosts move plants forward', () async {
    final seed = await env.seeds.add('apple_tree', Rarity.common, SeedSource.quests);
    final plant = await env.garden.plantSeed(seed.id, 'meadow', 0);
    await env.garden.boostGrowth(const Duration(hours: 10));
    final moved = (await env.garden.watchPlants('meadow').first).single;
    expect(plant.plantedAt.difference(moved.plantedAt), const Duration(hours: 10));
  });
}
