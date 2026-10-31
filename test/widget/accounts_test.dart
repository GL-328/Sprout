import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/app_root.dart';
import 'package:sprout/core/accounts.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/core/dev_mode.dart';
import 'package:sprout/core/notifications_service.dart';
import 'package:sprout/core/providers.dart';
import 'package:sprout/core/sound_service.dart';
import 'package:sprout/core/updater.dart';
import 'package:sprout/data/db/app_database.dart';
import 'package:sprout/data/repositories/counters_repository.dart';
import 'package:sprout/data/repositories/settings_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';

import 'test_app.dart';

/// Remembers the open account in memory: real file writes never finish
/// inside the test's fake clock.
class _MemoryStore extends AccountStore {
  Account last = Account.main;

  @override
  Future<Account> read() async => last;

  @override
  Future<void> write(Account account) async => last = account;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('the dev account is a separate garden, and the real one is untouched', (tester) async {
    final dir = await tester.runAsync(() => Directory.systemTemp.createTemp('sprout_accounts'));
    addTearDown(() => dir!.delete(recursive: true));
    final opened = <AppDatabase>[];
    AppDatabase open(Account a) {
      final db = AppDatabase(
        DatabaseConnection(
          NativeDatabase(File('${dir!.path}/${a.databaseName}.sqlite')),
          closeStreamsSynchronously: true,
        ),
      );
      opened.add(db);
      return db;
    }

    addTearDown(() async {
      for (final db in opened) {
        await db.close();
      }
    });

    final store = _MemoryStore();
    final start = await tester.runAsync(() async {
      final first = await openAccount(Account.main, testConfig, open: open);
      final settings = SettingsRepository(first.db);
      await settings.save(const AppSettings(name: 'Sam', onboardingDone: true, reducedMotion: true));
      await settings.writeValue(devUnlockedKey, 'true');
      await CountersRepository(first.db).add(CounterKeys.coins, 42);
      return (account: Account.main, db: first.db, settings: await settings.load());
    });

    await tester.pumpWidget(
      AppRoot(
        config: testConfig,
        start: start!,
        open: open,
        store: store,
        overrides: [
          clockProvider.overrideWithValue(const Clock()),
          reminderSchedulerProvider.overrideWithValue(const NoopReminderScheduler()),
          soundServiceProvider.overrideWithValue(const SilentSoundService()),
          updaterProvider.overrideWithValue(const NoopUpdater()),
        ],
      ),
    );
    await settle(tester);
    expect(find.text('Dev account'), findsNothing);
    expect(find.text('42'), findsWidgets);

    // Into the dev account, from Settings.
    await tester.tap(find.text('Settings').last);
    await settle(tester);
    await tester.tap(find.text('Open dev account'));
    await settle(tester);
    expect(find.text('Dev account'), findsOneWidget, reason: 'the badge on Home');
    expect(find.text('${DevAccount.coins}'), findsWidgets);
    expect(store.last, Account.dev);

    // Spend some dev coins, then go back.
    await tester.runAsync(() async {
      final dev = opened.last;
      await CountersRepository(dev).add(CounterKeys.coins, -1000);
    });
    await tester.tap(find.text('Settings').last);
    await settle(tester);
    await tester.tap(find.text('Back to my garden'));
    await settle(tester);
    expect(find.text('Dev account'), findsNothing);
    expect(find.text('42'), findsWidgets, reason: 'the real garden kept its own coins');
    expect(store.last, Account.main);
  });

  testWidgets('7 taps on Version and the password open the dev account', (tester) async {
    final dir = await tester.runAsync(() => Directory.systemTemp.createTemp('sprout_accounts'));
    addTearDown(() => dir!.delete(recursive: true));
    final opened = <AppDatabase>[];
    AppDatabase open(Account a) {
      final db = AppDatabase(
        DatabaseConnection(
          NativeDatabase(File('${dir!.path}/${a.databaseName}.sqlite')),
          closeStreamsSynchronously: true,
        ),
      );
      opened.add(db);
      return db;
    }

    addTearDown(() async {
      for (final db in opened) {
        await db.close();
      }
    });
    const password = 'test-only password';
    final store = _MemoryStore();
    final start = await tester.runAsync(() async {
      final first = await openAccount(Account.main, testConfig, open: open);
      final settings = SettingsRepository(first.db);
      await settings.save(const AppSettings(name: 'Sam', onboardingDone: true, reducedMotion: true));
      return (account: Account.main, db: first.db, settings: await settings.load());
    });
    await tester.pumpWidget(
      AppRoot(
        config: testConfig,
        start: start!,
        open: open,
        store: store,
        overrides: [
          devPasswordHashProvider.overrideWithValue(sha256.convert(utf8.encode(password)).toString()),
          reminderSchedulerProvider.overrideWithValue(const NoopReminderScheduler()),
          soundServiceProvider.overrideWithValue(const SilentSoundService()),
          updaterProvider.overrideWithValue(const NoopUpdater()),
        ],
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Settings').last);
    await settle(tester);
    await tester.scrollUntilVisible(find.text('About Sprout'), 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('About Sprout'));
    await settle(tester);
    final version = find.textContaining('Version');
    await tester.scrollUntilVisible(version, 200, scrollable: find.byType(Scrollable).last);
    for (var i = 0; i < 7; i++) {
      await tester.tap(version);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await settle(tester);
    // A keyboard's stray trailing space doesn't count.
    await tester.enterText(find.byType(TextField), '$password ');
    await tester.tap(find.text('Unlock'));
    await settle(tester);
    expect(store.last, Account.dev);
    expect(find.text('Dev account'), findsOneWidget);
  });
}
