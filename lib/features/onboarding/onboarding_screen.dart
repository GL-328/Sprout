import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../domain/models/enums.dart';
import '../../ui/widgets/motion.dart';

/// Keys of small bits of onboarding state kept in the settings table.
abstract final class OnboardingKeys {
  /// 'plant' when the user planted the first seed in onboarding, 'bag' when
  /// they skipped that step (the seed then waits in the Seed Bag).
  static const starterSeed = 'starter_seed_choice';
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 5;

  final _pages = PageController();
  final _nameController = TextEditingController();
  int _page = 0;
  final Set<QuestCategory> _focus = {};
  bool _reminders = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _nameController.text = s.name;
    _focus.addAll(s.focusAreas);
  }

  @override
  void dispose() {
    _pages.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_page == _pageCount - 1) {
      _finish(plantStarter: false);
      return;
    }
    if (reduceMotion(context, ref)) {
      _pages.jumpToPage(_page + 1);
    } else {
      _pages.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
    }
  }

  Future<void> _finish({required bool plantStarter}) async {
    Haptics.light();
    await ref.read(settingsRepositoryProvider).writeValue(OnboardingKeys.starterSeed, plantStarter ? 'plant' : 'bag');
    await ref.read(questRepositoryProvider).addStarterQuests(_focus);
    await ref.read(gardenServiceProvider).grantStarterSeed(plant: plantStarter);
    await ref
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(
            name: _nameController.text.trim(),
            focusAreas: _focus,
            remindersOn: _reminders,
            checkInReminderMinutes: _reminderTime.hour * 60 + _reminderTime.minute,
            onboardingDone: true,
          ),
        );
    if (mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
              child: Row(
                children: [
                  _Dots(count: _pageCount, index: _page),
                  const Spacer(),
                  TextButton(onPressed: _next, child: const Text('Skip')),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _OnboardingPage(
                    emoji: '🌱',
                    title: 'Welcome to Sprout',
                    body:
                        'A little garden that grows when you take care of yourself. '
                        'Small kind things count. There is no wrong way to do this.',
                    action: FilledButton(onPressed: _next, child: const Text("Let's begin")),
                  ),
                  _OnboardingPage(
                    emoji: '👋',
                    title: 'What should we call you?',
                    body: 'Just a first name or a nickname. It stays on this phone.',
                    content: TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _next(),
                      decoration: const InputDecoration(hintText: 'Your name'),
                      style: theme.textTheme.titleMedium,
                    ),
                    action: FilledButton(onPressed: _next, child: const Text('Next')),
                  ),
                  _OnboardingPage(
                    emoji: '🧭',
                    title: 'What would you like to care for?',
                    body: "Pick a few areas. We'll suggest some gentle starter quests. You can change these any time.",
                    content: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final c in QuestCategory.values)
                          FilterChip(
                            label: Text('${c.emoji}  ${c.label}'),
                            selected: _focus.contains(c),
                            onSelected: (on) => setState(() => on ? _focus.add(c) : _focus.remove(c)),
                          ),
                      ],
                    ),
                    action: FilledButton(onPressed: _next, child: const Text('Next')),
                  ),
                  _OnboardingPage(
                    emoji: '🔔',
                    title: 'Gentle reminders?',
                    body: 'A soft nudge once a day to check in. Never nagging, and easy to turn off in Settings.',
                    content: Column(
                      children: [
                        SwitchListTile(
                          value: _reminders,
                          onChanged: (v) => setState(() => _reminders = v),
                          title: const Text('Daily check-in reminder'),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        AnimatedOpacity(
                          opacity: _reminders ? 1 : 0.4,
                          duration: const Duration(milliseconds: 200),
                          child: ListTile(
                            enabled: _reminders,
                            title: const Text('Time'),
                            trailing: Text(_reminderTime.format(context), style: theme.textTheme.titleMedium),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            onTap: () async {
                              final t = await showTimePicker(context: context, initialTime: _reminderTime);
                              if (t != null) setState(() => _reminderTime = t);
                            },
                          ),
                        ),
                      ],
                    ),
                    action: FilledButton(onPressed: _next, child: const Text('Next')),
                  ),
                  _OnboardingPage(
                    emoji: '🌻',
                    title: 'Your very first seed',
                    body:
                        'Here is a Giant sunflower seed, just for you. '
                        "Plant it in your Meadow and watch it grow, even while you're away.",
                    action: FilledButton(onPressed: () => _finish(plantStarter: true), child: const Text('Plant it')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.action,
    this.content,
  });

  final String emoji;
  final String title;
  final String body;
  final Widget? content;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: 32),
              Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                body,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                textAlign: TextAlign.center,
              ),
              if (content != null) ...[const SizedBox(height: 28), content!],
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: action),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(right: 6),
            width: i == index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? scheme.primary : scheme.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
