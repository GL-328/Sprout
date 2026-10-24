import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/updater.dart';
import '../../domain/logic/updates.dart';

/// App-wide messenger, so update news can show on any screen.
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Settings key for the build an install was started for, so the next launch
/// can tell whether it worked.
const pendingUpdateBuildKey = 'pending_update_build';

enum UpdatePhase {
  idle,
  checking,
  upToDate,
  available,
  downloading,
  verifying,

  /// Downloaded and verified, waiting for the user to say go.
  ready,

  /// Android's confirm screen is up (or about to be).
  waitingForYou,
  installing,
  done,
  error,
}

class UpdateState {
  const UpdateState({this.phase = UpdatePhase.idle, this.currentBuild, this.info, this.progress = 0, this.error});

  final UpdatePhase phase;
  final int? currentBuild;

  /// The newer build, once one is found.
  final UpdateInfo? info;

  /// Download progress, 0 to 1.
  final double progress;
  final UpdateError? error;

  bool get busy => switch (phase) {
    UpdatePhase.checking ||
    UpdatePhase.downloading ||
    UpdatePhase.verifying ||
    UpdatePhase.waitingForYou ||
    UpdatePhase.installing => true,
    _ => false,
  };

  UpdateState to(UpdatePhase phase, {UpdateInfo? info, double? progress, UpdateError? error, int? currentBuild}) =>
      UpdateState(
        phase: phase,
        currentBuild: currentBuild ?? this.currentBuild,
        info: info ?? this.info,
        progress: progress ?? (phase == UpdatePhase.downloading ? this.progress : 0),
        error: error,
      );
}

final updateControllerProvider = NotifierProvider<UpdateController, UpdateState>(UpdateController.new);

/// Checks, downloads and installs updates, one clear step at a time.
class UpdateController extends Notifier<UpdateState> {
  StreamSubscription<InstallEvent>? _events;
  Timer? _stall;
  File? _apk;
  bool _leftApp = false;

  /// How long to wait for Android after the confirm screen before offering
  /// the fallback.
  static const stallTimeout = Duration(seconds: 45);

  Updater get _updater => ref.read(updaterProvider);

  @override
  UpdateState build() {
    _events = ref.watch(updaterProvider).events.listen(_onInstallEvent);
    ref.onDispose(() {
      _events?.cancel();
      _stall?.cancel();
    });
    return const UpdateState();
  }

  /// Looks for a newer build. Automatic checks ([manual] false) follow the
  /// setting, run at most once a day, stay quiet, and download the update in
  /// the background so it's ready to install.
  Future<void> check({bool manual = false}) async {
    if (state.busy) return;
    final settings = ref.read(settingsRepositoryProvider);
    final clock = ref.read(clockProvider);
    if (!manual) {
      if (!ref.read(settingsProvider).autoUpdate) return;
      final last = DateTime.tryParse(await settings.readValue(lastUpdateCheckKey) ?? '');
      if (!shouldCheck(last, clock.now())) return;
    }
    state = state.to(UpdatePhase.checking);
    final int current;
    final UpdateInfo info;
    try {
      current = await _updater.currentBuild();
      info = await _updater.fetchInfo();
    } on UpdateFailure catch (e) {
      state = manual ? state.to(UpdatePhase.error, error: e.error) : state.to(UpdatePhase.idle);
      return;
    }
    await settings.writeValue(lastUpdateCheckKey, clock.now().toIso8601String());
    if (!isNewer(current, info)) {
      state = state.to(UpdatePhase.upToDate, currentBuild: current);
      return;
    }
    state = state.to(UpdatePhase.available, info: info, currentBuild: current);
    if (manual) return;

    // Quietly get it ready, then ask gently.
    final file = await _prepare(info, quiet: true);
    if (file == null) return;
    _say(
      'Build ${info.versionCode} of Sprout is ready to install.',
      action: SnackBarAction(label: 'Install', onPressed: update),
      long: true,
    );
  }

  /// The "Update" button: downloads if needed, then installs.
  Future<void> update() async {
    final info = state.info;
    if (info == null || state.busy) return;
    if (!await _updater.canInstall()) {
      state = state.to(UpdatePhase.error, error: UpdateError.permissionOff);
      return;
    }
    final file = await _prepare(info);
    if (file == null) return;
    await ref.read(settingsRepositoryProvider).writeValue(pendingUpdateBuildKey, '${info.versionCode}');
    _leftApp = false;
    state = state.to(UpdatePhase.waitingForYou);
    try {
      await _updater.install(file);
    } on UpdateFailure catch (e) {
      await _clearPending();
      state = state.to(UpdatePhase.error, error: e.error);
    }
  }

  /// Opens the update in Android's own installer, for when the normal way
  /// didn't work.
  Future<void> openSystemInstaller() async {
    final info = state.info;
    final file = _apk ?? (info == null ? null : await _updater.downloaded(info));
    if (file == null) return update();
    try {
      if (info != null) {
        await ref.read(settingsRepositoryProvider).writeValue(pendingUpdateBuildKey, '${info.versionCode}');
      }
      await _updater.openSystemInstaller(file);
    } on UpdateFailure catch (e) {
      state = state.to(UpdatePhase.error, error: e.error);
    }
  }

