import 'package:flutter/material.dart';

import '../../domain/models/enums.dart';

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
