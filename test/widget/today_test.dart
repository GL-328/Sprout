import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/clock.dart';
import 'package:sprout/data/repositories/quest_repository.dart';
import 'package:sprout/data/repositories/seed_repository.dart';
import 'package:sprout/domain/models/app_settings.dart';
import 'package:sprout/domain/models/enums.dart';

import 'test_app.dart';

void main() {
  testWidgets('completing a quest fills the meter and can be undone', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() async {
      await SeedRepository(db, const Clock()).ensurePlot('meadow');
      await QuestRepository(
        db,
        const Clock(),
      ).create(title: 'Drink water', category: QuestCategory.foodWater, difficulty: Difficulty.small);
    });

    await tester.pumpWidget(testApp(db, settings: const AppSettings(onboardingDone: true, reducedMotion: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today').last);
    await tester.pumpAndSettle();

    expect(find.text('Drink water'), findsOneWidget);
    expect(find.textContaining('Finish 3 quests'), findsOneWidget);

    await tester.ensureVisible(find.bySemanticsLabel('Complete Drink water'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Complete Drink water'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 of 3'), findsOneWidget);
    expect(find.text('Done today (1)'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Finish 3 quests'), findsOneWidget);
    expect(find.text('Drink water'), findsOneWidget);
  });
}