  Future<void> openInstallSettings() => _updater.openInstallSettings();

  /// Call when the app goes to the background.
  void onLeave() {
    if (state.phase == UpdatePhase.waitingForYou) _leftApp = true;
  }

  /// Call when the app comes back to the front.
  Future<void> onReturn() async {
    if (state.phase == UpdatePhase.waitingForYou && _leftApp) {
      // Back from the confirm screen. Android now installs, or tells us why not.
      state = state.to(UpdatePhase.installing);
      _stall?.cancel();
      _stall = Timer(stallTimeout, () {
        if (state.phase == UpdatePhase.installing) state = state.to(UpdatePhase.error, error: UpdateError.other);
      });
    } else if (state.phase == UpdatePhase.error && state.error == UpdateError.permissionOff) {
      if (await _updater.canInstall()) state = state.to(UpdatePhase.available);
    }
  }

  /// Call once at start-up: says whether the last update worked.
  Future<void> afterLaunch() async {
    final settings = ref.read(settingsRepositoryProvider);
    final expected = int.tryParse(await settings.readValue(pendingUpdateBuildKey) ?? '');
    final last = await _updater.takeLastResult();
    final current = await _updater.currentBuild();
    switch (checkAfterLaunch(expectedBuild: expected, currentBuild: current)) {
      case LaunchCheck.none:
        break;
      case LaunchCheck.updated:
        await _clearPending();
        state = state.to(UpdatePhase.upToDate, currentBuild: current);
        _say('Sprout is updated to build $current. Your garden came along.');
      case LaunchCheck.notInstalled:
        await _clearPending();
        final error = (last == null ? null : installError(last.status, last.message)) ?? UpdateError.other;
        state = state.to(UpdatePhase.error, error: error, currentBuild: current);
        _say("The update to build $expected didn't finish. ${updateErrorText(error)}");
    }
  }

  Future<File?> _prepare(UpdateInfo info, {bool quiet = false}) async {
    final existing = await _updater.downloaded(info);
    if (existing != null) {
      _apk = existing;
      state = state.to(UpdatePhase.ready);
      return existing;
    }
    final size = info.size;
    final free = await _updater.freeBytes();
    if (size != null && free != null && free < spaceNeeded(size)) {
      state = quiet ? state.to(UpdatePhase.available) : state.to(UpdatePhase.error, error: UpdateError.noStorage);
      return null;
    }
    state = state.to(UpdatePhase.downloading, progress: 0);
    try {
      final file = await _updater.download(
        info,
        onProgress: (p) =>
            state = p >= 1 ? state.to(UpdatePhase.verifying) : state.to(UpdatePhase.downloading, progress: p),
      );
      _apk = file;
      state = state.to(UpdatePhase.ready);
      return file;
    } on UpdateFailure catch (e) {
      state = quiet ? state.to(UpdatePhase.available) : state.to(UpdatePhase.error, error: e.error);
      return null;
    }
  }

  void _onInstallEvent(InstallEvent e) {
    if (e.status == InstallStatus.pendingUserAction) {
      state = state.to(UpdatePhase.waitingForYou);
      return;
    }
    _stall?.cancel();
    final error = installError(e.status, e.message);
    if (error == null) {
      state = state.to(UpdatePhase.done);
    } else {
      _clearPending();
      state = state.to(UpdatePhase.error, error: error);
    }
  }

  Future<void> _clearPending() => ref.read(settingsRepositoryProvider).writeValue(pendingUpdateBuildKey, '');

  void _say(String text, {SnackBarAction? action, bool long = false}) {
    rootMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(text),
        action: action,
        duration: Duration(seconds: long ? 12 : 5),
      ),
    );
  }
}

/// A calm explanation of [error], with what to do next.
String updateErrorText(UpdateError error) => switch (error) {
  UpdateError.offline => "Couldn't reach GitHub. Try again when you're online.",
  UpdateError.noStorage => 'Not enough storage. Free up a little space, then try again.',
  UpdateError.permissionOff =>
    'Install permission is off. Allow Sprout to install apps, then come back and tap Update.',
  UpdateError.downloadFailed => 'Download failed, try again.',
  UpdateError.cancelled => 'Update was cancelled. You can update whenever you like.',
  UpdateError.signedDifferently =>
    "Couldn't install: signed differently from the Sprout on this phone. Export your data, "
        'uninstall Sprout, then install the newest APK from the GitHub Releases page.',
  UpdateError.blocked => 'Android blocked the install. Try opening it in Android\'s installer, or check Play Protect.',
  UpdateError.incompatible => "Couldn't install: this build doesn't fit this phone.",
  UpdateError.other => "Couldn't install the update. Try opening it in Android's installer.",
};
