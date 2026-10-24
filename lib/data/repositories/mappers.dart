import 'package:drift/drift.dart' show Value;

import '../../domain/models/enums.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/quest.dart';
import '../../domain/models/seed.dart';
import '../db/app_database.dart';

Quest questFromRow(QuestRow r) => Quest(
  id: r.id,
  title: r.title,
  category: QuestCategory.fromId(r.category),
  difficulty: Difficulty.fromId(r.difficulty),
  notes: r.notes,
  repeat: RepeatKind.fromId(r.repeat),
  weekdays: {
    for (final d in r.weekdays.split(','))
      if (d.isNotEmpty) int.parse(d),
  },
  premadeKey: r.premadeKey,
  showOnToday: r.showOnToday,
  archived: r.archived,
  reminderOn: r.reminderOn,
  reminderMinutes: r.reminderMinutes,
  createdAt: r.createdAt,
);

QuestsCompanion questToCompanion(Quest q, {int sortOrder = 0}) => QuestsCompanion.insert(
  id: q.id,
  title: q.title,
  category: q.category.id,
  difficulty: q.difficulty.id,
  notes: Value(q.notes),
  repeat: q.repeat.id,
  weekdays: Value((q.weekdays.toList()..sort()).join(',')),
  premadeKey: Value(q.premadeKey),
  showOnToday: Value(q.showOnToday),
  archived: Value(q.archived),
  reminderOn: Value(q.reminderOn),
  reminderMinutes: Value(q.reminderMinutes),
  createdAt: q.createdAt,
  sortOrder: Value(sortOrder),
);

Completion completionFromRow(CompletionRow r) => Completion(
  id: r.id,
  questId: r.questId,
  title: r.title,
  category: QuestCategory.fromId(r.category),
  difficulty: Difficulty.fromId(r.difficulty),
  completedAt: r.completedAt,
  day: r.day,
  counted: r.counted,
  seedId: r.seedId,
);

Seed seedFromRow(SeedRow r) => Seed(
  id: r.id,
  speciesId: r.speciesId,
  rarity: Rarity.fromId(r.rarity),
  source: SeedSource.values.byName(r.source),
  earnedAt: r.earnedAt,
  state: SeedState.values.byName(r.state),
);

Plant plantFromRow(PlantRow r) => Plant(
  id: r.id,
  envId: r.envId,
  slot: r.slot,
  speciesId: r.speciesId,
  rarity: Rarity.fromId(r.rarity),
  plantedAt: r.plantedAt,
  fruitAnchorAt: r.fruitAnchorAt,
  harvests: r.harvests,
  uprootedAt: r.uprootedAt,
);
