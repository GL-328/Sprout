import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/models/app_settings.dart';
import '../../ui/layout/insets.dart';
import '../../ui/widgets/soft_card.dart';

/// Choose which notifications Sprout sends. Each one pops up on screen, even
/// when Sprout isn't open. All off until turned on.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  /// Asks Android for permission the first time something is turned on.
  /// Returns whether it's allowed.
  static Future<bool> _allowed(BuildContext context, WidgetRef ref) async {
    if (await ref.read(reminderSchedulerProvider).requestPermission()) return true;
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Notifications are turned off for Sprout in your phone settings.')));
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    Future<void> toggle(bool on, AppSettings Function(AppSettings s) change) async {
      if (on && !await _allowed(context, ref)) return;
      await notifier.update(change);
    }

    final time = TimeOfDay(hour: s.checkInReminderMinutes ~/ 60, minute: s.checkInReminderMinutes % 60);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: AppInsets.list(context, top: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text(
              'Pick the ones you want. They pop up on your screen, even when Sprout is closed.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Daily check-in'),
                  subtitle: const Text('A gentle hello at a time you choose'),
                  value: s.remindersOn,
                  onChanged: (v) => toggle(v, (x) => x.copyWith(remindersOn: v)),
                ),
                ListTile(
                  enabled: s.remindersOn,
                  contentPadding: const EdgeInsets.fromLTRB(32, 0, 24, 0),
                  title: const Text('Check-in time'),
                  trailing: Text(time.format(context), style: theme.textTheme.titleMedium),
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: time);
                    if (t != null) {
                      await notifier.update((x) => x.copyWith(checkInReminderMinutes: t.hour * 60 + t.minute));
                    }
                  },
                ),
                SwitchListTile(
                  title: const Text('Quest reminders'),
                  subtitle: const Text('For the quests you gave a reminder time'),
                  value: s.notifyQuests,
                  onChanged: (v) => toggle(v, (x) => x.copyWith(notifyQuests: v)),
                ),
                SwitchListTile(
                  title: const Text('Fruit ready to pick'),
                  subtitle: const Text('When a plant has fruit waiting for you'),
                  value: s.notifyFruit,
                  onChanged: (v) => toggle(v, (x) => x.copyWith(notifyFruit: v)),
                ),
                SwitchListTile(
                  title: const Text('Plant fully grown'),
                  subtitle: const Text('When a seed has grown all the way up'),
                  value: s.notifyGrown,
                  onChanged: (v) => toggle(v, (x) => x.copyWith(notifyGrown: v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
