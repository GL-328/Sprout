import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dev_mode.dart';
import '../../core/providers.dart';
import '../../ui/widgets/soft_card.dart';

void _say(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

/// The app's version, at the bottom of About. Tapping it seven times asks for
/// the developer password.
class BuildLine extends ConsumerStatefulWidget {
  const BuildLine({super.key});

  @override
  ConsumerState<BuildLine> createState() => _BuildLineState();
}

class _BuildLineState extends ConsumerState<BuildLine> {
  static const _taps = 7;
  late final _label = ref.read(updaterProvider).versionLabel();
  int _count = 0;

  Future<void> _tap() async {
    if (++_count < _taps) return;
    _count = 0;
    if (await ref.read(devModeServiceProvider).isOn()) {
      if (mounted) _say(context, 'Developer mode is on. You can reset it in Settings.');
      return;
    }
    if (!mounted) return;
    final password = await showDialog<String>(context: context, builder: (_) => const _PasswordDialog());
    if (password == null || !mounted) return;
    final ok = await ref.read(devModeServiceProvider).enable(password);
    ref.invalidate(devModeProvider);
    if (mounted) _say(context, ok ? 'Developer mode is on. Every plot is unlocked.' : "That's not it.");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _tap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: FutureBuilder<String>(
          future: _label,
          builder: (context, snap) => Text(
            'Version ${snap.data ?? ''}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Developer mode'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      obscureText: true,
      autocorrect: false,
      enableSuggestions: false,
      decoration: const InputDecoration(hintText: 'Password'),
      onSubmitted: (v) => Navigator.pop(context, v),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('Unlock')),
    ],
  );
}

/// Shown at the top of Settings while developer mode is on.
class DevModeCard extends ConsumerWidget {
  const DevModeCard({super.key});

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reset and turn off?'),
        content: const Text(
          'Your garden goes back to exactly how it was before developer mode: plots, plants, coins, seeds '
          'and quests. Anything done since then is undone too.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(devModeServiceProvider).reset();
    await ref.read(gardenServiceProvider).ensureStartingPlot();
    await ref.read(settingsProvider.notifier).reload();
    ref.invalidate(reminderSyncProvider);
    ref.invalidate(devModeProvider);
    if (context.mounted) _say(context, 'Developer mode is off. Your garden is back as it was.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(devModeProvider).value != true) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SoftCard(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Developer mode', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'All plots are unlocked for testing. Reset puts your garden back to how it was before.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => _reset(context, ref), child: const Text('Reset and turn off')),
          ],
        ),
      ),
    );
  }
}
