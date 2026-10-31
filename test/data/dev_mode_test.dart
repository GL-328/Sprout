import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/dev_mode.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/domain/models/seed.dart';

import 'test_env.dart';

void main() {
  late TestEnv env;

  setUp(() => env = TestEnv());
  tearDown(() => env.close());

  test('only the right password matches', () {
    const testPassword = 'test-only password';
    final hash = sha256.convert(utf8.encode(testPassword)).toString();
    expect(devPasswordMatches(testPassword, hash: hash), isTrue);
    expect(devPasswordMatches('wrong', hash: hash), isFalse);
    expect(devPasswordMatches(''), isFalse);
  });

  test('a new dev account has every plot, plenty of coins and seeds of each rarity', () async {
    const from = AppSettings(name: 'Sam', soundOn: true, musicOn: true, accent: AccentChoice.sage);
    await DevAccount.seed(env.db, TestEnv.config, from);

    final settings = await env.settings.load();
    expect(settings.onboardingDone, isTrue);
    expect(settings.name, 'Dev');
    expect(settings.soundOn && settings.musicOn, isTrue, reason: 'sound settings come from the real account');
    expect(settings.accent, AccentChoice.sage);
    expect((await env.seeds.unlockedEnvironments()).toSet(), {for (final e in TestEnv.config.environments) e.id});
    expect(await env.counters.get(CounterKeys.coins), DevAccount.coins);
    final bag = await env.seeds.watchBag().first;
    expect({for (final s in bag) s.rarity}, Rarity.values.toSet());
  });

  test('the old in-place developer mode is undone on start', () async {
    final dir = await Directory.systemTemp.createTemp('sprout_dev');
    addTearDown(() => dir.delete(recursive: true));
    await env.garden.ensureStartingPlot();
    await env.counters.add(CounterKeys.coins, 42);
    final snapshot = await env.backup.exportJson();
    await File('${dir.path}/dev_mode_snapshot.json').writeAsString(snapshot);

    // What the old developer mode did to the real garden.
    await env.settings.writeValue('dev_mode', 'on');
    await env.counters.add(CounterKeys.coins, 1000);
    final oak = await env.seeds.add('oak', Rarity.uncommon, SeedSource.quests);
    await env.seeds.ensurePlot('forest');
    await env.garden.plantSeed(oak.id, 'forest', 0);

    await restoreOldDevSnapshot(env.db, dir);
    expect(await env.counters.get(CounterKeys.coins), 42);
    expect(await env.seeds.unlockedEnvironments(), ['meadow']);
    expect(await env.settings.readValue('dev_mode'), isNot('on'));
    expect(File('${dir.path}/dev_mode_snapshot.json').existsSync(), isFalse);

    // Running it again changes nothing.
    await restoreOldDevSnapshot(env.db, dir);
    expect(await env.counters.get(CounterKeys.coins), 42);
  });
}
