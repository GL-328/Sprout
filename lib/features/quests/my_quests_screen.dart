import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/logic/quest_schedule.dart';
import '../../domain/models/quest.dart';
import '../../ui/theme/category_style.dart';
import '../../ui/widgets/soft_card.dart';
import '../today/today_providers.dart';
import 'add_quest_sheet.dart';
import 'quest_editor_screen.dart';

/// All the user's quests: choose which appear on Today, edit, archive.
class MyQuestsScreen extends ConsumerWidget {
  const MyQuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quests = ref.watch(questsProvider).value ?? const <Quest>[];
    final active = quests.where((q) => !q.archived).toList();
    final archived = quests.where((q) => q.archived).toList();

    Widget tile(Quest q) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuestEditorScreen(quest: q))),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: categoryColor(q.category), borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: Text(q.category.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    q.repeat == RepeatKind.weekdays ? weekdaysLabel(q.weekdays) : q.repeat.label,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (!q.archived)
              Tooltip(
                message: 'Show on Today',
                child: Switch(
                  value: q.showOnToday,
                  onChanged: (v) => ref.read(questRepositoryProvider).setShowOnToday(q.id, v),
                ),
              )
            else
              TextButton(
                onPressed: () => ref.read(questRepositoryProvider).setArchived(q.id, false),
                child: const Text('Bring back'),
              ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('All quests')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddQuestSheet(context),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text(
            'Switch a quest on to see it on Today. Tap one to edit it.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (active.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No quests yet. Tap + to add one.')),
            ),
          ...active.map(tile),
          if (archived.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
              child: Text('Archived', style: theme.textTheme.titleMedium),
            ),
            ...archived.map(tile),
          ],
        ],
      ),
    );
  }
}
