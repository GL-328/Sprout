import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'update_check.dart';

final _versionProvider = FutureProvider<String>((ref) => ref.watch(updaterProvider).versionLabel());
final _canInstallProvider = FutureProvider<bool>((ref) => ref.watch(updaterProvider).canInstall());

/// Automatic updates: the switch, the current version and a manual check.
class UpdatesSection extends ConsumerStatefulWidget {
  const UpdatesSection({super.key});

  @override
  ConsumerState<UpdatesSection> createState() => _UpdatesSectionState();
}

class _UpdatesSectionState extends ConsumerState<UpdatesSection> {
  bool _checking = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final on = ref.watch(settingsProvider.select((s) => s.autoUpdate));
    final version = ref.watch(_versionProvider).value ?? '';
    final canInstall = ref.watch(_canInstallProvider).value ?? true;
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Automatic updates'),
          subtitle: const Text(
            'Once a day, check GitHub for a new version and install it. This is the only time Sprout goes online.',
          ),
          value: on,
          onChanged: (v) => ref.read(settingsProvider.notifier).update((s) => s.copyWith(autoUpdate: v)),
        ),
        if (!canInstall)
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: const Text('Allow Sprout to install updates'),
            subtitle: const Text('A one-time Android permission, so new versions can install themselves.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await ref.read(updaterProvider).openInstallSettings();
              ref.invalidate(_canInstallProvider);
            },
          ),
        ListTile(
          title: const Text('Check for updates now'),
          subtitle: Text(version.isEmpty ? '' : 'Version $version', style: theme.textTheme.bodySmall),
          trailing: _checking
              ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
              : const Icon(Icons.system_update_alt),
          onTap: _checking
              ? null
              : () async {
                  setState(() => _checking = true);
                  await runUpdateCheck(ref, manual: true);
                  ref.invalidate(_canInstallProvider);
                  if (mounted) setState(() => _checking = false);
                },
        ),
      ],
    );
  }
}
