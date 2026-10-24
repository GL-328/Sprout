import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/quest.dart';
import '../../ui/theme/category_style.dart';
import '../../ui/widgets/soft_card.dart';

/// Create a custom quest, or edit an existing one.
class QuestEditorScreen extends ConsumerStatefulWidget {
  const QuestEditorScreen({super.key, this.quest});

  final Quest? quest;

  @override
  ConsumerState<QuestEditorScreen> createState() => _QuestEditorScreenState();
}

class _QuestEditorScreenState extends ConsumerState<QuestEditorScreen> {
  late final _title = TextEditingController(text: widget.quest?.title ?? '');
  late final _notes = TextEditingController(text: widget.quest?.notes ?? '');
  late QuestCategory _category = widget.quest?.category ?? QuestCategory.mind;
  late Difficulty _difficulty = widget.quest?.difficulty ?? Difficulty.small;
  late RepeatKind _repeat = widget.quest?.repeat ?? RepeatKind.daily;
  late final Set<int> _weekdays = {...?widget.quest?.weekdays};
  late bool _showOnToday = widget.quest?.showOnToday ?? true;
  late bool _reminderOn = widget.quest?.reminderOn ?? false;
  late int _reminderMinutes = widget.quest?.reminderMinutes ?? 10 * 60;

  bool get _editing => widget.quest != null;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Give your quest a little name first')));
      return;
    }
    final repo = ref.read(questRepositoryProvider);
    final weekdays = _repeat == RepeatKind.weekdays ? (_weekdays.isEmpty ? {1, 2, 3, 4, 5} : _weekdays) : <int>{};
    if (_editing) {
      await repo.update(
        widget.quest!.copyWith(
          title: title,
          category: _category,
          difficulty: _difficulty,
          notes: _notes.text.trim(),
          repeat: _repeat,
          weekdays: weekdays,
          showOnToday: _showOnToday,
          reminderOn: _reminderOn,
          reminderMinutes: () => _reminderOn ? _reminderMinutes : null,
        ),
      );
    } else {
      await repo.create(
        title: title,
        category: _category,
        difficulty: _difficulty,
        notes: _notes.text.trim(),
        repeat: _repeat,
        weekdays: weekdays,
        reminderOn: _reminderOn,
        reminderMinutes: _reminderOn ? _reminderMinutes : null,
      );
    }
    ref.invalidate(reminderSyncProvider);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _archive() async {
    await ref.read(questRepositoryProvider).setArchived(widget.quest!.id, !widget.quest!.archived);
    ref.invalidate(reminderSyncProvider);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this quest?'),
        content: const Text("It will be removed from your list. Times you've already done it stay in your journal."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep it')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(questRepositoryProvider).delete(widget.quest!.id);
    ref.invalidate(reminderSyncProvider);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit quest' : 'New quest'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          TextField(
            controller: _title,
            autofocus: !_editing,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'What would you like to do?'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            textCapitalization: TextCapitalization.sentences,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Notes (optional)'),
          ),
          const _Label('Category'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in QuestCategory.values)
                ChoiceChip(
                  label: Text('${c.emoji} ${c.label}'),
                  selected: _category == c,
                  selectedColor: categoryColor(c),
                  onSelected: (_) => setState(() => _category = c),
                ),
            ],
          ),
          const _Label('Size'),
          SegmentedButton<Difficulty>(
            segments: [
              for (final d in Difficulty.values)
                ButtonSegment(value: d, label: Text('${d.label} ${difficultyDots(d)}')),
            ],
            selected: {_difficulty},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() => _difficulty = v.first),
          ),
          const _Label('How often'),
          SegmentedButton<RepeatKind>(
            segments: [for (final r in RepeatKind.values) ButtonSegment(value: r, label: Text(r.label))],
            selected: {_repeat},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() => _repeat = v.first),
          ),
          if (_repeat == RepeatKind.weekdays) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var d = 1; d <= 7; d++)
                  FilterChip(
                    label: Text(days[d - 1]),
                    showCheckmark: false,
                    selected: _weekdays.contains(d),
                    onSelected: (on) => setState(() => on ? _weekdays.add(d) : _weekdays.remove(d)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Show on Today'),
                  value: _showOnToday,
                  onChanged: (v) => setState(() => _showOnToday = v),
                ),
                SwitchListTile(
                  title: const Text('Gentle reminder'),
                  subtitle: const Text('A soft nudge for this quest'),
                  value: _reminderOn,
                  onChanged: (v) => setState(() => _reminderOn = v),
                ),
                if (_reminderOn)
                  ListTile(
                    title: const Text('Remind me at'),
                    trailing: Text(
                      TimeOfDay(hour: _reminderMinutes ~/ 60, minute: _reminderMinutes % 60).format(context),
                      style: theme.textTheme.titleMedium,
                    ),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: _reminderMinutes ~/ 60, minute: _reminderMinutes % 60),
                      );
                      if (t != null) setState(() => _reminderMinutes = t.hour * 60 + t.minute);
                    },
                  ),
              ],
            ),
          ),
          if (_editing) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _archive,
              icon: Icon(widget.quest!.archived ? Icons.unarchive_outlined : Icons.archive_outlined),
              label: Text(widget.quest!.archived ? 'Bring back from archive' : 'Archive (hide for now)'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete quest'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10, left: 4),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
