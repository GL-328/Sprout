import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../domain/models/quest.dart';
import '../../ui/widgets/motion.dart';
import '../today/quest_actions.dart';
import '../today/today_providers.dart';
import '../today/today_screen.dart';
import '../../ui/art/icon_art.dart';

/// The "Today's quests" panel on Home: the Seed Meter and the first two
/// quests due today. It never scrolls; "See all" opens the Today tab.
class QuestsPanel extends ConsumerWidget {
  const QuestsPanel({super.key, required this.bottomInset, this.shown = QuestsPanel.defaultShown});

  /// How many quests the panel shows normally.
  static const defaultShown = 2;

  /// How many quests to show (fewer on very short screens).
  final int shown;

  /// Space at the bottom for the floating navigation bar and system bar.
  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final view = ref.watch(todayViewProvider).value;
    final calm = reduceMotion(context, ref);
    final due = <Quest>[...?view?.todo, ...?view?.later];
    final dark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF2B2635) : const Color(0xFFFFFAF3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, -4)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 6, 18, bottomInset + 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // At very large text sizes the row scales down to one line
                // rather than stacking letters.
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text("Today's quests", style: theme.textTheme.titleMedium),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go('/today'),
                      child: Text(due.length > shown ? 'See all (${due.length})' : 'See all'),
                    ),
                  ),
                ),
              ],
            ),
            const _MeterBar(),
            const SizedBox(height: 10),
            if (view != null && due.isEmpty)
              _Empty(allDone: view.done.isNotEmpty)
            else
              for (final q in due.take(shown))
                Padding(
                  key: ValueKey(q.id),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: QuestRow(
                    quest: q,
                    compact: true,
                    reduceMotion: calm,
                    onComplete: () => completeQuestFlow(context, ref, q),
                    onMenu: () => showQuestMenu(context, ref, q, isLater: view?.later.contains(q) ?? false),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// The Seed Meter as a slim segmented bar with a short count.
class _MeterBar extends ConsumerWidget {
  const _MeterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final meter = ref.watch(meterProvider).value;
    final rules = ref.watch(progressServiceProvider).rules;
    final filled = meter?.filled ?? 0;
    final total = meter?.questsPerSeed ?? rules.questsPerSeed;
    final duration = reduceMotion(context, ref) ? Duration.zero : const Duration(milliseconds: 450);
    return Semantics(
      label: 'Seed Meter, $filled of $total',
      child: Row(
        children: [
          const ArtIcon('seed', size: 22),
          const SizedBox(width: 8),
          for (var i = 0; i < total; i++)
            Expanded(
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutBack,
                height: 10,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: i < filled ? const Color(0xFF7FC48B) : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          const SizedBox(width: 6),
          // A short count keeps the panel small; the Today tab has the full,
          // kind message.
          Text('$filled of $total', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.allDone});

  final bool allDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(allDone ? 'All done for today' : 'No quests planned for today', style: theme.textTheme.titleSmall),
          if (!allDone) ...[
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: () => showAddChooser(context),
              icon: const Icon(Icons.add),
              label: const Text('Add a quest'),
            ),
          ],
        ],
      ),
    );
  }
}
