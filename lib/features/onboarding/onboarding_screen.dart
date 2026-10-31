import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../data/premade/premade_quests.dart';
import '../../domain/models/enums.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/theme/chunky.dart';
import '../../ui/art/icon_art.dart';
import '../../ui/theme/category_style.dart';
import '../../ui/widgets/motion.dart';
import '../../ui/widgets/tile_grid.dart';

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

  /// Categories to show first in the quest picker. Only sorts; never picks.
  final Set<QuestCategory> _focus = {};

  /// Premade quest keys the user picked. Starts empty: nothing is chosen
  /// for them.
  final Set<String> _picked = {};
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
    // Only what the user picked becomes a daily quest. No picks, no quests.
    final quests = ref.read(questRepositoryProvider);
    for (final p in premadeQuests.where((p) => _picked.contains(p.key))) {
      await quests.addPremade(p);
    }
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
    if (_reminders) await ref.read(reminderSchedulerProvider).requestPermission();
    ref.invalidate(reminderSyncProvider);
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
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
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
                    icon: 'sprout',
                    title: 'Welcome to Sprout',
                    body:
                        'A little garden that grows when you take care of yourself. '
                        'Small kind things count. There is no wrong way to do this.',
                    action: FilledButton(onPressed: _next, child: const Text("Let's begin")),
                  ),
                  _OnboardingPage(
                    icon: 'heart',
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
                  QuestPickerPage(
                    picked: _picked,
                    focus: _focus,
                    onToggle: (key) => setState(() => _picked.contains(key) ? _picked.remove(key) : _picked.add(key)),
                    onToggleFocus: (c) => setState(() => _focus.contains(c) ? _focus.remove(c) : _focus.add(c)),
                    onContinue: _next,
                    onSkip: () {
                      setState(_picked.clear);
                      _next();
                    },
                  ),
                  _OnboardingPage(
                    icon: 'bell',
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
                    icon: 'seed',
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

/// The bar at the bottom of every setup step: the main button, always on
/// screen, with room for the system bar below it.
class _PinnedBar extends StatelessWidget {
  const _PinnedBar({required this.action, this.secondary});

  final Widget action;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, -4))],
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: double.infinity, child: action),
          ?secondary,
        ],
      ),
    ),
  );
}

/// One setup step: a compact header, content that scrolls only when it must,
/// and the pinned main button.
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    this.content,
  });

  final String icon;
  final String title;
  final String body;
  final Widget? content;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final roomy = constraints.maxHeight > 420;
              final art = roomy ? 120.0 : 80.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: art,
                        height: art,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: ArtIcon(icon, size: art * 0.58),
                      ),
                      SizedBox(height: roomy ? 24 : 14),
                      Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Text(
                        body,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (content != null) ...[SizedBox(height: roomy ? 24 : 16), content!],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _PinnedBar(action: action),
      ],
    );
  }
}

/// "Pick your daily quests": the premade quests in a tidy 2-column grid,
/// none selected, with the categories chosen in "Show first" sorted to the top.
class QuestPickerPage extends StatelessWidget {
  const QuestPickerPage({
    super.key,
    required this.picked,
    required this.focus,
    required this.onToggle,
    required this.onToggleFocus,
    required this.onContinue,
    required this.onSkip,
  });

  final Set<String> picked;
  final Set<QuestCategory> focus;
  final ValueChanged<String> onToggle;
  final ValueChanged<QuestCategory> onToggleFocus;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = [
      ...QuestCategory.values.where(focus.contains),
      ...QuestCategory.values.where((c) => !focus.contains(c)),
    ];
    final count = picked.length;
    final chips = Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Show first:', style: theme.textTheme.labelLarge),
        for (final c in QuestCategory.values)
          FilterChip(
            label: Text(c.label),
            avatar: Icon(categoryIcon(c), size: 16),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            selected: focus.contains(c),
            selectedColor: categoryColor(c),
            onSelected: (_) => onToggleFocus(c),
          ),
      ],
    );
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pick your daily quests', style: theme.textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(
            'Most people start with 3 to 5, but any number is fine. You can change them any time.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // On short screens (landscape) the header scrolls with the list,
        // so the pinned button always fits.
        final short = constraints.maxHeight < 420;
        return Column(
          children: [
            if (!short) header,
            Expanded(
              child: ListView(
                key: const ValueKey('quest-picker-list'),
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                children: [
                  if (short) header.child!,
                  chips,
                  for (final c in categories) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
                      child: Row(
                        children: [
                          CategoryBadge(c, size: 24),
                          const SizedBox(width: 8),
                          Text(c.label, style: theme.textTheme.titleSmall),
                        ],
                      ),
                    ),
                    TileGrid(
                      columns: 2,
                      children: [
                        for (final q in premadeQuests.where((q) => q.category == c))
                          _PickCard(
                            quest: q,
                            selected: picked.contains(q.key),
                            suggested: suggestedQuestKeys.contains(q.key),
                            onTap: () => onToggle(q.key),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            _PinnedBar(
              action: FilledButton(
                onPressed: onContinue,
                child: Text(count == 0 ? 'Continue' : 'Continue with $count'),
              ),
              secondary: TextButton(onPressed: onSkip, child: const Text("Skip, I'll add some later")),
            ),
          ],
        );
      },
    );
  }
}

class _PickCard extends StatelessWidget {
  const _PickCard({required this.quest, required this.selected, required this.suggested, required this.onTap});

  final PremadeQuest quest;
  final bool selected;
  final bool suggested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = categoryColor(quest.category);
    final fill = Color.alphaBlend(selected ? tint : tint.withValues(alpha: 0.28), SproutColors.cream);
    return Semantics(
      button: true,
      selected: selected,
      label: quest.title,
      excludeSemantics: true,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 76),
        child: DecoratedBox(
          // Picked quests stand a little taller.
          decoration: Chunky.box(fill, radius: BorderRadius.circular(18), lipHeight: selected ? 3.5 : 2),
          child: Material(
            color: fill,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            quest.title,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: const Color(0xFF3B3346),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                          size: 20,
                          color: const Color(0xFF3B3346).withValues(alpha: selected ? 1 : 0.35),
                        ),
                      ],
                    ),
                    if (suggested) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Suggested',
                          style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF3B3346)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
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
