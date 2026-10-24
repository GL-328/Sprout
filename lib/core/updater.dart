import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/logic/updates.dart';

/// Where updates come from. Change these to follow a fork or the stable channel
/// (`latest`, built from main).
const updateRepository = 'GL328/Sprout';
const updateReleaseTag = 'dev-latest';

String _assetUrl(String name) => 'https://github.com/$updateRepository/releases/download/$updateReleaseTag/$name';

enum UpdateResult {
  upToDate,

  /// A newer build was downloaded and handed to Android to install.
  installing,

  /// A newer build exists, but Sprout isn't allowed to install apps yet.
  needsPermission,
  failed,

  /// Self-updating isn't available on this platform.
  unsupported,
}

abstract class Updater {
  /// e.g. "0.1.0 (build 42)".
  Future<String> versionLabel();

  Future<bool> canInstall();

  /// Opens the system setting that lets Sprout install updates.
  Future<void> openInstallSettings();

  /// Looks for a newer build and installs it if there is one. Never throws.
  Future<UpdateResult> checkAndInstall();
}

class NoopUpdater implements Updater {
  const NoopUpdater();

  @override
  Future<String> versionLabel() async => 'test';

  @override
  Future<bool> canInstall() async => true;

  @override
  Future<void> openInstallSettings() async {}

  @override
  Future<UpdateResult> checkAndInstall() async => UpdateResult.unsupported;
}

/// Downloads new builds from GitHub Releases and installs them through
/// Android's package installer (see MainActivity.kt).
class GitHubReleaseUpdater implements Updater {
  static const _channel = MethodChannel('sprout/updater');

  bool get _supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<String> versionLabel() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (build ${info.buildNumber})';
  }

  @override
  Future<bool> canInstall() async {
    if (!_supported) return false;
    return await _channel.invokeMethod<bool>('canInstall') ?? false;
  }

  @override
  Future<void> openInstallSettings() async {
    if (_supported) await _channel.invokeMethod<void>('openInstallSettings');
  }

  @override
  Future<UpdateResult> checkAndInstall() async {
    if (!_supported) return UpdateResult.unsupported;
    try {
      final current = int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0;
      final response = await http.get(Uri.parse(_assetUrl('version.json'))).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) return UpdateResult.failed;
      final info = UpdateInfo.fromJson(jsonDecode(response.body));
      if (info == null) return UpdateResult.failed;
      if (!isNewer(current, info)) return UpdateResult.upToDate;
      if (!await canInstall()) return UpdateResult.needsPermission;

      final apk = await _download(info);
      if (apk == null) return UpdateResult.failed;
      await _channel.invokeMethod<void>('install', {'path': apk.path});
      return UpdateResult.installing;
    } catch (e) {
      debugPrint('Update check failed: $e');
      return UpdateResult.failed;
    }
  }

  /// Downloads the APK and checks its hash. Returns null if it doesn't match.
  Future<File?> _download(UpdateInfo info) async {
    final file = File('${(await getTemporaryDirectory()).path}/sprout-update.apk');
    final client = http.Client();
    try {
      final response = await client.send(http.Request('GET', Uri.parse(_assetUrl('sprout.apk'))));
      if (response.statusCode != 200) return null;
      final sink = file.openWrite();
      await response.stream.pipe(sink);
    } finally {
      client.close();
    }
    final digest = sha256.convert(await file.readAsBytes()).toString();
    if (digest != info.sha256) {
      debugPrint('Update download did not match its checksum; ignoring it.');
      await file.delete();
      return null;
    }
    return file;
  }
}
