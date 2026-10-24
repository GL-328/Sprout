import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/logic/friends.dart';
import 'friends_controller.dart';

/// Exactly what Friends shares, shown before anyone turns it on.
const friendsPrivacyText =
    'Friends is optional and off unless you turn it on. When it is on, Sprout shares '
    'only your display name, your friend code, who your friends are, and a picture of your '
    'garden: your plots, what grows in each spot and how far along it is, and your decorations. '
    'Your quests, moods, notes, helpful contacts and history never leave this phone. '
    'Turning Friends off deletes what was shared.';

/// Settings → Friends: opt in or out, your code and your display name.
class FriendsSection extends ConsumerWidget {
  const FriendsSection({super.key, this.onOpenFriends});

  /// Opens the Friends screen, once Friends is on.
  final VoidCallback? onOpenFriends;

  void _say(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<String?> _askName(BuildContext context, String initial) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        scrollable: true,
        title: const Text('Your name for friends'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('A first name or nickname. Friends see this, nothing else about you.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 20,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Your name'),
              onSubmitted: (v) => Navigator.pop(dialog, v),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(dialog, controller.text), child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _turnOn(BuildContext context, WidgetRef ref) async {
    final initial = ref.read(friendsProvider).name.isNotEmpty
        ? ref.read(friendsProvider).name
        : ref.read(settingsProvider).name;
    final name = await _askName(context, initial);
    if (name == null || !context.mounted) return;
    final result = await ref.read(friendsProvider.notifier).turnOn(name);
    if (context.mounted) _say(context, result.message);
  }

  Future<void> _turnOff(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        scrollable: true,
        title: const Text('Turn off Friends?'),
        content: const Text(
          'Your friend code, friends list and shared garden picture will be deleted. '
          'Your own garden stays exactly as it is.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Keep Friends')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Turn off')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final result = await ref.read(friendsProvider.notifier).turnOff();
    if (context.mounted) _say(context, result.message);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = ref.watch(friendsProvider);
    final small = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    if (!s.available) {
      return const ListTile(
        leading: Icon(Icons.people_outline_rounded),
        title: Text('Friends'),
        subtitle: Text('Not set up in this version yet. Everything else works as usual.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(friendsPrivacyText, style: small),
        ),
        SwitchListTile(
          title: const Text('Friends'),
          subtitle: Text(s.on ? 'On. Visit friends’ gardens and let them visit yours.' : 'Off'),
          value: s.on,
          onChanged: !s.loaded ? null : (v) => v ? _turnOn(context, ref) : _turnOff(context, ref),
        ),
        if (s.on) ...[
          ListTile(
            leading: const Icon(Icons.qr_code_2_rounded),
            title: const Text('Your friend code'),
            subtitle: Text(
              s.code == null ? 'Getting your code…' : formatFriendCode(s.code!),
              style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w800),
            ),
            trailing: s.code == null
                ? null
                : IconButton(
                    tooltip: 'Copy code',
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: formatFriendCode(s.code!)));
                      if (context.mounted) _say(context, 'Code copied. Share it with a friend.');
                    },
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Your name for friends'),
            subtitle: Text(s.name),
            onTap: () async {
              final name = await _askName(context, s.name);
              if (name == null || !context.mounted) return;
              final result = await ref.read(friendsProvider.notifier).rename(name);
              if (context.mounted) _say(context, result.message);
            },
          ),
          if (onOpenFriends != null)
            ListTile(
              leading: const Icon(Icons.people_alt_rounded),
              title: const Text('Open Friends'),
              subtitle: const Text('Add friends and visit their gardens'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenFriends,
            ),
        ],
      ],
    );
  }
}
