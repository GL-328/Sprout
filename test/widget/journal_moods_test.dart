import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/features/mood/moods.dart';

import 'test_app.dart';

void main() {
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    }
    await tester.pumpAndSettle();
  }

  testWidgets("today's mood can be set from Journal → Moods", (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() => SeedRepository(db, const Clock()).ensurePlot('meadow'));
    await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
    await settle(tester);

    await tester.tap(find.text('Journal').last);
    await settle(tester);
    expect(find.text('How are you feeling?'), findsOneWidget, reason: 'the faces are on the Moods tab');

    await tester.tap(find.bySemanticsLabel('Feeling ${moodOption(4).label}'));
    await settle(tester);
    await tester.tap(find.text('Save check-in'));
    await settle(tester);

    expect(find.text(moodReply(4)), findsOneWidget, reason: "today's mood shows, ready to change");
    expect(find.bySemanticsLabel("Today: change today's mood"), findsOneWidget, reason: 'and in the calendar');
    expect(find.byTooltip('Next month'), findsOneWidget);
    final next = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right));
    expect(next.onPressed, isNull, reason: 'no future months to look at');
  });
}
