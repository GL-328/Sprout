import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/clock.dart';
import '../../core/providers.dart';
import '../../data/repositories/counters_repository.dart';
import '../../data/repositories/wellbeing_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/quest.dart';
import '../../ui/art/plant_art_provider.dart';
import '../../ui/theme/category_style.dart';
import '../../ui/widgets/soft_card.dart';
import '../home/garden_providers.dart';
import '../mood/moods.dart';
import '../settings/about_screen.dart';
import 'contacts_screen.dart';

final _moodsProvider = StreamProvider<Map<String, MoodEntry>>(
  (ref) => ref.watch(wellbeingRepositoryProvider).watchMoods(),
);

final _historyProvider = StreamProvider<List<Completion>>((ref) => ref.watch(questRepositoryProvider).watchHistory());

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Journal'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Moods'),
              Tab(text: 'Quests'),
              Tab(text: 'Plants'),
              Tab(text: 'Visitors'),
              Tab(text: 'Achievements'),
            ],
          ),
        ),
        body: const TabBarView(children: [_MoodsTab(), _HistoryTab(), _PlantsTab(), _VisitorsTab(), _StatsTab()]),
      ),
    );
  }
}

const _pad = EdgeInsets.fromLTRB(20, 16, 20, 120);

class _MoodsTab extends ConsumerStatefulWidget {
  const _MoodsTab();

  @override
  ConsumerState<_MoodsTab> createState() => _MoodsTabState();
}

