import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/greeting.dart';
import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../domain/models/quest.dart';
import '../../ui/theme/category_style.dart';
import '../../ui/widgets/motion.dart';
import '../../ui/widgets/seed_meter_ring.dart';
import '../../ui/widgets/soft_card.dart';
import '../quests/add_quest_sheet.dart';
import '../quests/my_quests_screen.dart';
import '../quests/quest_editor_screen.dart';
import 'quest_card.dart';
import 'seed_reveal.dart';
import 'today_providers.dart';

/// Slot for the daily mood check-in card. Filled in by the mood feature.
Widget Function(BuildContext context)? moodCheckInCardBuilder;

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

  Future<void> _complete(Quest quest) async {
    Haptics.medium();
    final service = ref.read(progressServiceProvider);
    final result = await service.complete(quest);
    if (!mounted) return;
    if (!reduceMotion(context, ref)) _confetti.play();

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final undoSeconds = ref.read(gameConfigProvider).undoSeconds;
    messenger.showSnackBar(
      SnackBar(
        duration: Duration(seconds: undoSeconds),
        content: Text(result.counted ? 'Nice, "${quest.title}" done 🌱' : '"${quest.title}" done. Well done you 💛'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await service.undo(result.completionId);
            Haptics.light();
          },
        ),
      ),
    );

    final seed = result.seed;
    if (seed != null) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) await showSeedReveal(context, seed);
    }
  }

  void _edit(Quest quest) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuestEditorScreen(quest: quest)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final view = ref.watch(todayViewProvider);
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final name = ref.watch(settingsProvider.select((s) => s.name));
    final repo = ref.read(questRepositoryProvider);
    final day = ref.watch(todayKeyProvider);
    final calm = reduceMotion(context, ref);

    Widget card(Quest q, {bool later = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QuestCard(
        quest: q,
        isLater: later,
        reduceMotion: calm,
        onComplete: () => _complete(q),
        onSkip: () => repo.setDayMark(q.id, day, DayMarkKind.skip),
        onLater: () => repo.setDayMark(q.id, day, DayMarkKind.later),
        onEdit: () => _edit(q),
      ),
    );

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 84),
        child: FloatingActionButton(
          tooltip: 'Add a quest',
          onPressed: () => showAddQuestSheet(context),
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 180),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(greetingFor(now, name), style: theme.textTheme.headlineSmall),
                            Text(
                              DateFormat('EEEE d MMMM').format(now),
                              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'My quests',
                        icon: const Icon(Icons.list_alt_rounded),
                        onPressed: () =>
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyQuestsScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (moodCheckInCardBuilder != null) ...[moodCheckInCardBuilder!(context), const SizedBox(height: 12)],
                  const SeedMeterCard(),
                  const SizedBox(height: 20),
                  if (v.todo.isEmpty && v.later.isEmpty)
                    _AllClear(hasDone: v.done.isNotEmpty, onAdd: () => showAddQuestSheet(context)),
                  ...v.todo.map(card),
                  if (v.later.isNotEmpty) ...[
                    const _SectionLabel('For later'),
                    ...v.later.map((q) => card(q, later: true)),
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
              numberOfParticles: 18,
              maxBlastForce: 18,
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

/// The Seed Meter with its encouraging message.
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
    return SoftCard(
      color: const Color(0xFF7FC48B).withValues(alpha: 0.16),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SeedMeterRing(filled: filled, total: total, size: 64, animate: !reduceMotion(context, ref)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seed Meter', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(message, style: theme.textTheme.bodyMedium),
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
    return SoftCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(hasDone ? '🌷' : '🌤️', style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text(
            hasDone ? "That's everything for today. Take it easy." : 'Nothing planned yet. Want to add a small quest?',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (!hasDone) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAdd, child: const Text('Add a quest')),
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
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _DoneSection extends StatelessWidget {
  const _DoneSection({required this.done});

  final List<Completion> done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SoftCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(),
            title: Text('Done today (${done.length})', style: theme.textTheme.titleMedium),
            leading: const Text('✅', style: TextStyle(fontSize: 22)),
            children: [
              for (final c in done.reversed)
                ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: categoryColor(c.category),
                    child: Text(c.category.emoji, style: const TextStyle(fontSize: 14)),
                  ),
                  title: Text(c.title, style: const TextStyle(decoration: TextDecoration.lineThrough)),
                  subtitle: c.counted ? null : const Text('Done for you (the meter was full for today)'),
                  trailing: Text(DateFormat.jm().format(c.completedAt)),
                ),
            ],
          ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SoftCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(),
            title: Text('Resting today (${skipped.length})', style: theme.textTheme.titleMedium),
            leading: const Text('🌙', style: TextStyle(fontSize: 22)),
            children: [
              for (final q in skipped)
                ListTile(
                  dense: true,
                  title: Text(q.title),
                  trailing: TextButton(onPressed: () => onRestore(q), child: const Text('Bring back')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
