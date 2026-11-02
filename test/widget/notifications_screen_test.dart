import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/accounts.dart';
import 'package:sprout/core/home_widgets.dart';
import 'package:sprout/core/notifications_service.dart';
import 'package:sprout/core/providers.dart';
import 'package:sprout/core/sound_service.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/domain/logic/reminders.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/features/settings/dev_mode_section.dart';
import 'package:sprout/features/settings/notifications_screen.dart';

import 'test_app.dart';

class _FakeScheduler extends NoopReminderScheduler {
  _FakeScheduler({this.allowed = true});

  final bool allowed;
  int asked = 0;
  final tests = <(GardenNotice, Duration)>[];

  @override
  Future<bool> requestPermission() async {
    asked++;
    return allowed;
  }

  @override
  Future<void> test(GardenNotice sample, {Duration delay = Duration.zero}) async => tests.add((sample, delay));
}

void main() {
  Widget host(AppDatabase db, _FakeScheduler scheduler, Widget child, {Account account = Account.main}) =>
      ProviderScope(
        overrides: [
          gameConfigProvider.overrideWithValue(testConfig),
          databaseProvider.overrideWithValue(db),
          initialSettingsProvider.overrideWithValue(const AppSettings(onboardingDone: true, reducedMotion: true)),
          reminderSchedulerProvider.overrideWithValue(scheduler),
          homeWidgetBridgeProvider.overrideWithValue(const NoopHomeWidgetBridge()),
          soundServiceProvider.overrideWithValue(const SilentSoundService()),
          activeAccountProvider.overrideWithValue(account),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets('each kind of notification has its own switch, and turning one on asks first', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    final scheduler = _FakeScheduler();
    await tester.pumpWidget(host(db, scheduler, const NotificationsScreen()));
    await tester.pumpAndSettle();

    for (final label in ['Daily check-in', 'Quest reminders', 'Fruit ready to pick', 'Plant fully grown']) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text('Fruit ready to pick'));
    await tester.pumpAndSettle();
    expect(scheduler.asked, 1);
    final container = ProviderScope.containerOf(tester.element(find.byType(NotificationsScreen)));
    expect(container.read(settingsProvider).notifyFruit, isTrue);
    expect(container.read(settingsProvider).notifyGrown, isFalse);

    // Turning off doesn't need permission.
    await tester.tap(find.text('Fruit ready to pick'));
    await tester.pumpAndSettle();
    expect(scheduler.asked, 1);
    expect(container.read(settingsProvider).notifyFruit, isFalse);
  });

  testWidgets('when the phone says no, the switch stays off and says why', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.pumpWidget(host(db, _FakeScheduler(allowed: false), const NotificationsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plant fully grown'));
    await tester.pumpAndSettle();
    expect(find.textContaining('turned off for Sprout'), findsOneWidget);
    final container = ProviderScope.containerOf(tester.element(find.byType(NotificationsScreen)));
    expect(container.read(settingsProvider).notifyGrown, isFalse);
  });

  testWidgets('the dev account can send test notifications', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    final scheduler = _FakeScheduler();
    await tester.pumpWidget(
      host(db, scheduler, const SingleChildScrollView(child: DevModeCard()), account: Account.dev),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pop up now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fruit ready in 10 seconds'));
    await tester.pumpAndSettle();
    expect(find.text('On its way in 10 seconds.'), findsOneWidget);
    await tester.tap(find.text('Plant grown in 10 seconds'));
    await tester.pumpAndSettle();

    expect(scheduler.tests.map((t) => t.$2), [Duration.zero, const Duration(seconds: 10), const Duration(seconds: 10)]);
    expect(scheduler.tests.map((t) => t.$1.id).toSet().length, 3);
    expect(scheduler.tests.every((t) => t.$1.id >= testNoticeBaseId), isTrue);
  });

  testWidgets('the main account has no test buttons', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.pumpWidget(host(db, _FakeScheduler(), const DevModeCard()));
    await tester.pumpAndSettle();
    expect(find.text('Pop up now'), findsNothing);
  });
}
