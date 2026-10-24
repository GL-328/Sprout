import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/data/repositories/quest_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/data/repositories/wellbeing_repository.dart';
import 'package:sprout/data/services/garden_service.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/domain/models/seed.dart';
import 'package:sprout/ui/layout/insets.dart';

import 'test_app.dart';

/// A phone setup to check: screen size in logical pixels, system bar height
/// and text size.
class Phone {
  const Phone(this.name, this.size, this.systemBar, {this.textScale = 1});

  final String name;
  final Size size;
  final double systemBar;
  final double textScale;
}

const phones = [
  Phone('small, gesture bar', Size(360, 640), 24),
  Phone('small, three buttons', Size(360, 640), 48),
  Phone('small, 150% text', Size(360, 640), 48, textScale: 1.5),
  Phone('landscape', Size(640, 360), 48),
];

const _dpr = 2.0;

Future<void> setPhone(WidgetTester tester, Phone p) async {
  tester.view.devicePixelRatio = _dpr;
  tester.view.physicalSize = p.size * _dpr;
  tester.view.viewPadding = FakeViewPadding(bottom: p.systemBar * _dpr);
  tester.view.padding = FakeViewPadding(bottom: p.systemBar * _dpr);
  tester.platformDispatcher.textScaleFactorTestValue = p.textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
  }
  await tester.pumpAndSettle();
}

Future<AppDatabase> seededDb(WidgetTester tester) async {
  final db = memoryDb();
  addTearDown(db.close);
  await tester.runAsync(() async {
    final clock = FakeClock(DateTime.now().subtract(const Duration(hours: 1)));
    final seeds = SeedRepository(db, clock);
    await seeds.ensurePlot('meadow');
    final garden = GardenService(db, testConfig, clock, seeds, CountersRepository(db));
    final s = await seeds.add('giant_sunflower', Rarity.common, SeedSource.quests);
    await garden.plantSeed(s.id, 'meadow', 1);
    final quests = QuestRepository(db, const Clock());
    for (var i = 1; i <= 10; i++) {
      await quests.create(
        title: 'Quest number $i',
        category: QuestCategory.values[i % 7],
        difficulty: Difficulty.small,
      );
    }
    await WellbeingRepository(db, const Clock()).addContact('Sam', '0123 456', 'best friend');
  });
  return db;
}

/// Jumps the main scroll view under [within] to its very end.
Future<void> scrollToEnd(WidgetTester tester, {Finder? within}) async {
  final finder = find.descendant(of: within ?? find.byType(Scaffold).last, matching: find.byType(Scrollable));
  for (var i = 0; i < 6; i++) {
    for (final e in finder.evaluate()) {
      final state = (e as StatefulElement).state as ScrollableState;
      if (state.position.axis == Axis.vertical && state.position.maxScrollExtent > 0) {
        state.position.jumpTo(state.position.maxScrollExtent);
      }
    }
    await tester.pumpAndSettle();
  }
}

/// The bottom edge nothing may cross: the floating nav bar inside the tabs,
/// otherwise the system bar.
double safeBottom(Phone p, {required bool inShell}) =>
    p.size.height - (inShell ? AppInsets.shellNavHeight(p.systemBar) : p.systemBar);

void expectClear(WidgetTester tester, Finder target, double limit, String what) {
  expect(target, findsWidgets, reason: '$what should be on screen');
  final rect = tester.getRect(target.last);
  expect(rect.bottom, lessThanOrEqualTo(limit + 0.5), reason: '$what ends at ${rect.bottom}, covered below $limit');
}

