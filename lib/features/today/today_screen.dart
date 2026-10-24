import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/greeting.dart';
import '../../core/providers.dart';
import '../../domain/models/quest.dart';
import '../../ui/theme/category_style.dart';
import '../../ui/widgets/gentle_motion.dart';
import '../../ui/widgets/motion.dart';
import '../../ui/widgets/seed_meter_ring.dart';
import '../../ui/widgets/soft_card.dart';
import '../home/garden_providers.dart';
import '../mood/mood_check_in_card.dart';
import '../quests/add_quest_sheet.dart';
import '../quests/my_quests_screen.dart';
import '../quests/quest_editor_screen.dart';
import 'quest_actions.dart';
import 'today_providers.dart';
import '../../ui/layout/insets.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  final _confetti = ConfettiController(duration: const Duration(milliseconds: 700));

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final view = ref.watch(todayViewProvider);
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final name = ref.watch(settingsProvider.select((s) => s.name));
    final calm = reduceMotion(context, ref);
    final repo = ref.read(questRepositoryProvider);
    final day = ref.watch(todayKeyProvider);

    Widget row(Quest q, {bool later = false}) => Padding(
      key: ValueKey(q.id),
      padding: const EdgeInsets.only(bottom: 12),
      child: FadeSlideIn(
        enabled: !calm,
        child: QuestRow(
          quest: q,
          reduceMotion: calm,
          onComplete: () => completeQuestFlow(context, ref, q, onCelebrate: calm ? null : _confetti.play),
          onMenu: () => showQuestMenu(context, ref, q, isLater: later),
        ),
      ),
    );

    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: AppInsets.covered(context)),
        child: FloatingActionButton(
          tooltip: 'Add a quest',
          onPressed: () => showAddChooser(context),
          child: const Icon(Icons.add),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: view.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Something went a little wrong: $e')),
              data: (v) => ListView(
                padding: AppInsets.list(context, top: 16, withFab: true),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('EEEE d MMMM').format(now), style: theme.textTheme.titleLarge),
                            Text(
                              greetingFor(now, name),
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const _TodayMenu(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SeedMeterCard(),
                  const SizedBox(height: 12),
                  const MoodCheckInCard(hideWhenDone: true),
                  const SizedBox(height: 8),
                  if (v.todo.isEmpty && v.later.isEmpty)
                    _AllClear(hasDone: v.done.isNotEmpty, onAdd: () => showAddChooser(context)),
                  ...v.todo.map(row),
                  if (v.later.isNotEmpty) ...[
                    const _SectionLabel('For later'),
                    ...v.later.map((q) => row(q, later: true)),
                  ],
                  if (v.done.isNotEmpty) _DoneSection(done: v.done),
                  if (v.skipped.isNotEmpty)
                    _SkippedSection(skipped: v.skipped, onRestore: (q) => repo.setDayMark(q.id, day, null)),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 14,
              maxBlastForce: 16,
              minBlastForce: 6,
              gravity: 0.25,
              colors: const [
                Color(0xFFF59E7A),
                Color(0xFF7FC48B),
                Color(0xFFFFE08A),
                Color(0xFFA48ADB),
                Color(0xFF6FAEDD),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "+" chooser: make a quest, browse ideas, or manage all quests.
Future<void> showAddChooser(BuildContext context) => showSproutSheet<void>(
  context,
  builder: (sheet) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_rounded),
          title: const Text('Make my own quest'),
          onTap: () {
            Navigator.pop(sheet);
            pushPage(context, const QuestEditorScreen());
          },
        ),
        ListTile(
          leading: const Icon(Icons.auto_awesome_rounded),
          title: const Text('Browse quest ideas'),
          onTap: () {
            Navigator.pop(sheet);
            showAddQuestSheet(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.list_alt_rounded),
          title: const Text('All quests'),
          subtitle: const Text('Choose what shows today, edit or archive'),
          onTap: () {
            Navigator.pop(sheet);
            pushPage(context, const MyQuestsScreen());
          },
        ),
        const SizedBox(height: 8),
      ],
    ),
  ),
);

/// A quiet "⋯" in the header: rest day and all quests.
class _TodayMenu extends ConsumerWidget {
  const _TodayMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(todayKeyProvider);
    final resting = (ref.watch(restDaysProvider).value ?? const {}).contains(day);
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(Icons.more_horiz),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onSelected: (v) {
        if (v == 'rest') ref.read(wellbeingRepositoryProvider).setRestDay(day, !resting);
        if (v == 'all') pushPage(context, const MyQuestsScreen());
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'rest', child: Text(resting ? 'End rest day' : 'Take a rest day 🌙')),
        const PopupMenuItem(value: 'all', child: Text('All quests')),
      ],
    );
  }
}

/// The Seed Meter in one slim card, with the gentle streak underneath.
class SeedMeterCard extends ConsumerWidget {
  const SeedMeterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final meter = ref.watch(meterProvider).value;
    final rules = ref.watch(progressServiceProvider).rules;
    final filled = meter?.filled ?? 0;
    final total = meter?.questsPerSeed ?? rules.questsPerSeed;
    final message = rules.message(filled: filled, countedToday: meter?.countedToday ?? 0);
    final streak = ref.watch(streakProvider);
    final day = ref.watch(todayKeyProvider);
    final resting = (ref.watch(restDaysProvider).value ?? const {}).contains(day);
    final sub = resting
        ? 'Rest day. Your garden keeps growing 🌙'
        : streak > 1
        ? '$streak days of caring for yourself 🌿'
        : null;
    return SoftCard(
      color: const Color(0xFF7FC48B).withValues(alpha: 0.14),
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      child: Row(
        children: [
          SeedMeterRing(filled: filled, total: total, size: 44, animate: !reduceMotion(context, ref)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                if (sub != null)
                  Text(sub, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllClear extends StatelessWidget {
  const _AllClear({required this.hasDone, required this.onAdd});

  final bool hasDone;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Text(hasDone ? '🌷' : '🌤️', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            hasDone ? 'All done for today. Take it easy.' : 'Nothing planned yet.',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (!hasDone) ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add a quest')),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class _DoneSection extends StatelessWidget {
  const _DoneSection({required this.done});

  final List<Completion> done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text('Done today (${done.length})', style: theme.textTheme.titleSmall),
          children: [
            for (final c in done.reversed)
              ListTile(
                dense: true,
                leading: CategoryBadge(c.category, size: 28),
                title: Text(c.title, style: const TextStyle(decoration: TextDecoration.lineThrough)),
                subtitle: c.counted ? null : const Text('Done for you (the meter was full for today)'),
                trailing: Text(DateFormat.jm().format(c.completedAt)),
              ),
          ],
        ),
      ),
    );
  }
}

class _SkippedSection extends StatelessWidget {
  const _SkippedSection({required this.skipped, required this.onRestore});

  final List<Quest> skipped;
  final ValueChanged<Quest> onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        title: Text('Resting today (${skipped.length})', style: theme.textTheme.titleSmall),
        children: [
          for (final q in skipped)
            ListTile(
              dense: true,
              title: Text(q.title),
              trailing: TextButton(onPressed: () => onRestore(q), child: const Text('Bring back')),
            ),
        ],
      ),
    );
  }
}
