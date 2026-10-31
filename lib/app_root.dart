import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'app.dart';
import 'config/game_config.dart';
import 'core/accounts.dart';
import 'core/clock.dart';
import 'core/dev_mode.dart';
import 'core/providers.dart';
import 'data/db/app_database.dart';
import 'data/repositories/seed_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/backup_service.dart';
import 'domain/models/app_settings.dart';

/// Everything an account needs to start: its database and its settings.
typedef OpenedAccount = ({Account account, AppDatabase db, AppSettings settings});

/// Opens [account]: its own database, set up if it's a new dev account (or
/// wiped and set up again with [reset]), with the starting plot ready.
/// [current] is the settings of the account being left, for the dev
/// account's look and sound.
Future<OpenedAccount> openAccount(
  Account account,
  GameConfig config, {
  required AppDatabase Function(Account) open,
  AppSettings current = const AppSettings(),
  bool reset = false,
}) async {
  final db = open(account);
  if (account == Account.dev) {
    if (reset) await BackupService(db, const Clock()).deleteAll();
    if (!(await SettingsRepository(db).load()).onboardingDone) await DevAccount.seed(db, config, current);
  }
  await SeedRepository(db, const Clock()).ensurePlot(config.startingEnvironment.id);
  return (account: account, db: db, settings: await SettingsRepository(db).load());
}

/// Holds the open account and swaps the whole app over to another one: a fresh
/// [ProviderScope] on the other account's database, so nothing carries across.
class AppRoot extends StatefulWidget {
  const AppRoot({
    super.key,
    required this.config,
    required this.start,
    required this.open,
    this.store = const AccountStore(),
    this.overrides = const [],
    this.mainOnlyOverrides = const [],
  });

  final GameConfig config;
  final OpenedAccount start;
  final AppDatabase Function(Account) open;
  final AccountStore store;

  /// Overrides for every account (and tests).
  final List<Override> overrides;

  /// Overrides only for the owner's own account, like Friends.
  final List<Override> mainOnlyOverrides;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late OpenedAccount _open = widget.start;
  var _generation = 0;

  Future<void> _switch(Account to, {bool reset = false}) async {
    final leaving = _open;
    final next = await openAccount(to, widget.config, open: widget.open, current: leaving.settings, reset: reset);
    await widget.store.write(to);
    if (!mounted) return;
    setState(() {
      _open = next;
      _generation++;
    });
    // Closed after the old app has gone, so nothing reads a closed database.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!identical(leaving.db, next.db)) leaving.db.close();
    });
  }

  @override
  Widget build(BuildContext context) => ProviderScope(
    key: ValueKey(_generation),
    overrides: [
      gameConfigProvider.overrideWithValue(widget.config),
      databaseProvider.overrideWithValue(_open.db),
      initialSettingsProvider.overrideWithValue(_open.settings),
      activeAccountProvider.overrideWithValue(_open.account),
      accountSwitcherProvider.overrideWithValue(_switch),
      ...widget.overrides,
      if (_open.account == Account.main) ...widget.mainOnlyOverrides,
    ],
    child: const SproutApp(),
  );
}
