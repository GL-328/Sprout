import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/core/notifications_service.dart';
import 'package:sprout/core/providers.dart';
import 'package:sprout/core/sound_service.dart';
import 'package:sprout/core/updater.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/data/repositories/settings_repository.dart';
import 'package:sprout/domain/logic/friends.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';
import 'package:sprout/features/friends/friends_backend.dart';
import 'package:sprout/features/friends/friends_controller.dart';
import 'package:sprout/features/friends/friends_screen.dart';

import '../features/fake_friends.dart';
import '../visual/render.dart';
import 'test_app.dart';

/// A world where Alice (this phone) is friends with Bob, Carol has asked to
/// be friends, and Dave has a code.
Future<(AppDatabase, FakeFriendsWorld)> setUpWorld(WidgetTester tester) async {
  final db = memoryDb();
  addTearDown(db.close);
  final world = FakeFriendsWorld()
    ..codes.addAll({'AAAA2222': 'alice', 'DDDD5555': 'dave'})
    ..users.addAll({
      'alice': {'name': 'Alice', 'code': 'AAAA2222'},
      'bob': {
        'name': 'Bob',
        'snapshot': const GardenSnapshot([
          SnapshotPlot(
            env: 'meadow',
            slots: [
              SnapshotSlot(slot: 0, species: 'apple_tree', stage: GrowthStage.fruiting),
              SnapshotSlot(slot: 1, species: 'berry_bush', stage: GrowthStage.young),
            ],
            decor: {'bench': 'wooden_bench'},
          ),
        ]).toJson(),
      },
    })
    ..friends.addAll({
      'alice': {'bob': 'Bob'},
      'bob': {'alice': 'Alice'},
    })
    ..requests['carol_alice'] = const FriendRequest(from: 'carol', to: 'alice', fromName: 'Carol');
  await tester.runAsync(() async {
    await SeedRepository(db, const Clock()).ensurePlot('meadow');
    final settings = SettingsRepository(db);
    await settings.writeValue(FriendsKeys.on, 'true');
    await settings.writeValue(FriendsKeys.name, 'Alice');
    await settings.writeValue(FriendsKeys.code, 'AAAA2222');
  });
  return (db, world);
}

Widget friendsApp(AppDatabase db, FakeFriendsWorld world) => ProviderScope(
  overrides: [
    gameConfigProvider.overrideWithValue(testConfig),
    databaseProvider.overrideWithValue(db),
    initialSettingsProvider.overrideWithValue(const AppSettings(onboardingDone: true, reducedMotion: true)),
    reminderSchedulerProvider.overrideWithValue(const NoopReminderScheduler()),
    soundServiceProvider.overrideWithValue(const SilentSoundService()),
    updaterProvider.overrideWithValue(const NoopUpdater()),
    friendsBackendProvider.overrideWithValue(FakeFriendsBackend(world, 'alice')),
  ],
  child: themed(const FriendsScreen()),
);

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('add a friend by code, accept a request, visit and block', (tester) async {
    setPhoneScreen(tester);
    final (db, world) = await setUpWorld(tester);
    await tester.pumpWidget(friendsApp(db, world));
    await settle(tester);

    expect(find.text('AAAA-2222'), findsOneWidget, reason: 'your code');
    expect(find.text('Carol'), findsOneWidget, reason: 'a request is waiting');
    expect(find.text('Bob'), findsOneWidget, reason: 'your friend');

    // Add Dave by code, typed loosely.
    await tester.enterText(find.byType(TextField), 'dddd 5555');
    await tester.tap(find.text('Add'));
    await settle(tester);
    expect(world.requests.containsKey('alice_dave'), isTrue);
    expect(find.text('Waiting for them to accept'), findsOneWidget);

    // Accept Carol.
    await tester.tap(find.byTooltip('Accept'));
    await settle(tester);
    expect(world.friends['alice']!.containsKey('carol'), isTrue);

    // Visit Bob: his garden, and the reward once.
    await tester.tap(find.widgetWithText(FilledButton, 'Visit').first);
    await settle(tester);
    expect(find.text("Bob's garden"), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Apple tree')), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    expect(find.textContaining('Thanks for visiting Bob'), findsOneWidget);
    final coins = await tester.runAsync(() => CountersRepository(db).get(CounterKeys.coins));
    expect(coins, visitRewardCoins);
    expect(world.visits['bob']!.length, 1, reason: 'Bob gets a visit note');

    // Block Carol.
    final carolCard = find.ancestor(of: find.text('Carol'), matching: find.byType(Row)).first;
    await tester.tap(find.descendant(of: carolCard, matching: find.byTooltip('More')));
    await settle(tester);
    await tester.tap(find.text('Block'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Block'));
    await settle(tester);
    expect(world.blocked['alice'], contains('carol'));
    expect(world.friends['alice']!.containsKey('carol'), isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('Friends and visit screens at ${(scale * 100).round()}% text', (tester) async {
      await loadAppFonts();
      setPhoneScreen(tester, textScale: scale);
      final (db, world) = await setUpWorld(tester);
      await tester.pumpWidget(shot(friendsApp(db, world)));
      await settle(tester);
      await savePng(tester, 'friends_${(scale * 100).round()}');
      await tester.tap(find.widgetWithText(FilledButton, 'Visit').first);
      await settle(tester);
      await savePng(tester, 'visit_${(scale * 100).round()}');
      expect(tester.takeException(), isNull);
    });
  }
}
