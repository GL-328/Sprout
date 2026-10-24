import 'dart:async';
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
const updateRepository = 'GL-328/Sprout';
const updateReleaseTag = 'latest';

String _assetUrl(String name) => 'https://github.com/$updateRepository/releases/download/$updateReleaseTag/$name';

/// An update step that didn't work, and why.
class UpdateFailure implements Exception {
  const UpdateFailure(this.error, [this.detail = '']);

  final UpdateError error;
  final String detail;

  @override
  String toString() => 'UpdateFailure($error${detail.isEmpty ? '' : ': $detail'})';
}

/// A result from Android's installer (see [InstallStatus]).
class InstallEvent {
  const InstallEvent(this.status, [this.message = '']);

  final int status;
  final String message;
}

/// Everything the update flow needs from the phone and the network.
abstract class Updater {
  /// The running build number.
  Future<int> currentBuild();

  /// e.g. "0.1.0 (build 42)".
  Future<String> versionLabel();

  /// The newest published build. Throws [UpdateFailure].
  Future<UpdateInfo> fetchInfo();

  /// Bytes free for downloads, or null if unknown.
  Future<int?> freeBytes();

  /// Downloads and verifies the APK for [info]. Throws [UpdateFailure].
  Future<File> download(UpdateInfo info, {void Function(double progress)? onProgress});

  /// The already downloaded, verified APK for [info], if there is one.
  Future<File?> downloaded(UpdateInfo info);

  Future<bool> canInstall();

  /// Opens the system setting that lets Sprout install updates.
  Future<void> openInstallSettings();

  /// Hands [apk] to Android's installer. The outcome arrives on [events].
  Future<void> install(File apk);

  /// The fallback: opens [apk] in Android's own installer screen.
  Future<void> openSystemInstaller(File apk);

  /// Installer results while the app runs.
  Stream<InstallEvent> get events;

  /// The last installer result, even from before a restart. Read once.
  Future<InstallEvent?> takeLastResult();
}

class NoopUpdater implements Updater {
  const NoopUpdater();

  @override
  Future<int> currentBuild() async => 0;

  @override
  Future<String> versionLabel() async => 'test';

  @override
  Future<UpdateInfo> fetchInfo() async => throw const UpdateFailure(UpdateError.offline);

  @override
  Future<int?> freeBytes() async => null;

  @override
  Future<File> download(UpdateInfo info, {void Function(double progress)? onProgress}) async =>
      throw const UpdateFailure(UpdateError.downloadFailed);

  @override
  Future<File?> downloaded(UpdateInfo info) async => null;

  @override
  Future<bool> canInstall() async => true;

  @override
  Future<void> openInstallSettings() async {}

  @override
  Future<void> install(File apk) async {}

  @override
  Future<void> openSystemInstaller(File apk) async {}

  @override
  Stream<InstallEvent> get events => const Stream.empty();

  @override
  Future<InstallEvent?> takeLastResult() async => null;
}

/// Writes [bytes] to [target], reporting progress, then checks the size and
/// SHA-256 against [info]. Writes to a `.part` file first, so a half-finished
/// download is never mistaken for a whole one. Throws [UpdateFailure].
Future<File> saveVerified(
  Stream<List<int>> bytes, {
  required UpdateInfo info,
  required File target,
  int? contentLength,
  void Function(double progress)? onProgress,
}) async {
  final part = File('${target.path}.part');
  final expected = info.size ?? contentLength;
  var received = 0;
  final sink = part.openWrite();
  try {
    await for (final chunk in bytes) {
      sink.add(chunk);
      received += chunk.length;
      if (expected != null && expected > 0) onProgress?.call((received / expected).clamp(0, 1).toDouble());
    }
    await sink.flush();
  } on FileSystemException catch (e) {
    await sink.close().catchError((_) {});
    await _deleteQuietly(part);
    throw UpdateFailure(e.osError?.errorCode == 28 ? UpdateError.noStorage : UpdateError.downloadFailed, e.message);
  } catch (e) {
    await sink.close().catchError((_) {});
    await _deleteQuietly(part);
    throw UpdateFailure(UpdateError.downloadFailed, 'stopped after $received bytes: $e');
  }
  await sink.close();
  if (expected != null && received != expected) {
    await _deleteQuietly(part);
    throw UpdateFailure(UpdateError.downloadFailed, 'got $received of $expected bytes');
  }
  final digest = (await sha256.bind(part.openRead()).first).toString();
  if (digest != info.sha256) {
    await _deleteQuietly(part);
    throw const UpdateFailure(UpdateError.downloadFailed, 'checksum did not match');
  }
  await _deleteQuietly(target);
  return part.rename(target.path);
}

