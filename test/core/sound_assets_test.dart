import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/sound_service.dart';
import 'package:sprout/features/shell/app_shell.dart';

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

  test('every plot, and the shop, has its own music', () {
    for (final track in [for (final env in testConfig.environments) env.id, 'shop']) {
      expect(File('assets/${musicAsset(track)}').existsSync(), isTrue, reason: track);
    }
  });

  test('the music follows the tab: the plot on Home, shop music in the Shop, quiet elsewhere', () {
    expect(AppShell.musicFor(0, 'forest'), 'forest');
    expect(AppShell.musicFor(3, 'forest'), 'shop');
    for (final tab in [1, 2, 4]) {
      expect(AppShell.musicFor(tab, 'forest'), isNull);
    }
  });
}
