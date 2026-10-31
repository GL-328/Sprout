import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/db/app_database.dart';

/// Whose garden is open: the owner's own, or a separate one for testing.
/// Each has its own database, so nothing done in one touches the other.
enum Account {
  main('sprout'),
  dev('sprout_dev');

  const Account(this.databaseName);

  final String databaseName;
}

/// Opens [account]'s own database.
AppDatabase openAccountDatabase(Account account) => AppDatabase(driftDatabase(name: account.databaseName));

/// Remembers which account was open last, in a tiny file outside both
/// databases.
class AccountStore {
  const AccountStore([this._directory = getApplicationSupportDirectory]);

  final Future<Directory> Function() _directory;

  Future<File> get _file async => File('${(await _directory()).path}/account.txt');

  Future<Account> read() async {
    try {
      final text = (await (await _file).readAsString()).trim();
      return Account.values.firstWhere((a) => a.name == text, orElse: () => Account.main);
    } on FileSystemException {
      return Account.main;
    }
  }

  Future<void> write(Account account) async => (await _file).writeAsString(account.name, flush: true);
}

/// Which account is open. Overridden by the app root.
final activeAccountProvider = Provider<Account>((ref) => Account.main);

/// Switches to [to]. With [reset], [to]'s garden is wiped and set up afresh
/// first. Overridden by the app root; a no-op in tests that don't need it.
typedef AccountSwitcher = Future<void> Function(Account to, {bool reset});

final accountSwitcherProvider = Provider<AccountSwitcher>((ref) => (to, {reset = false}) async {});
