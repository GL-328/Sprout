import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/data/repositories/quest_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/data/repositories/settings_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/features/home/home_tutorial.dart';
import 'package:sprout/features/home/plant_carousel.dart';
import 'package:sprout/features/home/quests_panel.dart';
import 'package:sprout/ui/layout/insets.dart';
import 'package:sprout/ui/widgets/measure_size.dart';

import '../visual/render.dart';
import 'test_app.dart';

const _titles = [
  'Drink a glass of water',
  'Stretch for two minutes',
  'Text a friend',
  'Tidy one corner',
  'Read a page',
];

Future<AppDatabase> withQuests(WidgetTester tester, int n) async {
  final db = memoryDb();
  addTearDown(db.close);
  await tester.runAsync(() async {
    await SeedRepository(db, const Clock()).ensurePlot('meadow');
    await SettingsRepository(db).writeValue(tutorialDoneKey, 'true');
    final quests = QuestRepository(db, const Clock());
    for (final t in _titles.take(n)) {
      await quests.create(title: t, category: QuestCategory.home, difficulty: Difficulty.small);
    }
  });
  return db;
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
  }
  await tester.pumpAndSettle();
}

void main() {
  const settings = AppSettings(name: 'Sam', onboardingDone: true, reducedMotion: true);

  for (final scale in [1.0, 1.3]) {
    for (final n in [0, 1, 2, 5]) {
      testWidgets('Home with $n quests at ${(scale * 100).round()}% text', (tester) async {
        await loadAppFonts();
        setPhoneScreen(tester, textScale: scale);
        final db = await withQuests(tester, n);
        await tester.pumpWidget(shot(testApp(db, settings: settings)));
        await settle(tester);
        await savePng(tester, 'home_panel_${n}_${(scale * 100).round()}');

        // The first quests due today, in order: two at normal text size. With
        // bigger text the panel may show fewer, so the plant keeps its room;
        // "See all (N)" always tells how many there are.
        final shown = [
          for (final title in _titles.take(n))
            if (find.text(title).evaluate().isNotEmpty) title,
        ];
        expect(shown, _titles.take(shown.length).toList(), reason: 'the first quests, in order');
        expect(shown.length, lessThanOrEqualTo(QuestsPanel.defaultShown));
        if (scale == 1) expect(shown.length, n < 2 ? n : 2);
        if (n > 0) expect(shown, isNotEmpty);
        final shownCount = shown.length;
        expect(find.text(n > shownCount ? 'See all ($n)' : 'See all'), findsOneWidget);
        if (n == 0) expect(find.text('Add a quest'), findsOneWidget);

        // The panel's content sits fully above the nav bar and system bar...
        final navTop = 640 - AppInsets.shellNavHeight(24);
        final lastInPanel = n == 0 ? find.text('Add a quest') : find.text(_titles[shownCount - 1]);
        final row = find.ancestor(of: lastInPanel, matching: find.byType(Material)).first;
        expect(tester.getRect(row).bottom, lessThanOrEqualTo(navTop), reason: 'clear of the nav bar');
        // ...and the garden stays clear of the panel.
        final panelTop = tester.getRect(find.byType(QuestsPanel)).top;
        expect(tester.getRect(find.byType(PlantCarousel)).bottom, lessThanOrEqualTo(panelTop));
        expect(find.byType(MeasureSize), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('complete and undo from the panel; the next quest moves up', (tester) async {
    setPhoneScreen(tester);
    final db = await withQuests(tester, 3);
    await tester.pumpWidget(testApp(db, settings: settings));
    await settle(tester);

    expect(find.text('Text a friend'), findsNothing);
    await tester.tap(find.bySemanticsLabel(RegExp('Complete Drink a glass of water')));
    await settle(tester);
    expect(find.text('Text a friend'), findsOneWidget, reason: 'the third quest moves into the panel');
    expect(find.text('See all'), findsOneWidget, reason: 'two left, so no count');

    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(find.text('Drink a glass of water'), findsOneWidget);
    expect(find.text('See all (3)'), findsOneWidget);
  });

  testWidgets('"All done for today" once everything is done', (tester) async {
    setPhoneScreen(tester);
    final db = await withQuests(tester, 1);
    await tester.pumpWidget(testApp(db, settings: settings));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('Complete Drink a glass of water')));
    await settle(tester);
    expect(find.text('All done for today'), findsOneWidget);
  });

  testWidgets('"See all" opens the Today tab', (tester) async {
    setPhoneScreen(tester);
    final db = await withQuests(tester, 5);
    await tester.pumpWidget(testApp(db, settings: settings));
    await settle(tester);
    await tester.tap(find.text('See all (5)'));
    await settle(tester);
    expect(find.text('Read a page'), findsOneWidget, reason: 'the full list');
  });
}
