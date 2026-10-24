import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../ui/widgets/soft_card.dart';
import '../home/garden_providers.dart';
import 'moods.dart';

/// The daily check-in at the top of Today. Changes the sky in the garden.
class MoodCheckInCard extends ConsumerWidget {
  const MoodCheckInCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mood = ref.watch(todayMoodProvider).value;

    if (mood != null) {
      final option = moodOption(mood.value);
      return SoftCard(
        color: option.color.withValues(alpha: 0.5),
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        onTap: () => showMoodSheet(context, ref),
        child: Row(
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Checked in: ${option.label}', style: theme.textTheme.titleMedium),
                  Text(moodReply(mood.value), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, size: 20),
          ],
        ),
      );
    }

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily check-in', style: theme.textTheme.titleMedium),
          Text('How are you feeling right now?', style: theme.textTheme.bodySmall),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final o in moodOptions)
                Semantics(
                  button: true,
                  label: 'Feeling ${o.label}',
                  excludeSemantics: true,
                  child: InkResponse(
                    onTap: () => showMoodSheet(context, ref, initial: o.value),
                    radius: 30,
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: o.color, shape: BoxShape.circle),
                          child: Text(o.emoji, style: const TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(height: 4),
                        Text(o.label, style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
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
  final saved = await showModalBottomSheet<bool>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final theme = Theme.of(context);
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
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
