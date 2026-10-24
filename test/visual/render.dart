import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/ui/theme/app_theme.dart';

/// Where rendered images go, for a person (or Claude) to look at.
const visualDir = 'build/visual';

bool _fontsLoaded = false;

/// Loads the app's real fonts, so renders show proper text instead of boxes.
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;
  ByteData bytes(String path) => ByteData.sublistView(File(path).readAsBytesSync());
  final nunito = FontLoader(AppTheme.fontFamily);
  for (final w in ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
    nunito.addFont(Future.value(bytes('assets/fonts/Nunito-$w.ttf')));
  }
  await nunito.load();
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/opt/sdk/flutter';
  final icons = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    await (FontLoader('MaterialIcons')..addFont(Future.value(bytes(icons.path)))).load();
  }
}

/// Sets the test screen to a phone of [size] with a [systemBar] at the bottom
/// and [textScale] font size.
void setPhoneScreen(WidgetTester tester, {Size size = const Size(360, 640), double systemBar = 24, double textScale = 1}) {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = size * 2;
  tester.view.viewPadding = FakeViewPadding(top: 24 * 2, bottom: systemBar * 2);
  tester.view.padding = FakeViewPadding(top: 24 * 2, bottom: systemBar * 2);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

/// Marks what [savePng] captures.
const shotKey = ValueKey('visual-shot');

/// Wraps a whole app (or [themed] content) so it can be captured.
Widget shot(Widget app) => RepaintBoundary(key: shotKey, child: app);

/// Wraps [child] in the app theme on a plain background, ready to capture.
Widget themed(Widget child, {Brightness brightness = Brightness.light}) => shot(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.build(brightness, AccentChoice.values.first),
    home: Builder(
      builder: (context) => ColoredBox(color: Theme.of(context).colorScheme.surface, child: child),
    ),
  ),
);

/// Saves what [finder] shows (everything inside [shot] by default) to
/// `build/visual/[name].png`.
Future<File> savePng(WidgetTester tester, String name, {Finder? finder}) async {
  RenderObject? box = (finder ?? find.byKey(shotKey)).evaluate().first.renderObject;
  while (box != null && box is! RenderRepaintBoundary) {
    box = box.parent;
  }
  final boundary = box! as RenderRepaintBoundary;
  final file = File('$visualDir/$name.png');
  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(data!.buffer.asUint8List());
  });
  return file;
}
