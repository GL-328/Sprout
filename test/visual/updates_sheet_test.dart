import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/providers.dart';
import 'package:sprout/core/updater.dart';
import 'package:sprout/domain/logic/updates.dart';
import 'package:sprout/features/settings/update_controller.dart';
import 'package:sprout/features/settings/updates_section.dart';

import 'render.dart';

/// Renders every step of an update, to check the wording and layout by eye.
void main() {
  const info = UpdateInfo(versionCode: 15, versionName: '0.1.0', sha256: '', size: 68000000);
  final states = <UpdateState>[
    const UpdateState(phase: UpdatePhase.upToDate, currentBuild: 15),
    const UpdateState(phase: UpdatePhase.available, currentBuild: 14, info: info),
    const UpdateState(phase: UpdatePhase.downloading, currentBuild: 14, info: info, progress: 0.42),
    const UpdateState(phase: UpdatePhase.verifying, currentBuild: 14, info: info),
    const UpdateState(phase: UpdatePhase.waitingForYou, currentBuild: 14, info: info),
    const UpdateState(phase: UpdatePhase.installing, currentBuild: 14, info: info),
    const UpdateState(phase: UpdatePhase.done, currentBuild: 14, info: info),
    for (final e in UpdateError.values) UpdateState(phase: UpdatePhase.error, currentBuild: 14, info: info, error: e),
  ];

  for (final scale in [1.0, 1.3]) {
    testWidgets('update states at ${scale}x text', (tester) async {
      await loadAppFonts();
      setPhoneScreen(tester, size: Size(360, scale == 1 ? 1900 : 2500), textScale: scale);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [updaterProvider.overrideWithValue(const NoopUpdater())],
          child: themed(
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (final s in states) ...[UpdateStatusCard(state: s), const SizedBox(height: 8)],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await savePng(tester, 'updates_${(scale * 100).round()}');
    });
  }
}
