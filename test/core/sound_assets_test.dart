import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/sound_service.dart';

import '../widget/test_app.dart';

void main() {
  test('every sound effect has its file, and every one is soft', () {
    for (final sfx in Sfx.values) {
      for (var i = 0; i < sfx.variants; i++) {
        expect(File('assets/${sfx.file(i)}').existsSync(), isTrue, reason: sfx.file(i));
      }
      expect(sfx.volume, inInclusiveRange(0.1, 0.6), reason: sfx.name);
    }
  });

  test('every plot has its own music', () {
    for (final env in testConfig.environments) {
      expect(File('assets/${musicAsset(env.id)}').existsSync(), isTrue, reason: env.id);
    }
  });
}
