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
}
