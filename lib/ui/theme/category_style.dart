import 'package:flutter/material.dart';

import '../../domain/models/enums.dart';
import 'chunky.dart';

/// Soft colour for each quest category.
Color categoryColor(QuestCategory c) => switch (c) {
  QuestCategory.sleep => const Color(0xFFC9C3F2),
  QuestCategory.movement => const Color(0xFFFFD29D),
  QuestCategory.mind => const Color(0xFFDCC8F0),
  QuestCategory.social => const Color(0xFFF8C4CF),
  QuestCategory.home => const Color(0xFFC6E5C1),
  QuestCategory.foodWater => const Color(0xFFBFE2F2),
  QuestCategory.studyWork => const Color(0xFFF2E3A6),
};

Color rarityColor(Rarity r) => switch (r) {
  Rarity.common => const Color(0xFF8FC79A),
  Rarity.uncommon => const Color(0xFF6FAEDD),
  Rarity.rare => const Color(0xFFB27CE0),
};

String difficultyDots(Difficulty d) => switch (d) {
  Difficulty.small => '●',
  Difficulty.medium => '●●',
  Difficulty.big => '●●●',
};

/// The app's one icon set for quest categories (rounded Material icons).
IconData categoryIcon(QuestCategory c) => switch (c) {
  QuestCategory.sleep => Icons.bedtime_rounded,
  QuestCategory.movement => Icons.directions_walk_rounded,
  QuestCategory.mind => Icons.self_improvement_rounded,
  QuestCategory.social => Icons.favorite_rounded,
  QuestCategory.home => Icons.home_rounded,
  QuestCategory.foodWater => Icons.water_drop_rounded,
  QuestCategory.studyWork => Icons.menu_book_rounded,
};

/// A category icon in a soft pastel circle.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge(this.category, {super.key, this.size = 32});

  final QuestCategory category;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: categoryColor(category),
      shape: BoxShape.circle,
      border: Border.all(color: Chunky.edge(categoryColor(category)), width: 1.5),
    ),
    alignment: Alignment.center,
    child: Icon(
      categoryIcon(category),
      size: size * 0.55,
      color: Color.lerp(categoryColor(category), Colors.black, 0.55),
      semanticLabel: category.label,
    ),
  );
}

/// Small faint dots for a quest's size: one, two or three.
class DifficultyDots extends StatelessWidget {
  const DifficultyDots(this.difficulty, {super.key});

  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
    return Semantics(
      label: '${difficulty.label} quest',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < difficulty.index + 1; i++)
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
