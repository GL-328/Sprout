import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../config/game_config.dart';
import '../data/repositories/seed_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/services/backup_service.dart';
import 'providers.dart';

/// Settings key that is set while developer mode is on.
const devModeKey = 'dev_mode';

/// SHA-256 of the developer password. Only the hash lives in the app.
const _passwordHash = '15ae3c6a70058a5ab60c19e20419c1e86bfff08b7530243b0a6dd92b7cba46ea';

String _hash(String input) => sha256.convert(utf8.encode(input)).toString();

/// Developer mode, for testing: unlocks every plot. Turning it on first saves
/// a snapshot of everything; [reset] puts that snapshot back, so nothing done
/// in developer mode counts as real progress.
class DevModeService {
  DevModeService(
    this._backup,
    this._seeds,
    this._settings,
    this._config,
    this._directory, {
    String passwordHash = _passwordHash,
  }) : _passwordHashValue = passwordHash;

  final BackupService _backup;
  final SeedRepository _seeds;
  final SettingsRepository _settings;
  final GameConfig _config;

  /// Where the snapshot is kept: a file, so restoring the database can't wipe it.
  final Future<Directory> Function() _directory;

  /// Tests pass their own, so the real password never appears in the repo.
  final String _passwordHashValue;

  bool passwordMatches(String input) => _hash(input) == _passwordHashValue;

  Future<File> get _snapshot async => File('${(await _directory()).path}/dev_mode_snapshot.json');

  Future<bool> isOn() async => await _settings.readValue(devModeKey) == 'on';

  /// Turns developer mode on if [password] is right. Returns whether it did.
  Future<bool> enable(String password) async {
    if (!passwordMatches(password)) return false;
    if (await isOn()) return true;
    // The snapshot is taken before the flag is written, so a reset clears it too.
    await (await _snapshot).writeAsString(await _backup.exportJson(), flush: true);
    for (final env in _config.environments) {
      await _seeds.ensurePlot(env.id);
    }
    await _settings.writeValue(devModeKey, 'on');
    return true;
  }

  /// Puts everything back as it was before developer mode, and turns it off.
  Future<void> reset() async {
    final file = await _snapshot;
    if (await file.exists()) {
      await _backup.importJson(await file.readAsString());
      await file.delete();
    } else {
      // No snapshot to go back to: at least switch developer mode off.
      await _settings.writeValue(devModeKey, 'off');
    }
  }
}

final devModeServiceProvider = Provider<DevModeService>(
  (ref) => DevModeService(
    ref.watch(backupServiceProvider),
    ref.watch(seedRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(gameConfigProvider),
    getApplicationSupportDirectory,
  ),
);

/// Whether developer mode is on. Re-read after [DevModeService.enable] or
/// [DevModeService.reset] by invalidating it.
final devModeProvider = FutureProvider<bool>((ref) => ref.watch(devModeServiceProvider).isOn());
