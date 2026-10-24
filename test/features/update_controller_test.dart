import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/providers.dart';
import 'package:sprout/core/updater.dart';
import 'package:sprout/data/repositories/settings_repository.dart';
import 'package:sprout/domain/logic/updates.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/features/settings/update_controller.dart';

import '../widget/test_app.dart';

class FakeUpdater implements Updater {
  int build = 11;
  UpdateInfo? published = UpdateInfo(versionCode: 14, versionName: '0.1.0', sha256: 'a' * 64, size: 1000);
  bool allowed = true;
  int? free;
  UpdateFailure? downloadFails;
  File? ready;
  InstallEvent? lastResult;
  final installs = <File>[];
  final systemInstalls = <File>[];
  final eventSink = StreamController<InstallEvent>.broadcast();

  @override
  Future<int> currentBuild() async => build;
  @override
  Future<String> versionLabel() async => '0.1.0 (build $build)';
  @override
  Future<UpdateInfo> fetchInfo() async => published ?? (throw const UpdateFailure(UpdateError.offline));
  @override
  Future<int?> freeBytes() async => free;
  @override
  Future<File> download(UpdateInfo info, {void Function(double progress)? onProgress}) async {
    if (downloadFails != null) throw downloadFails!;
    onProgress?.call(0.5);
    onProgress?.call(1);
    return ready = File('update.apk');
  }

  @override
  Future<File?> downloaded(UpdateInfo info) async => ready;
  @override
  Future<bool> canInstall() async => allowed;
  @override
  Future<void> openInstallSettings() async {}
  @override
  Future<void> install(File apk) async => installs.add(apk);
  @override
  Future<void> openSystemInstaller(File apk) async => systemInstalls.add(apk);
  @override
  Stream<InstallEvent> get events => eventSink.stream;
  @override
  Future<InstallEvent?> takeLastResult() async => lastResult;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeUpdater updater;
  late ProviderContainer container;

  ProviderContainer make({AppSettings settings = const AppSettings()}) {
    final db = memoryDb();
    addTearDown(db.close);
    final c = ProviderContainer(
      overrides: [
        gameConfigProvider.overrideWithValue(testConfig),
        databaseProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(settings),
        updaterProvider.overrideWithValue(updater),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  UpdateController controller() => container.read(updateControllerProvider.notifier);
  UpdateState state() => container.read(updateControllerProvider);
  SettingsRepository repo() => container.read(settingsRepositoryProvider);

  setUp(() {
    updater = FakeUpdater();
    container = make();
  });

  test('says up to date with the build number', () async {
    updater.build = 14;
    await controller().check(manual: true);
    expect(state().phase, UpdatePhase.upToDate);
    expect(state().currentBuild, 14);
  });

  test('offers a newer build, then asks Android to install it', () async {
    await controller().check(manual: true);
    expect(state().phase, UpdatePhase.available);
    expect(state().info!.versionCode, 14);
    await controller().update();
    expect(updater.installs, hasLength(1));
    expect(state().phase, UpdatePhase.waitingForYou);
    expect(await repo().readValue(pendingUpdateBuildKey), '14');
  });

  test('install permission off: explains and installs nothing', () async {
    updater.allowed = false;
    await controller().check(manual: true);
    await controller().update();
    expect(state().phase, UpdatePhase.error);
    expect(state().error, UpdateError.permissionOff);
    expect(updater.installs, isEmpty);
    // Coming back from the setting with it switched on.
    updater.allowed = true;
    await controller().onReturn();
    expect(state().phase, UpdatePhase.available);
  });

  test('a failed checksum shows "Download failed" and installs nothing', () async {
    updater.downloadFails = const UpdateFailure(UpdateError.downloadFailed, 'checksum did not match');
    await controller().check(manual: true);
    await controller().update();
    expect(state().error, UpdateError.downloadFailed);
    expect(updater.installs, isEmpty);
  });

  test('not enough storage is caught before downloading', () async {
    updater.free = 10;
    await controller().check(manual: true);
    await controller().update();
    expect(state().error, UpdateError.noStorage);
    expect(updater.ready, isNull);
  });

  test('offline check says so', () async {
    updater.published = null;
    await controller().check(manual: true);
    expect(state().error, UpdateError.offline);
  });

  test('installer results arrive: cancelled, signed differently, success', () async {
    await controller().check(manual: true);
    await controller().update();
    updater.eventSink.add(const InstallEvent(InstallStatus.aborted));
    await pumpEventQueue();
    expect(state().error, UpdateError.cancelled);
    expect(await repo().readValue(pendingUpdateBuildKey), '');

    await controller().update();
    updater.eventSink.add(const InstallEvent(InstallStatus.failure, 'INSTALL_FAILED_UPDATE_INCOMPATIBLE'));
    await pumpEventQueue();
    expect(state().error, UpdateError.signedDifferently);

    await controller().update();
    updater.eventSink.add(const InstallEvent(InstallStatus.success));
    await pumpEventQueue();
    expect(state().phase, UpdatePhase.done);
  });

  test('coming back from the confirm screen shows installing, never before', () async {
    await controller().check(manual: true);
    await controller().update();
    await controller().onReturn();
    expect(state().phase, UpdatePhase.waitingForYou, reason: 'the app never left, so nothing was confirmed yet');
    controller().onLeave();
    await controller().onReturn();
    expect(state().phase, UpdatePhase.installing);
  });

  test('after an update, the next launch confirms the new build', () async {
    await repo().writeValue(pendingUpdateBuildKey, '14');
    updater.build = 14;
    await controller().afterLaunch();
    expect(state().phase, UpdatePhase.upToDate);
    expect(await repo().readValue(pendingUpdateBuildKey), '');
  });

  test('after a failed update, the next launch says why', () async {
    await repo().writeValue(pendingUpdateBuildKey, '14');
    updater.lastResult = const InstallEvent(InstallStatus.conflict);
    await controller().afterLaunch();
    expect(state().phase, UpdatePhase.error);
    expect(state().error, UpdateError.signedDifferently);
  });

  test('daily check downloads quietly and gets it ready to install', () async {
    await controller().check();
    expect(state().phase, UpdatePhase.ready);
    expect(updater.installs, isEmpty, reason: 'it asks first');
  });

  test('daily check respects the switch and runs once a day', () async {
    container = make(settings: const AppSettings(autoUpdate: false));
    await controller().check();
    expect(state().phase, UpdatePhase.idle);

    container = make();
    updater.build = 14;
    await controller().check();
    expect(state().phase, UpdatePhase.upToDate);
    updater.build = 11;
    await controller().check();
    expect(state().phase, UpdatePhase.upToDate, reason: 'already checked today');
  });

  test('the automatic updates switch stays as you set it', () async {
    await container.read(settingsProvider.notifier).update((s) => s.copyWith(autoUpdate: false));
    expect((await repo().load()).autoUpdate, isFalse);
    await controller().check(manual: true);
    expect((await repo().load()).autoUpdate, isFalse);
    await container.read(settingsProvider.notifier).update((s) => s.copyWith(autoUpdate: true));
    expect((await repo().load()).autoUpdate, isTrue);
  });
}
