import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/updater.dart';
import '../../domain/logic/updates.dart';

/// App-wide messenger, so update news can show on any screen.
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Checks for an update and installs it. Automatic checks ([manual] false)
/// respect the setting and run at most once a day; they stay quiet unless an
/// update is actually installing.
Future<UpdateResult> runUpdateCheck(WidgetRef ref, {bool manual = false}) async {
  final settings = ref.read(settingsRepositoryProvider);
  final clock = ref.read(clockProvider);
  if (!manual) {
    if (!ref.read(settingsProvider).autoUpdate) return UpdateResult.upToDate;
    final last = DateTime.tryParse(await settings.readValue(lastUpdateCheckKey) ?? '');
    if (!shouldCheck(last, clock.now())) return UpdateResult.upToDate;
  }
  final result = await ref.read(updaterProvider).checkAndInstall();
  if (result != UpdateResult.failed && result != UpdateResult.unsupported) {
    await settings.writeValue(lastUpdateCheckKey, clock.now().toIso8601String());
  }
  final message = switch (result) {
    UpdateResult.installing => 'A new version of Sprout is installing 🌱 Your garden comes with it.',
    UpdateResult.needsPermission => 'A new version is ready. Allow Sprout to install updates in Settings.',
    UpdateResult.upToDate => manual ? "You're on the newest version 🌷" : null,
    UpdateResult.failed => manual ? "Couldn't check for updates right now. Maybe later." : null,
    UpdateResult.unsupported => manual ? 'Automatic updates only work on Android.' : null,
  };
  if (message != null) {
    rootMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }
  return result;
}
