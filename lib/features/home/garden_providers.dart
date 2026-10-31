import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/counters_repository.dart';
import '../../data/repositories/wellbeing_repository.dart';
import '../../data/services/economy_service.dart';
import '../../domain/logic/streaks.dart';
import '../../domain/models/plant.dart';

/// Unlocked plots and when they were unlocked.
/// The plot Home is showing, so the shell can play its music.
final shownPlotProvider = NotifierProvider<ShownPlot, String?>(ShownPlot.new);

class ShownPlot extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String envId) => state = envId;
}

final plotsProvider = StreamProvider<Map<String, DateTime>>((ref) => ref.watch(seedRepositoryProvider).watchPlots());

final plantsInPlotProvider = StreamProvider.family<List<Plant>, String>(
  (ref, envId) => ref.watch(gardenServiceProvider).watchPlants(envId),
);

final allPlantsProvider = StreamProvider<List<Plant>>((ref) => ref.watch(gardenServiceProvider).watchAllPlants());

final inventoryProvider = StreamProvider<Map<String, int>>((ref) => ref.watch(gardenServiceProvider).watchInventory());

final coinsProvider = StreamProvider<int>((ref) => ref.watch(countersRepositoryProvider).watch(CounterKeys.coins));

final countersProvider = StreamProvider<Map<String, int>>((ref) => ref.watch(countersRepositoryProvider).watchAll());

final todayMoodProvider = StreamProvider<MoodEntry?>((ref) {
  final day = ref.watch(todayKeyProvider);
  return ref.watch(wellbeingRepositoryProvider).watchMood(day);
});

final restDaysProvider = StreamProvider<Set<String>>((ref) => ref.watch(wellbeingRepositoryProvider).watchRestDays());

final activeDaysProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(wellbeingRepositoryProvider).watchActiveDays(),
);

final streakProvider = Provider<int>((ref) {
  ref.watch(restDaysProvider);
  final days = ref.watch(activeDaysProvider).value ?? const {};
  final now = ref.watch(nowProvider).value ?? ref.watch(clockProvider).now();
  return gentleStreak(activeDays: days, now: now);
});

/// Recipes already made today (each can be made once a day).
final recipesMadeTodayProvider = StreamProvider<Set<String>>((ref) {
  ref.watch(todayKeyProvider);
  return ref.watch(economyServiceProvider).watchRecipesMadeToday();
});

final ownedCosmeticsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(economyServiceProvider).watchOwnedCosmetics(),
);

final placedCosmeticsProvider = StreamProvider<Map<String, Map<String, String>>>(
  (ref) => ref.watch(economyServiceProvider).watchPlacedCosmetics(),
);

final visitorsSeenProvider = StreamProvider<Map<String, VisitorSeenRow>>(
  (ref) => ref.watch(economyServiceProvider).watchVisitorsSeen(),
);

/// Whether a recipe's visitor lure is active.
final visitorLureProvider = FutureProvider<bool>((ref) async {
  final now = ref.watch(nowProvider).value ?? ref.watch(clockProvider).now();
  final raw = await ref.watch(settingsRepositoryProvider).readValue(visitorLureUntilKey);
  final until = raw == null ? null : DateTime.tryParse(raw);
  return until != null && until.isAfter(now);
});
