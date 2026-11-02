// Renders the Mood widget's five faces from the app's own painted mood art
// into the Android drawables, so the home-screen widget matches the app.
//
// Run: flutter test tool/render_widget_art_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/features/mood/moods.dart';
import 'package:sprout/ui/art/icon_art.dart';

const _out = 'android/app/src/main/res/drawable-nodpi';
const _px = 192.0;

void main() {
  testWidgets('mood faces for the widget', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(_px, _px);
    addTearDown(tester.view.reset);
    for (final o in moodOptions) {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: Container(
                width: _px,
                height: _px,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: o.color, shape: BoxShape.circle),
                child: ArtIcon(o.icon, size: _px * 0.74),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final ui.Image image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        File('$_out/widget_mood_${o.value}.png')
          ..parent.createSync(recursive: true)
          ..writeAsBytesSync(data!.buffer.asUint8List());
      });
    }
  });
}
