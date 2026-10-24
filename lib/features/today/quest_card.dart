import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../domain/models/quest.dart';
import '../../ui/theme/category_style.dart';
import '../../ui/widgets/soft_card.dart';

/// A quest on the Today screen. Tap the circle to complete it. Swipe for
/// skip, later and edit.
class QuestCard extends StatefulWidget {
  const QuestCard({
    super.key,
    required this.quest,
    required this.onComplete,
    required this.onSkip,
    required this.onLater,
    required this.onEdit,
    this.isLater = false,
    this.reduceMotion = false,
  });

  final Quest quest;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final VoidCallback onLater;
  final VoidCallback onEdit;
  final bool isLater;
  final bool reduceMotion;

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  bool _ticking = false;

  Future<void> _tick() async {
    if (_ticking) return;
    setState(() => _ticking = true);
    if (!widget.reduceMotion) await Future<void>.delayed(const Duration(milliseconds: 350));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = widget.quest;
    final tint = categoryColor(q.category);
    return Slidable(
      key: ValueKey(q.id),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (_) => widget.onSkip(),
            icon: Icons.bedtime_outlined,
            label: 'Skip today',
            backgroundColor: const Color(0xFFE3D9F5),
            foregroundColor: const Color(0xFF5B4D7A),
            borderRadius: BorderRadius.circular(24),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.55,
        children: [
          if (!widget.isLater)
            SlidableAction(
              onPressed: (_) => widget.onLater(),
              icon: Icons.schedule,
              label: 'Later',
              backgroundColor: const Color(0xFFFFEDB8),
              foregroundColor: const Color(0xFF7A5E1E),
              borderRadius: BorderRadius.circular(24),
            ),
          SlidableAction(
            onPressed: (_) => widget.onEdit(),
            icon: Icons.edit_outlined,
            label: 'Edit',
            backgroundColor: const Color(0xFFCFE6F7),
            foregroundColor: const Color(0xFF2F5878),
            borderRadius: BorderRadius.circular(24),
          ),
        ],
      ),
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        onTap: widget.onEdit,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(16)),
              alignment: Alignment.center,
              child: Text(q.category.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${q.category.label} · ${q.difficulty.label} ${difficultyDots(q.difficulty)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: 'Complete ${q.title}',
              child: InkResponse(
                onTap: _tick,
                radius: 30,
                child: AnimatedContainer(
                  duration: widget.reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _ticking ? const Color(0xFF7FC48B) : Colors.transparent,
                    border: Border.all(color: _ticking ? const Color(0xFF7FC48B) : tint, width: 3),
                  ),
                  child: AnimatedScale(
                    scale: _ticking ? 1 : 0,
                    duration: widget.reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    child: const Icon(Icons.check_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
