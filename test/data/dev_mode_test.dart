import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/dev_mode.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/domain/models/seed.dart';

import 'test_env.dart';

void main() {
  late TestEnv env;
  late Directory dir;
  late DevModeService dev;
  const testPassword = 'test-only password';

  setUp(() async {
    env = TestEnv();
    dir = await Directory.systemTemp.createTemp('sprout_dev');
    dev = DevModeService(
      env.backup,
      env.seeds,
      env.settings,
      TestEnv.config,
      () async => dir,
      passwordHash: sha256.convert(utf8.encode(testPassword)).toString(),
    );
    await env.garden.ensureStartingPlot();
  });

  tearDown(() async {
    await env.close();
    await dir.delete(recursive: true);
  });

  test('only the right password turns developer mode on', () async {
    expect(dev.passwordMatches('wrong'), isFalse);
    expect(await dev.enable('wrong'), isFalse);
    expect(await dev.isOn(), isFalse);
    expect(await env.seeds.unlockedEnvironments(), ['meadow']);
  });

  test('developer mode unlocks every plot, and reset puts everything back', () async {
    await env.counters.add(CounterKeys.coins, 42);
    final seed = await env.seeds.add('apple_tree', Rarity.common, SeedSource.quests);
    await env.garden.plantSeed(seed.id, 'meadow', 1);

    expect(await dev.enable(testPassword), isTrue);
    expect(await dev.isOn(), isTrue);
    expect((await env.seeds.unlockedEnvironments()).toSet(), {for (final e in TestEnv.config.environments) e.id});

    // Playing around in developer mode...
    await env.counters.add(CounterKeys.coins, 1000);
    final oak = await env.seeds.add('oak', Rarity.uncommon, SeedSource.quests);
    await env.garden.plantSeed(oak.id, 'forest', 0);

    await dev.reset();
    expect(await dev.isOn(), isFalse);
    expect(await env.seeds.unlockedEnvironments(), ['meadow']);
    expect(await env.counters.get(CounterKeys.coins), 42);
    expect((await env.garden.activePlants()).map((p) => p.speciesId), ['apple_tree']);
    expect(dir.listSync(), isEmpty, reason: 'the snapshot is cleaned up');
  });
}
