import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/game_config.dart';
import '../data/db/app_database.dart';
import '../data/repositories/counters_repository.dart';
import '../data/repositories/seed_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/services/backup_service.dart';
import '../domain/models/app_settings.dart';
import '../domain/models/enums.dart';
import '../domain/models/seed.dart';
import 'clock.dart';
import 'providers.dart';

/// Set in the owner's own settings once the developer password has been
/// entered, so Settings can offer the dev account. It holds no password.
const devUnlockedKey = 'dev_unlocked';

/// SHA-256 of the developer password. Only the hash lives in the app.
const devPasswordHash = '15ae3c6a70058a5ab60c19e20419c1e86bfff08b7530243b0a6dd92b7cba46ea';

/// Whether [input] is the developer password ([hash] is for tests, so the real
/// password never appears in the repo).
bool devPasswordMatches(String input, {String hash = devPasswordHash}) =>
    sha256.convert(utf8.encode(input)).toString() == hash;

/// Whether the dev account has been unlocked on this phone.
final devUnlockedProvider = FutureProvider<bool>(
  (ref) async => await ref.watch(settingsRepositoryProvider).readValue(devUnlockedKey) == 'true',
);

/// What a new (or reset) dev account starts with.
class DevAccount {
  static const coins = 5000;
  static const seedsPerRarity = 2;

  /// Sets up an empty dev database: onboarding done, every plot unlocked,
  /// plenty of coins and a few seeds of each rarity. Look-and-feel and sound
  /// settings are copied from [from], so testing feels the same.
  static Future<void> seed(AppDatabase db, GameConfig config, AppSettings from) async {
    const clock = Clock();
    final seeds = SeedRepository(db, clock);
    await SettingsRepository(db).save(from.copyWith(name: 'Dev', onboardingDone: true, remindersOn: false));
    for (final env in config.environments) {
      await seeds.ensurePlot(env.id);
    }
    await CountersRepository(db).add(CounterKeys.coins, coins);
    for (final rarity in Rarity.values) {
      final kinds = config.species.values.where((s) => s.rarity == rarity).take(seedsPerRarity);
      for (final s in kinds) {
        await seeds.add(s.id, rarity, SeedSource.mysteryPack);
      }
    }
  }
}

/// Before the dev account existed, developer mode changed the owner's own
/// garden and kept a snapshot to put back. If that mode was left on, put the
/// garden back exactly as it was and tidy up.
Future<void> restoreOldDevSnapshot(AppDatabase db, Directory directory) async {
  final settings = SettingsRepository(db);
  if (await settings.readValue('dev_mode') != 'on') return;
  final snapshot = File('${directory.path}/dev_mode_snapshot.json');
  if (await snapshot.exists()) {
    await BackupService(db, const Clock()).importJson(await snapshot.readAsString());
    await snapshot.delete();
  }
  await settings.writeValue('dev_mode', 'off');
}
