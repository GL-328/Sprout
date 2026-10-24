import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../core/sound_service.dart';
import '../../domain/models/quest.dart';
import '../../ui/theme/category_style.dart';
import '../quests/quest_editor_screen.dart';
import 'seed_reveal.dart';
import '../../ui/layout/insets.dart';

/// Completes [quest]: haptic, sound, the undo snackbar and, when the Seed Meter
/// fills, the seed reveal. Shared by the Home quests panel and the Today tab.
Future<void> completeQuestFlow(BuildContext context, WidgetRef ref, Quest quest, {VoidCallback? onCelebrate}) async {
  Haptics.medium();
  ref.read(soundServiceProvider).play(Sfx.complete);
  final service = ref.read(progressServiceProvider);
  final messenger = ScaffoldMessenger.of(context);
  final result = await service.complete(quest);
  onCelebrate?.call();

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: Duration(seconds: ref.read(gameConfigProvider).undoSeconds),
        content: Text(result.counted ? '"${quest.title}" done' : '"${quest.title}" done. Well done you.'),
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
    if (context.mounted) {
      ref.read(soundServiceProvider).play(Sfx.seed);
      await showSeedReveal(context, seed);
    }
  }
}

/// Edit, skip, later and delete, tucked away behind a long press or "⋯".
Future<void> showQuestMenu(BuildContext context, WidgetRef ref, Quest quest, {bool isLater = false}) async {
  final repo = ref.read(questRepositoryProvider);
  final day = ref.read(todayKeyProvider);
  final choice = await showSproutSheet<String>(
    context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(quest.title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit'),
            onTap: () => Navigator.pop(context, 'edit'),
          ),
          ListTile(
            leading: const Icon(Icons.bedtime_outlined),
            title: const Text('Skip today'),
            onTap: () => Navigator.pop(context, 'skip'),
          ),
          if (!isLater)
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Do it later'),
              onTap: () => Navigator.pop(context, 'later'),
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete'),
            onTap: () => Navigator.pop(context, 'delete'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (!context.mounted) return;
  switch (choice) {
    case 'edit':
      await pushPage(context, QuestEditorScreen(quest: quest));
    case 'skip':
      await repo.setDayMark(quest.id, day, DayMarkKind.skip);
    case 'later':
      await repo.setDayMark(quest.id, day, DayMarkKind.later);
    case 'delete':
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          scrollable: true,
          title: const Text('Delete this quest?'),
          content: const Text("Times you've already done it stay in your journal."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep it')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
          ],
        ),
      );
      if (ok == true) {
        await repo.delete(quest.id);
        ref.invalidate(reminderSyncProvider);
      }
  }
}

/// A calm quest row: a big check circle, the title, a tiny category icon and
/// faint size dots. Everything else lives in the long-press menu.
class QuestRow extends StatefulWidget {
  const QuestRow({
    super.key,
    required this.quest,
    required this.onComplete,
    required this.onMenu,
    this.reduceMotion = false,
    this.compact = false,
  });

  final Quest quest;
  final VoidCallback onComplete;
  final VoidCallback onMenu;
  final bool reduceMotion;

  /// Tighter spacing, for the Home quests panel.
  final bool compact;

  @override
  State<QuestRow> createState() => _QuestRowState();
}

class _QuestRowState extends State<QuestRow> {
  bool _ticked = false;

  Future<void> _tick() async {
    if (_ticked) return;
    setState(() => _ticked = true);
    if (!widget.reduceMotion) await Future<void>.delayed(const Duration(milliseconds: 380));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = widget.quest;
    final tint = categoryColor(q.category);
    final duration = widget.reduceMotion ? Duration.zero : const Duration(milliseconds: 320);
    final circle = widget.compact ? 34.0 : 40.0;
    return Material(
      color: tint.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _tick,
        onLongPress: widget.onMenu,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, widget.compact ? 8 : 12, 4, widget.compact ? 8 : 12),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'Complete ${q.title}',
                excludeSemantics: true,
                onTap: _tick,
                child: AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOutBack,
                  width: circle,
                  height: circle,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _ticked ? const Color(0xFF7FC48B) : theme.colorScheme.surface,
                    border: Border.all(color: _ticked ? const Color(0xFF7FC48B) : tint, width: 3),
                  ),
                  child: AnimatedScale(
                    scale: _ticked ? 1 : 0,
                    duration: duration,
                    curve: Curves.easeOutBack,
                    child: const Icon(Icons.check_rounded, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: _ticked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DifficultyDots(q.difficulty),
                  ],
                ),
              ),
              CategoryBadge(q.category, size: widget.compact ? 26 : 30),
              IconButton(
                tooltip: 'More',
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.more_horiz, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                onPressed: widget.onMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
