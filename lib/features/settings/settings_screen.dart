import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../friends/friends_screen.dart';
import '../friends/friends_section.dart';

import '../../core/providers.dart';
import '../../domain/models/app_settings.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/soft_card.dart';
import 'about_screen.dart';
import 'data_section.dart';
import 'dev_mode_section.dart';
import 'updates_section.dart';
import '../../ui/layout/insets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: AppInsets.list(context),
        children: [
          const DevModeCard(),
          _Section(
            title: 'You',
            children: [
              ListTile(
                title: const Text('Name'),
                subtitle: Text(s.name.isEmpty ? 'Not set' : s.name),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () async {
                  final name = await _askName(context, s.name);
                  if (name != null) await notifier.update((x) => x.copyWith(name: name));
                },
              ),
            ],
          ),
          _Section(
            title: 'Look and feel',
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SegmentedButton<ThemePreference>(
                  segments: const [
                    ButtonSegment(
                      value: ThemePreference.system,
                      label: Text('Auto'),
                      icon: Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(value: ThemePreference.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                    ButtonSegment(value: ThemePreference.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                  ],
                  selected: {s.theme},
                  onSelectionChanged: (v) => notifier.update((x) => x.copyWith(theme: v.first)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final a in AccentChoice.values)
                      Semantics(
                        label: '${a.name} accent',
                        selected: s.accent == a,
                        button: true,
                        child: GestureDetector(
                          onTap: () => notifier.update((x) => x.copyWith(accent: a)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: SproutColors.accent(a),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: s.accent == a ? theme.colorScheme.onSurface : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: s.accent == a ? const Icon(Icons.check, color: Colors.white) : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SwitchListTile(
                title: const Text('Reduce motion'),
                subtitle: const Text('Calmer, simpler animations'),
                value: s.reducedMotion,
                onChanged: (v) => notifier.update((x) => x.copyWith(reducedMotion: v)),
              ),
              SwitchListTile(
                title: const Text('Sounds'),
                subtitle: const Text('Soft taps and little chimes'),
                value: s.soundOn,
                onChanged: (v) => notifier.update((x) => x.copyWith(soundOn: v)),
              ),
              SwitchListTile(
                title: const Text('Music'),
                subtitle: const Text('Gentle music in the garden that changes with each plot'),
                value: s.musicOn,
                onChanged: (v) => notifier.update((x) => x.copyWith(musicOn: v)),
              ),
            ],
          ),
          _Section(
            title: 'Reminders',
            children: [
              SwitchListTile(
                title: const Text('Gentle reminders'),
                subtitle: const Text('Turn on a daily check-in nudge, plus any quest reminders you set'),
                value: s.remindersOn,
                onChanged: (v) async {
                  if (v && !await ref.read(reminderSchedulerProvider).requestPermission()) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications are turned off for Sprout in your phone settings.'),
                        ),
                      );
                    }
                    return;
                  }
                  await notifier.update((x) => x.copyWith(remindersOn: v));
                },
              ),
              ListTile(
                enabled: s.remindersOn,
                title: const Text('Check-in time'),
                trailing: Text(
                  TimeOfDay(
                    hour: s.checkInReminderMinutes ~/ 60,
                    minute: s.checkInReminderMinutes % 60,
                  ).format(context),
                  style: theme.textTheme.titleMedium,
                ),
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: s.checkInReminderMinutes ~/ 60, minute: s.checkInReminderMinutes % 60),
                  );
                  if (t != null) {
                    await notifier.update((x) => x.copyWith(checkInReminderMinutes: t.hour * 60 + t.minute));
                  }
                },
              ),
            ],
          ),
          _Section(
            title: 'Friends',
            children: [FriendsSection(onOpenFriends: () => pushPage(context, const FriendsScreen()))],
          ),
          const _Section(title: 'Your data', children: [DataSection()]),
          const _Section(title: 'Updates', children: [UpdatesSection()]),
          _Section(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text('About Sprout'),
                subtitle: const Text('And a little note about wellbeing'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => pushPage(context, const AboutScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _askName(BuildContext context, String current) {
    final controller = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('What should we call you?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Your name'),
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    ).whenComplete(controller.dispose);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
