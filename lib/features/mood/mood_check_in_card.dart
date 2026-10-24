import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../ui/widgets/soft_card.dart';
import '../home/garden_providers.dart';
import '../../ui/layout/insets.dart';
import 'moods.dart';

/// The daily check-in: one small card. Changes the sky in the garden.
class MoodCheckInCard extends ConsumerWidget {
  const MoodCheckInCard({super.key, this.hideWhenDone = false});

  /// Disappear once today's mood is saved (used on Today).
  final bool hideWhenDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mood = ref.watch(todayMoodProvider);
    if (mood.isLoading) return const SizedBox.shrink();
    final entry = mood.value;

    if (entry != null) {
      if (hideWhenDone) return const SizedBox.shrink();
      final option = moodOption(entry.value);
      return SoftCard(
        color: option.color.withValues(alpha: 0.5),
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        onTap: () => showMoodSheet(context, ref),
        child: Row(
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 12),
            Expanded(child: Text(moodReply(entry.value), style: theme.textTheme.bodyMedium)),
            const Icon(Icons.edit_outlined, size: 20),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        child: Row(
          children: [
            Expanded(child: Text('How are you feeling?', style: theme.textTheme.titleSmall)),
            for (final o in moodOptions)
              Semantics(
                button: true,
                label: 'Feeling ${o.label}',
                excludeSemantics: true,
                onTap: () => showMoodSheet(context, ref, initial: o.value),
                child: InkResponse(
                  onTap: () => showMoodSheet(context, ref, initial: o.value),
                  radius: 22,
                  child: Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(left: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: o.color, shape: BoxShape.circle),
                    child: Text(o.emoji, style: const TextStyle(fontSize: 19)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pick a mood and add an optional note.
Future<void> showMoodSheet(BuildContext context, WidgetRef ref, {int? initial}) async {
  final repo = ref.read(wellbeingRepositoryProvider);
  final day = ref.read(todayKeyProvider);
  final existing = ref.read(todayMoodProvider).value;
  var value = initial ?? existing?.value ?? 3;
  final note = TextEditingController(text: existing?.note ?? '');
  final saved = await showSproutSheet<bool>(
    context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How are you feeling?', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final o in moodOptions)
                    GestureDetector(
                      onTap: () {
                        Haptics.selection();
                        setState(() => value = o.value);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: o.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: value == o.value ? theme.colorScheme.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Text(o.emoji, style: TextStyle(fontSize: value == o.value ? 32 : 26)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Center(child: Text(moodOption(value).label, style: theme.textTheme.titleMedium)),
              const SizedBox(height: 16),
              TextField(
                controller: note,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Anything on your mind? (optional, stays on this phone)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save check-in')),
              ),
            ],
          ),
        );
      },
    ),
  );
  if (saved == true) {
    await repo.setMood(day, value, note.text.trim());
    Haptics.light();
  }
  note.dispose();
}