class _MoodsTabState extends ConsumerState<_MoodsTab> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moods = ref.watch(_moodsProvider).value ?? const {};
    final rest = ref.watch(restDaysProvider).value ?? const {};
    final first = _month;
    final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
    final leading = first.weekday - 1;
    final inMonth = [for (var d = 1; d <= daysInMonth; d++) moods[dayKey(DateTime(first.year, first.month, d))]]
        .whereType<MoodEntry>()
        .toList();

    return ListView(
      padding: _pad,
      children: [
        SoftCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous month',
                    onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      DateFormat('MMMM yyyy').format(_month),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                    Expanded(
                      child: Center(child: Text(d, style: theme.textTheme.labelMedium)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              GridView.count(
                padding: EdgeInsets.zero,
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  for (var i = 0; i < leading; i++) const SizedBox.shrink(),
                  for (var d = 1; d <= daysInMonth; d++)
                    Builder(
                      builder: (context) {
                        final key = dayKey(DateTime(first.year, first.month, d));
                        final mood = moods[key];
                        final isRest = rest.contains(key);
                        return Tooltip(
                          message: mood == null
                              ? (isRest ? 'Rest day' : '')
                              : '${moodOption(mood.value).label}${mood.note.isEmpty ? '' : ': ${mood.note}'}',
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: mood == null
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
                                  : moodOption(mood.value).color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: mood == null
                                ? Text(isRest ? '🌙' : '$d', style: theme.textTheme.bodySmall)
                                : Text(moodOption(mood.value).emoji, style: const TextStyle(fontSize: 18)),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (inMonth.isNotEmpty)
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This month', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final o in moodOptions)
                      Chip(
                        avatar: Text(o.emoji),
                        label: Text('${inMonth.where((m) => m.value == o.value).length}'),
                        backgroundColor: o.color.withValues(alpha: 0.6),
                      ),
                  ],
                ),
                for (final m in inMonth.where((m) => m.note.isNotEmpty).toList().reversed.take(5))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(moodOption(m.value).emoji, style: const TextStyle(fontSize: 24)),
                    title: Text(m.note),
                    subtitle: Text(DateFormat('EEE d MMM').format(DateTime.parse(m.day))),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const _SupportCard(),
      ],
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      color: theme.colorScheme.primary.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Need a little support?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(notMedicalAdviceNote, style: theme.textTheme.bodySmall?.copyWith(height: 1.4)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactsScreen())),
            icon: const Icon(Icons.favorite_outline),
            label: const Text('My helpful contacts'),
          ),
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final history = ref.watch(_historyProvider).value ?? const <Completion>[];
    if (history.isEmpty) {
      return const Center(child: Text('Quests you finish will be remembered here 🌱'));
    }
    final byDay = <String, List<Completion>>{};
    for (final c in history) {
      (byDay[c.day] ??= []).add(c);
    }
    return ListView(
      padding: _pad,
      children: [
        for (final e in byDay.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
            child: Text(
              '${DateFormat('EEEE d MMMM').format(DateTime.parse(e.key))} · ${e.value.length} done',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final c in e.value)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: categoryColor(c.category),
                      child: Text(c.category.emoji, style: const TextStyle(fontSize: 14)),
                    ),
                    title: Text(c.title),
                    trailing: Text(DateFormat.jm().format(c.completedAt)),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PlantsTab extends ConsumerWidget {
  const _PlantsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final plants = ref.watch(allPlantsProvider).value ?? const <Plant>[];
    final discovered = {for (final p in plants) p.speciesId};
    final keepsakes = plants.where((p) => p.isKeepsake).toList();
    return ListView(
      padding: _pad,
      children: [
        Text('${discovered.length} of ${config.species.length} plants discovered', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
          children: [
            for (final s in config.species.values)
              SoftCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Expanded(
                      child: discovered.contains(s.id)
                          ? plantArtProvider.plant(s, GrowthStage.mature, size: 80)
                          : const Center(child: Text('❔', style: TextStyle(fontSize: 34))),
                    ),
                    Text(
                      discovered.contains(s.id) ? s.name : '???',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      s.rarity == Rarity.rare ? '✨ ${s.rarity.label}' : s.rarity.label,
                      style: theme.textTheme.labelSmall?.copyWith(color: rarityColor(s.rarity)),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Keepsakes', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Plants you moved on from, remembered here.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        if (keepsakes.isEmpty) const Text('None yet.'),
        for (final p in keepsakes)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: SizedBox(
              width: 48,
              child: plantArtProvider.plant(config.speciesById(p.speciesId), GrowthStage.mature, size: 48),
            ),
            title: Text(config.speciesById(p.speciesId).name),
            subtitle: Text(
              'Grew in the ${config.environment(p.envId).name} '
              'from ${DateFormat('d MMM').format(p.plantedAt)} to ${DateFormat('d MMM yyyy').format(p.uprootedAt!)}'
              ' · picked ${p.harvests} times',
            ),
          ),
      ],
    );
  }
}

class _VisitorsTab extends ConsumerWidget {
  const _VisitorsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(gameConfigProvider);
    final seen = ref.watch(visitorsSeenProvider).value ?? const {};
    return ListView(
      padding: _pad,
      children: [
        Text('${seen.length} of ${config.visitors.length} visitors met', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Visitors come by when your plots are thriving, and some only on a streak or at night.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (final v in config.visitors.values)
              SoftCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(seen.containsKey(v.id) ? v.emoji : '❔', style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 4),
                    Text(
                      seen.containsKey(v.id) ? v.name : '???',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if ((seen[v.id]?.timesFed ?? 0) > 0)
                      Text('fed ${seen[v.id]!.timesFed}×', style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatsTab extends ConsumerWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final c = ref.watch(countersProvider).value ?? const <String, int>{};
    final plots = ref.watch(plotsProvider).value?.length ?? 1;
    final streak = ref.watch(streakProvider);
    final visitors = ref.watch(visitorsSeenProvider).value?.length ?? 0;
    int v(String key) => c[key] ?? 0;

    final items = [
      ('✅', 'Quests completed', v(CounterKeys.questsCompleted)),
      ('🌱', 'Seeds earned', v(CounterKeys.seedsEarned)),
      ('🌳', 'Plants grown', v(CounterKeys.plantsGrown)),
      ('🧺', 'Fruit harvested', v(CounterKeys.fruitHarvested)),
      ('🪙', 'Coins earned', v(CounterKeys.coinsEarned)),
      ('🥧', 'Recipes made', v(CounterKeys.recipesMade)),
      ('🗺️', 'Plots tended', plots),
      ('🦋', 'Visitors met', visitors),
      ('🌿', 'Current gentle streak', streak),
    ];
    return ListView(
      padding: _pad,
      children: [
        Text(
          'Everything you\'ve grown so far. Every number here is something you did for yourself.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            for (final (emoji, label, value) in items)
              SoftCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 28)),
                    const Spacer(),
                    Text('$value', style: theme.textTheme.headlineSmall),
                    Text(label, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