Future<void> _deleteQuietly(File f) async {
  try {
    if (await f.exists()) await f.delete();
  } catch (_) {}
}

/// Downloads new builds from GitHub Releases and installs them through
/// Android's package installer (see MainActivity.kt).
class GitHubReleaseUpdater implements Updater {
  static const _channel = MethodChannel('sprout/updater');
  static const _events = EventChannel('sprout/updater/events');

  /// Must match UpdateFileProvider.kt.
  static const _apkName = 'sprout-update.apk';

  Stream<InstallEvent>? _stream;

  Future<File> get _apkFile async => File('${(await getTemporaryDirectory()).path}/$_apkName');

  @override
  Future<int> currentBuild() async => int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0;

  @override
  Future<String> versionLabel() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (build ${info.buildNumber})';
  }

  @override
  Future<UpdateInfo> fetchInfo() async {
    try {
      final response = await http
          .get(Uri.parse(_assetUrl('version.json')), headers: const {'Cache-Control': 'no-cache'})
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw UpdateFailure(UpdateError.offline, 'HTTP ${response.statusCode}');
      final info = UpdateInfo.fromJson(jsonDecode(response.body));
      if (info == null) throw const UpdateFailure(UpdateError.offline, 'unreadable version file');
      return info;
    } on UpdateFailure {
      rethrow;
    } catch (e) {
      throw UpdateFailure(UpdateError.offline, '$e');
    }
  }

  @override
  Future<int?> freeBytes() async {
    try {
      return await _channel.invokeMethod<int>('freeBytes');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<File> download(UpdateInfo info, {void Function(double progress)? onProgress}) async {
    final client = http.Client();
    try {
      final response = await client
          .send(http.Request('GET', Uri.parse(_assetUrl('sprout.apk'))))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) throw UpdateFailure(UpdateError.downloadFailed, 'HTTP ${response.statusCode}');
      return await saveVerified(
        response.stream.timeout(const Duration(seconds: 60)),
        info: info,
        target: await _apkFile,
        contentLength: response.contentLength,
        onProgress: onProgress,
      );
    } on UpdateFailure {
      rethrow;
    } catch (e) {
      throw UpdateFailure(UpdateError.downloadFailed, '$e');
    } finally {
      client.close();
    }
  }

  @override
  Future<File?> downloaded(UpdateInfo info) async {
    final file = await _apkFile;
    if (!await file.exists()) return null;
    if (info.size != null && await file.length() != info.size) return null;
    final digest = (await sha256.bind(file.openRead()).first).toString();
    return digest == info.sha256 ? file : null;
  }

  @override
  Future<bool> canInstall() async => await _channel.invokeMethod<bool>('canInstall') ?? false;

  @override
  Future<void> openInstallSettings() => _channel.invokeMethod<void>('openInstallSettings');

  @override
  Future<void> install(File apk) async {
    try {
      await _channel.invokeMethod<void>('install', {'path': apk.path});
    } on PlatformException catch (e) {
      final message = e.message ?? '';
      throw UpdateFailure(installError(InstallStatus.failure, message) ?? UpdateError.other, message);
    }
  }

  @override
  Future<void> openSystemInstaller(File apk) async {
    try {
      await _channel.invokeMethod<void>('openInstaller', {'path': apk.path});
    } on PlatformException catch (e) {
      throw UpdateFailure(UpdateError.other, e.message ?? '');
    }
  }

  @override
  Stream<InstallEvent> get events => _stream ??= _events.receiveBroadcastStream().map((e) {
    final map = e as Map;
    return InstallEvent(map['status'] as int, map['message'] as String? ?? '');
  }).asBroadcastStream();

  @override
  Future<InstallEvent?> takeLastResult() async {
    try {
      final map = await _channel.invokeMapMethod<String, Object?>('takeLastResult');
      if (map == null) return null;
      return InstallEvent(map['status'] as int, map['message'] as String? ?? '');
    } catch (e) {
      debugPrint('Could not read the last install result: $e');
      return null;
    }
  }
}

/// Picks the real updater on Android and a no-op elsewhere.
Updater platformUpdater() =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? GitHubReleaseUpdater() : const NoopUpdater();
