import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../core/providers.dart';
import '../../data/premade/premade_quests.dart';
import '../../domain/models/enums.dart';
import '../../ui/theme/category_style.dart';
import '../today/today_providers.dart';
import 'quest_editor_screen.dart';
import '../../ui/layout/insets.dart';

Future<void> showAddQuestSheet(BuildContext context) =>
    showSproutSheet<void>(context, heightFactor: 0.9, builder: (_) => const _AddQuestSheet());

class _AddQuestSheet extends StatelessWidget {
  const _AddQuestSheet();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Add a quest', style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 8),
          const TabBar(
            tabs: [
              Tab(text: 'Library'),
              Tab(text: 'Make your own'),
            ],
          ),
          const Expanded(child: TabBarView(children: [_Library(), _CustomTab()])),
        ],
      ),
    );
  }
}

class _Library extends ConsumerWidget {
  const _Library();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quests = ref.watch(questsProvider).value ?? const [];
    final added = {
      for (final q in quests)
        if (q.premadeKey != null && !q.archived) q.premadeKey!,
    };
    return ListView(
      padding: AppInsets.list(context, horizontal: 16, top: 12),
      children: [
        for (final c in QuestCategory.values) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Text('${c.emoji}  ${c.label}', style: theme.textTheme.titleMedium),
          ),
          for (final p in premadeQuests.where((p) => p.category == c))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: categoryColor(c).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text(p.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text('${p.description}  ${difficultyDots(p.difficulty)}'),
                  trailing: added.contains(p.key)
                      ? const Icon(Icons.check_circle, color: Color(0xFF7FC48B))
                      : IconButton.filledTonal(
                          tooltip: 'Add',
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            Haptics.light();
                            await ref.read(questRepositoryProvider).addPremade(p);
                            ref.invalidate(reminderSyncProvider);
                          },
                        ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _CustomTab extends StatelessWidget {
  const _CustomTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✏️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('Make a quest that fits your life', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Give it a name, a category and a size, and choose how often it shows up.',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final saved = await navigator.push<bool>(MaterialPageRoute(builder: (_) => const QuestEditorScreen()));
              if (saved == true) navigator.pop();
            },
            icon: const Icon(Icons.add),
            label: const Text('Create a quest'),
          ),
        ],
      ),
    );
  }
}
