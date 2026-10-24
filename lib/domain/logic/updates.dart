/// What a published build says about itself (the release's `version.json`).
class UpdateInfo {
  const UpdateInfo({required this.versionCode, required this.versionName, required this.sha256, this.notes = ''});

  /// Returns null if [json] isn't a usable version file.
  static UpdateInfo? fromJson(Object? json) {
    if (json is! Map) return null;
    final code = json['versionCode'];
    final hash = json['sha256'];
    if (code is! int || hash is! String || hash.length != 64) return null;
    return UpdateInfo(
      versionCode: code,
      versionName: json['versionName'] as String? ?? '',
      sha256: hash.toLowerCase(),
      notes: json['notes'] as String? ?? '',
    );
  }

  /// Always increases with each build.
  final int versionCode;
  final String versionName;

  /// Hash of the APK, checked before installing.
  final String sha256;
  final String notes;
}

/// Whether [info] is a newer build than the one running.
bool isNewer(int currentVersionCode, UpdateInfo info) => info.versionCode > currentVersionCode;

/// Automatic checks happen at most once a day.
bool shouldCheck(DateTime? lastCheck, DateTime now) =>
    lastCheck == null || now.difference(lastCheck) >= const Duration(hours: 24) || now.isBefore(lastCheck);
