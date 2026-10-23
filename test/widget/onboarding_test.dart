import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/data/repositories/settings_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';

import 'test_app.dart';

void main() {
  testWidgets('onboarding can be completed and lands on the garden', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.pumpWidget(testApp(db));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Sprout'), findsOneWidget);
    await tester.tap(find.text("Let's begin"));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Robin');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Sleep'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plant it'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Robin'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget, reason: 'bottom navigation is visible');

    final saved = await tester.runAsync(() => SettingsRepository(db).load());
    expect(saved!.onboardingDone, isTrue);
    expect(saved.name, 'Robin');
  });

  testWidgets('every onboarding step can be skipped', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.pumpWidget(testApp(db));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('returning users go straight to the garden and can switch tabs', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true)));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Sprout'), findsNothing);
    for (final tab in ['Today', 'Journal', 'Shop', 'Settings', 'Home']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }
    expect(find.textContaining('Meadow'), findsOneWidget);
  });
}
