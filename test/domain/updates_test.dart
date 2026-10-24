import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/domain/logic/updates.dart';

void main() {
  final hash = 'a' * 64;

  test('reads a version file', () {
    final info = UpdateInfo.fromJson({'versionCode': 42, 'versionName': '0.1.0', 'sha256': hash.toUpperCase()});
    expect(info!.versionCode, 42);
    expect(info.versionName, '0.1.0');
    expect(info.sha256, hash);
  });

  test('ignores broken version files', () {
    expect(UpdateInfo.fromJson(null), isNull);
    expect(UpdateInfo.fromJson('nope'), isNull);
    expect(UpdateInfo.fromJson({'versionCode': '42', 'sha256': hash}), isNull);
    expect(UpdateInfo.fromJson({'versionCode': 42, 'sha256': 'short'}), isNull);
  });

  test('only newer builds are offered', () {
    final info = UpdateInfo(versionCode: 10, versionName: '', sha256: hash);
    expect(isNewer(9, info), isTrue);
    expect(isNewer(10, info), isFalse);
    expect(isNewer(11, info), isFalse);
  });

  test('checks at most once a day', () {
    final now = DateTime(2026, 3, 2, 12);
    expect(shouldCheck(null, now), isTrue);
    expect(shouldCheck(now.subtract(const Duration(hours: 3)), now), isFalse);
    expect(shouldCheck(now.subtract(const Duration(hours: 25)), now), isTrue);
    expect(shouldCheck(now.add(const Duration(days: 2)), now), isTrue, reason: 'clock moved backwards');
  });

  test('reads the APK size when the release gives it', () {
    expect(UpdateInfo.fromJson({'versionCode': 2, 'sha256': hash, 'size': 1000})!.size, 1000);
    expect(UpdateInfo.fromJson({'versionCode': 2, 'sha256': hash})!.size, isNull);
    expect(UpdateInfo.fromJson({'versionCode': 2, 'sha256': hash, 'size': -1})!.size, isNull);
  });

  test('build 14 is offered to build 11, never the other way', () {
    final b14 = UpdateInfo(versionCode: 14, versionName: '0.1.0', sha256: hash);
    expect(isNewer(11, b14), isTrue);
    expect(isNewer(14, b14), isFalse);
    expect(isNewer(15, b14), isFalse);
  });

  test("needs room for the download and Android's copy", () {
    expect(spaceNeeded(68 * 1024 * 1024), greaterThan(136 * 1024 * 1024));
  });

  test('maps installer results to clear reasons', () {
    expect(installError(InstallStatus.success, ''), isNull);
    expect(installError(InstallStatus.pendingUserAction, ''), isNull);
    expect(installError(InstallStatus.aborted, ''), UpdateError.cancelled);
    expect(installError(InstallStatus.storage, ''), UpdateError.noStorage);
    expect(installError(InstallStatus.conflict, ''), UpdateError.signedDifferently);
    expect(
      installError(InstallStatus.incompatible, 'INSTALL_FAILED_UPDATE_INCOMPATIBLE: signatures do not match'),
      UpdateError.signedDifferently,
    );
    expect(installError(InstallStatus.incompatible, 'INSTALL_FAILED_VERSION_DOWNGRADE'), UpdateError.incompatible);
    expect(installError(InstallStatus.blocked, ''), UpdateError.blocked);
    expect(installError(InstallStatus.invalid, ''), UpdateError.downloadFailed);
    expect(installError(InstallStatus.failure, 'INSTALL_FAILED_INSUFFICIENT_STORAGE'), UpdateError.noStorage);
    expect(installError(InstallStatus.failure, ''), UpdateError.other);
  });

  test('after a restart, tells whether the update landed', () {
    expect(checkAfterLaunch(expectedBuild: null, currentBuild: 11), LaunchCheck.none);
    expect(checkAfterLaunch(expectedBuild: 14, currentBuild: 14), LaunchCheck.updated);
    expect(checkAfterLaunch(expectedBuild: 14, currentBuild: 11), LaunchCheck.notInstalled);
  });
}
