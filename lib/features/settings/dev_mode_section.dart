import 'dart:async';

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
    final hash = ref.read(devPasswordHashProvider);
    // The dialog checks the password itself, and only closes when it's right.
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _PasswordDialog(hash: hash),
    );
    if (ok != true || !mounted) return;
    await ref.read(settingsRepositoryProvider).writeValue(devUnlockedKey, 'true');
    ref.invalidate(devUnlockedProvider);
    if (mounted) await openDevAccount(context, ref);
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

/// Opens the dev account (or resets it), with a little "Opening…" note, and
/// shows what went wrong if it can't.
Future<void> openDevAccount(BuildContext context, WidgetRef ref, {bool reset = false}) async {
  final switcher = ref.read(accountSwitcherProvider);
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
            SizedBox(width: 16),
            Expanded(child: Text('Opening the dev account...')),
          ],
        ),
      ),
    ),
  );
  try {
    await switcher(Account.dev, reset: reset);
  } catch (e) {
    if (navigator.mounted) {
      navigator.pop();
      await showDialog<void>(
        context: navigator.context,
        builder: (c) => AlertDialog(
          title: const Text("Couldn't open the dev account"),
          content: Text('$e'),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
        ),
      );
    }
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.hash});

  final String hash;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();
  bool _show = false;
  bool _wrong = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    // Spaces a keyboard adds by itself don't count.
    if (devPasswordMatches(_controller.text.trim(), hash: widget.hash)) {
      Navigator.pop(context, true);
    } else {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Developer mode'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      obscureText: !_show,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        hintText: 'Password',
        errorText: _wrong ? "That's not it. Capitals and symbols count." : null,
        errorMaxLines: 2,
        suffixIcon: IconButton(
          tooltip: _show ? 'Hide password' : 'Show password',
          icon: Icon(_show ? Icons.visibility_off_rounded : Icons.visibility_rounded),
          onPressed: () => setState(() => _show = !_show),
        ),
      ),
      onChanged: (_) {
        if (_wrong) setState(() => _wrong = false);
      },
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
      FilledButton(onPressed: _submit, child: const Text('Unlock')),
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
    if (ok == true && context.mounted) await openDevAccount(context, ref, reset: true);
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
                  FilledButton(onPressed: () => openDevAccount(context, ref), child: const Text('Open dev account')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
