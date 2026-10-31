import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/accounts.dart';
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
    if (ref.read(activeAccountProvider) == Account.dev) {
      _say(context, "You're in the dev account. Settings has the way back to your garden.");
      return;
    }
    final password = await showDialog<String>(context: context, builder: (_) => const _PasswordDialog());
    if (password == null || !mounted) return;
    if (!devPasswordMatches(password)) {
      _say(context, "That's not it.");
      return;
    }
    await ref.read(settingsRepositoryProvider).writeValue(devUnlockedKey, 'true');
    ref.invalidate(devUnlockedProvider);
    await ref.read(accountSwitcherProvider)(Account.dev);
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

/// At the top of Settings: in the dev account, the way back and a reset; in
/// the owner's own account (once unlocked), the way into the dev account.
class DevModeCard extends ConsumerWidget {
  const DevModeCard({super.key});

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reset the dev account?'),
        content: const Text(
          'The dev garden starts again from scratch: every plot unlocked, 5,000 coins and a few seeds. '
          'Your own garden is not touched.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true) await ref.read(accountSwitcherProvider)(Account.dev, reset: true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dev = ref.watch(activeAccountProvider) == Account.dev;
    if (!dev && ref.watch(devUnlockedProvider).value != true) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final switcher = ref.read(accountSwitcherProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SoftCard(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dev ? "You're in the dev account" : 'Developer', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              dev
                  ? 'A separate garden for testing. Nothing here touches your own garden.'
                  : 'A separate dev garden for testing, with every plot unlocked. Your own garden stays as it is.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                if (dev) ...[
                  FilledButton(onPressed: () => switcher(Account.main), child: const Text('Back to my garden')),
                  OutlinedButton(onPressed: () => _reset(context, ref), child: const Text('Reset dev account')),
                ] else
                  FilledButton(onPressed: () => switcher(Account.dev), child: const Text('Open dev account')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
