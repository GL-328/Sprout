import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/data/repositories/wellbeing_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';

import 'test_app.dart';

void main() {
  Future<void> open(WidgetTester tester, String tab) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() => SeedRepository(db, const Clock()).ensurePlot('meadow'));
    await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tab).last);
    await tester.pumpAndSettle();
  }

  testWidgets('every Journal tab opens', (tester) async {
    await open(tester, 'Journal');
    for (final tab in ['Quests', 'Plants', 'Visitors', 'Achievements', 'Moods']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
    }
    await tester.dragUntilVisible(
      find.text('Need a little support?'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    expect(find.text('Need a little support?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every Shop tab opens', (tester) async {
    await open(tester, 'Shop');
    expect(find.text('✅ Unlocked'), findsOneWidget, reason: 'the Meadow is unlocked');
    for (final tab in ['Sell & compost', 'Recipes', 'Decorations', 'Mystery seeds']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
    }
    expect(find.text('Mystery seed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mood check-in saves a mood', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() => SeedRepository(db, const Clock()).ensurePlot('meadow'));
    await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today').last);
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Feeling Good'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save check-in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save check-in'));
    for (var i = 0; i < 5; i++) {
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    }
    await tester.pumpAndSettle();

    expect(find.text('Checked in: Good'), findsOneWidget);
    final saved = await tester.runAsync(() => WellbeingRepository(db, const Clock()).watchMoods().first);
    expect(saved!.values.single.value, 4);
  });

  testWidgets('settings has export, import and delete', (tester) async {
    await open(tester, 'Settings');
    await tester.scrollUntilVisible(find.text('Delete all data'), 200);
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Export my data'), findsOneWidget);
    expect(find.text('Import from a backup'), findsOneWidget);
    await tester.tap(find.text('Delete all data'));
    await tester.pumpAndSettle();
    expect(find.text('Delete all data?'), findsOneWidget);
    await tester.tap(find.text('Keep my data'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
