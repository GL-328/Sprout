import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/logic/updates.dart';
import 'update_controller.dart';

final _versionProvider = FutureProvider<String>((ref) => ref.watch(updaterProvider).versionLabel());

/// Automatic updates: the switch, the current version and every step of an
/// update, with what to do next.
class UpdatesSection extends ConsumerWidget {
  const UpdatesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final on = ref.watch(settingsProvider.select((s) => s.autoUpdate));
    final version = ref.watch(_versionProvider).value ?? '';
    final update = ref.watch(updateControllerProvider);
    final controller = ref.read(updateControllerProvider.notifier);
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Automatic updates'),
          subtitle: const Text(
            'Once a day, check GitHub for a new version and download it. Android asks you to confirm '
            'each install, so Sprout will ask before updating. This is the only time Sprout goes online.',
          ),
          value: on,
          onChanged: (v) => ref.read(settingsProvider.notifier).update((s) => s.copyWith(autoUpdate: v)),
        ),
        ListTile(
          title: const Text('Check for updates now'),
          subtitle: Text(version.isEmpty ? '' : 'Version $version', style: theme.textTheme.bodySmall),
          trailing: update.phase == UpdatePhase.checking
              ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
              : const Icon(Icons.system_update_alt),
          onTap: update.busy ? null : () => controller.check(manual: true),
        ),
        if (update.phase != UpdatePhase.idle && update.phase != UpdatePhase.checking)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: UpdateStatusCard(state: update),
          ),
      ],
    );
  }
}

/// One update step, in calm words, with the button for what comes next.
class UpdateStatusCard extends ConsumerWidget {
  const UpdateStatusCard({super.key, required this.state});

  final UpdateState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final c = ref.read(updateControllerProvider.notifier);
    final build = state.info?.versionCode;
    final percent = (state.progress * 100).round();
    final (String title, String? body) = switch (state.phase) {
      UpdatePhase.idle || UpdatePhase.checking => ('Checking for updates…', null),
      UpdatePhase.upToDate => ("You're up to date (build ${state.currentBuild})", null),
      UpdatePhase.available => ('Build $build available', 'You have build ${state.currentBuild}.'),
      UpdatePhase.downloading => ('Downloading build $build… $percent%', null),
      UpdatePhase.verifying => ('Verifying the download…', null),
      UpdatePhase.ready => ('Build $build is downloaded', 'Ready when you are.'),
      UpdatePhase.waitingForYou => ('Tap Update on the next screen', 'Android asks you to confirm each update.'),
      UpdatePhase.installing => (
        'Installing…',
        'Sprout closes when the update is done. Open it again from your home screen.',
      ),
      UpdatePhase.done => ('Done, reopen Sprout', 'Your garden comes with it.'),
      UpdatePhase.error => (updateErrorText(state.error ?? UpdateError.other), null),
    };
    final actions = <Widget>[
      if (state.phase == UpdatePhase.available || state.phase == UpdatePhase.ready)
        FilledButton(onPressed: c.update, child: const Text('Update')),
      if (state.phase == UpdatePhase.error)
        ...switch (state.error) {
          UpdateError.permissionOff => [
            FilledButton(onPressed: c.openInstallSettings, child: const Text('Open setting')),
            TextButton(onPressed: c.update, child: const Text('Try again')),
          ],
          UpdateError.offline => [TextButton(onPressed: () => c.check(manual: true), child: const Text('Try again'))],
          UpdateError.cancelled => [
            FilledButton(onPressed: c.update, child: const Text('Try again')),
            TextButton(onPressed: c.openSystemInstaller, child: const Text("Open in Android's installer")),
          ],
          UpdateError.downloadFailed ||
          UpdateError.noStorage => [FilledButton(onPressed: c.update, child: const Text('Try again'))],
          UpdateError.blocked || UpdateError.other => [
            FilledButton(onPressed: c.openSystemInstaller, child: const Text("Open in Android's installer")),
            TextButton(onPressed: c.update, child: const Text('Try again')),
          ],
          _ => const <Widget>[],
        },
    ];
    final error = state.phase == UpdatePhase.error;
    return Material(
      key: const ValueKey('update-status'),
      color: error ? theme.colorScheme.errorContainer.withValues(alpha: 0.5) : theme.colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            if (body != null) ...[const SizedBox(height: 2), Text(body, style: theme.textTheme.bodySmall)],
            if (error && state.detail != null) ...[
              const SizedBox(height: 4),
              SelectableText(
                'Android said: ${state.detail}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            if (state.phase == UpdatePhase.downloading || state.phase == UpdatePhase.verifying) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: state.phase == UpdatePhase.verifying ? null : state.progress,
                ),
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Theme(
                data: theme.copyWith(
                  filledButtonTheme: FilledButtonThemeData(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                  ),
                ),
                child: Wrap(spacing: 8, runSpacing: 4, children: actions),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
