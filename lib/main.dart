import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'app_root.dart';
import 'config/config_loader.dart';
import 'core/accounts.dart';
import 'core/dev_mode.dart';
import 'core/firebase_setup.dart';
import 'features/friends/friends_backend.dart';
import 'features/friends/friends_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final config = await loadGameConfig();
  const store = AccountStore();
  final account = await store.read();

  // Put the owner's garden back if the old, in-place developer mode was left on.
  final own = openAccountDatabase(Account.main);
  await restoreOldDevSnapshot(own, await getApplicationSupportDirectory());
  if (account != Account.main) await own.close();

  final start = await openAccount(
    account,
    config,
    open: (a) => a == Account.main && account == Account.main ? own : openAccountDatabase(a),
  );
  final friendsReady = await startFirebase();

  runApp(
    AppRoot(
      config: config,
      start: start,
      open: openAccountDatabase,
      store: store,
      mainOnlyOverrides: [if (friendsReady) friendsBackendProvider.overrideWithValue(FirebaseFriendsBackend())],
    ),
  );
}
