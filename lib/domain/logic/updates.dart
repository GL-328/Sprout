/// What a published build says about itself (the release's `version.json`).
class UpdateInfo {
  const UpdateInfo({
    required this.versionCode,
    required this.versionName,
    required this.sha256,
    this.size,
    this.notes = '',
  });

  /// Returns null if [json] isn't a usable version file.
  static UpdateInfo? fromJson(Object? json) {
    if (json is! Map) return null;
    final code = json['versionCode'];
    final hash = json['sha256'];
    final size = json['size'];
    if (code is! int || hash is! String || hash.length != 64) return null;
    return UpdateInfo(
      versionCode: code,
      versionName: json['versionName'] as String? ?? '',
      sha256: hash.toLowerCase(),
      size: size is int && size > 0 ? size : null,
      notes: json['notes'] as String? ?? '',
    );
  }

  /// The build number. Always increases with each build.
  final int versionCode;
  final String versionName;

  /// Hash of the APK, checked before installing.
  final String sha256;

  /// Size of the APK in bytes, when the release says.
  final int? size;
  final String notes;
}

/// Whether [info] is a newer build than the one running.
bool isNewer(int currentVersionCode, UpdateInfo info) => info.versionCode > currentVersionCode;

/// Automatic checks happen at most once a day.
bool shouldCheck(DateTime? lastCheck, DateTime now) =>
    lastCheck == null || now.difference(lastCheck) >= const Duration(hours: 24) || now.isBefore(lastCheck);

/// Room needed to download and install an update of [size] bytes: the
/// download itself, Android's copy of it, and a little spare.
int spaceNeeded(int size) => size * 2 + 20 * 1024 * 1024;

/// Why an update didn't happen.
enum UpdateError {
  /// Couldn't reach GitHub or read the version file.
  offline,
  noStorage,
  permissionOff,

  /// The download stopped early or didn't match its checksum.
  downloadFailed,
  cancelled,

  /// The new build is signed with a different key than the installed one.
  signedDifferently,

  /// Android or Play Protect blocked it.
  blocked,

  /// Not compatible with this phone, or an older build.
  incompatible,
  other,
}

/// Android's `PackageInstaller` status codes.
abstract final class InstallStatus {
  static const pendingUserAction = -1;
  static const success = 0;
  static const failure = 1;
  static const blocked = 2;
  static const aborted = 3;
  static const invalid = 4;
  static const conflict = 5;
  static const storage = 6;
  static const incompatible = 7;
  static const timeout = 8;
}

/// Turns an installer result into an [UpdateError]; null means it worked or
/// is still waiting for the user.
UpdateError? installError(int status, String message) {
  final m = message.toUpperCase();
  if (m.contains('SIGNATURE') || m.contains('UPDATE_INCOMPATIBLE') || m.contains('NO_CERTIFICATES')) {
    return UpdateError.signedDifferently;
  }
  if (m.contains('INSUFFICIENT_STORAGE')) return UpdateError.noStorage;
  return switch (status) {
    InstallStatus.pendingUserAction || InstallStatus.success => null,
    InstallStatus.aborted => UpdateError.cancelled,
    InstallStatus.blocked => UpdateError.blocked,
    InstallStatus.invalid => UpdateError.downloadFailed,
    InstallStatus.conflict => UpdateError.signedDifferently,
    InstallStatus.storage => UpdateError.noStorage,
    InstallStatus.incompatible => UpdateError.incompatible,
    _ => UpdateError.other,
  };
}

/// What happened to the update the app tried before it last closed.
enum LaunchCheck { none, updated, notInstalled }

LaunchCheck checkAfterLaunch({required int? expectedBuild, required int currentBuild}) {
  if (expectedBuild == null) return LaunchCheck.none;
  return currentBuild >= expectedBuild ? LaunchCheck.updated : LaunchCheck.notInstalled;
}
