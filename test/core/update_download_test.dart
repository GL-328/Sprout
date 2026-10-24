import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/updater.dart';
import 'package:sprout/domain/logic/updates.dart';

void main() {
  late Directory dir;
  final apk = List<int>.generate(100000, (i) => i % 251);
  final hash = sha256.convert(apk).toString();

  setUp(() => dir = Directory.systemTemp.createTempSync('sprout_update'));
  tearDown(() => dir.deleteSync(recursive: true));

  Stream<List<int>> chunks(List<int> bytes, {int size = 8192}) async* {
    for (var i = 0; i < bytes.length; i += size) {
      yield bytes.sublist(i, (i + size).clamp(0, bytes.length));
    }
  }

  File target() => File('${dir.path}/sprout-update.apk');
  UpdateInfo info({String? sha, int? size}) =>
      UpdateInfo(versionCode: 15, versionName: '0.1.0', sha256: sha ?? hash, size: size);

  test('a complete download that matches is kept, with progress up to 100%', () async {
    final progress = <double>[];
    final file = await saveVerified(
      chunks(apk),
      info: info(size: apk.length),
      target: target(),
      onProgress: progress.add,
    );
    expect(await file.readAsBytes(), apk);
    expect(progress.last, 1.0);
    expect(progress, orderedEquals([...progress]..sort()));
    expect(File('${target().path}.part').existsSync(), isFalse);
  });

  test('a checksum mismatch is rejected and nothing is left behind', () async {
    await expectLater(
      saveVerified(
        chunks(apk),
        info: info(sha: 'b' * 64),
        target: target(),
      ),
      throwsA(isA<UpdateFailure>().having((e) => e.error, 'error', UpdateError.downloadFailed)),
    );
    expect(target().existsSync(), isFalse);
    expect(File('${target().path}.part').existsSync(), isFalse);
  });

  test('a download that stops early is rejected', () async {
    final short = apk.sublist(0, 50000);
    await expectLater(
      saveVerified(
        chunks(short),
        info: info(size: apk.length),
        target: target(),
      ),
      throwsA(isA<UpdateFailure>().having((e) => e.detail, 'detail', contains('50000 of 100000'))),
    );
    expect(target().existsSync(), isFalse);
  });

  test('an interrupted connection is rejected', () async {
    Stream<List<int>> broken() async* {
      yield apk.sublist(0, 8192);
      throw const SocketException('Connection reset');
    }

    await expectLater(
      saveVerified(broken(), info: info(), target: target(), contentLength: apk.length),
      throwsA(isA<UpdateFailure>().having((e) => e.error, 'error', UpdateError.downloadFailed)),
    );
    expect(File('${target().path}.part').existsSync(), isFalse);
  });

  test('an old finished download is replaced by the new one', () async {
    target().writeAsStringSync('old');
    final file = await saveVerified(chunks(apk), info: info(), target: target());
    expect(file.lengthSync(), apk.length);
  });
}
