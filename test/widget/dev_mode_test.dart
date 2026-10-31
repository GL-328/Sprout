import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';

import 'test_app.dart';

void main() {
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('seven taps on the version ask for the developer password', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() => SeedRepository(db, const Clock()).ensurePlot('meadow'));
    await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
    await settle(tester);

    await tester.tap(find.text('Settings').last);
    await settle(tester);
    expect(find.text('Developer mode'), findsNothing, reason: 'hidden until unlocked');
    await tester.scrollUntilVisible(find.text('About Sprout'), 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('About Sprout'));
    await settle(tester);

    final version = find.textContaining('Version');
    await tester.scrollUntilVisible(version, 200, scrollable: find.byType(Scrollable).last);
    for (var i = 0; i < 6; i++) {
      await tester.tap(version);
      await tester.pump();
    }
    expect(find.byType(AlertDialog), findsNothing, reason: 'six taps are not enough');
    await tester.tap(version);
    await settle(tester);
    expect(find.text('Developer mode'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'not the password');
    await tester.tap(find.text('Unlock'));
    await settle(tester);
    expect(find.textContaining("That's not it"), findsOneWidget, reason: 'shown right in the box');
    expect(find.byType(TextField), findsOneWidget, reason: 'the box stays open to try again');
  });
}