void main() {
  for (final phone in phones) {
    group(phone.name, () {
      testWidgets('Today: last quest and the + button clear the nav bar', (tester) async {
        await setPhone(tester, phone);
        final db = await seededDb(tester);
        await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
        await settle(tester);
        await tester.tap(find.text('Today').last);
        await settle(tester);
        await scrollToEnd(tester);
        final limit = safeBottom(phone, inShell: true);
        final fab = tester.getRect(find.byTooltip('Add a quest'));
        expect(fab.bottom, lessThanOrEqualTo(limit + 0.5), reason: 'the + button sits above the nav bar');
        expectClear(tester, find.text('Quest number 10'), fab.top, 'last quest (clear of the + button)');
      });

      testWidgets('All quests: last row clears the system bar and the + button', (tester) async {
        await setPhone(tester, phone);
        final db = await seededDb(tester);
        await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
        await settle(tester);
        await tester.tap(find.text('Today').last);
        await settle(tester);
        await tester.tap(find.byTooltip('More').first);
        await settle(tester);
        await tester.tap(find.text('All quests'));
        await settle(tester);
        await scrollToEnd(tester);
        final fab = tester.getRect(find.byType(FloatingActionButton).last);
        expect(fab.bottom, lessThanOrEqualTo(safeBottom(phone, inShell: false) + 0.5));
        expectClear(tester, find.text('Quest number 10'), fab.top, 'last quest row');
      });

      testWidgets('Edit quest: the last button is reachable', (tester) async {
        await setPhone(tester, phone);
        final db = await seededDb(tester);
        await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
        await settle(tester);
        await tester.tap(find.text('Today').last);
        await settle(tester);
        await tester.ensureVisible(find.text('Quest number 1'));
        await settle(tester);
        await tester.longPress(find.text('Quest number 1'));
        await settle(tester);
        await tester.tap(find.text('Edit'));
        await settle(tester);
        await scrollToEnd(tester);
        expectClear(tester, find.text('Delete quest'), safeBottom(phone, inShell: false), 'Delete quest');
        expectClear(tester, find.textContaining('Archive'), safeBottom(phone, inShell: false), 'Archive');
      });

      testWidgets('Journal achievements: last card clears the nav bar', (tester) async {
        await setPhone(tester, phone);
        final db = await seededDb(tester);
        await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
        await settle(tester);
        await tester.tap(find.text('Journal').last);
        await settle(tester);
        await tester.ensureVisible(find.text('Achievements'));
        await settle(tester);
        await tester.tap(find.text('Achievements'));
        await settle(tester);
        await scrollToEnd(tester);
        expectClear(tester, find.text('Current gentle streak'), safeBottom(phone, inShell: true), 'last achievement');
      });

      testWidgets('Shop plots: last card clears the nav bar', (tester) async {
        await setPhone(tester, phone);
        final db = await seededDb(tester);
        await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
        await settle(tester);
        await tester.tap(find.text('Shop').last);
        await settle(tester);
        await scrollToEnd(tester);
        expectClear(tester, find.text('Mystery seed'), safeBottom(phone, inShell: true), 'last shop card');
      });

      testWidgets('About: the end of the text is readable', (tester) async {
        await setPhone(tester, phone);
        final db = await seededDb(tester);
        await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
        await settle(tester);
        await tester.tap(find.text('Settings').last);
        await settle(tester);
        await scrollToEnd(tester);
        await tester.tap(find.text('About Sprout'));
        await settle(tester);
        await scrollToEnd(tester);
        expectClear(
          tester,
          find.textContaining('SIL Open Font License'),
          safeBottom(phone, inShell: false),
          'About text',
        );
      });

      testWidgets('Settings: the last row clears the nav bar', (tester) async {
        await setPhone(tester, phone);
        final db = await seededDb(tester);
        await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
        await settle(tester);
        await tester.tap(find.text('Settings').last);
        await settle(tester);
        await scrollToEnd(tester);
        expectClear(tester, find.text('About Sprout'), safeBottom(phone, inShell: true), 'About row');
      });

      testWidgets('Plant sheet: Move on is fully visible', (tester) async {
        await setPhone(tester, phone);
        final db = await seededDb(tester);
        await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
        await settle(tester);
        await tester.tap(find.bySemanticsLabel(RegExp('Giant sunflower')).first);
        await settle(tester);
        await scrollToEnd(tester, within: find.byType(BottomSheet));
        expectClear(tester, find.text('Move on'), safeBottom(phone, inShell: false), 'Move on');
      });

      testWidgets('Contact dialog: Save stays reachable with the keyboard open', (tester) async {
        await setPhone(tester, phone);
        final db = await seededDb(tester);
        await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
        await settle(tester);
        await tester.tap(find.text('Journal').last);
        await settle(tester);
        await scrollToEnd(tester);
        await tester.tap(find.text('My helpful contacts'));
        await settle(tester);
        await tester.tap(find.text('Sam'));
        await settle(tester);
        // Open a keyboard covering about 40% of the screen.
        final keyboard = phone.size.height * 0.4;
        tester.view.viewInsets = FakeViewPadding(bottom: keyboard * _dpr);
        await settle(tester);
        await scrollToEnd(tester, within: find.byType(AlertDialog));
        expectClear(tester, find.text('Save'), phone.size.height - keyboard, 'Save button');
        tester.view.resetViewInsets();
      });
    });
  }
}
