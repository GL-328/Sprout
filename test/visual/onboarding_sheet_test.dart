import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widget/test_app.dart';
import 'render.dart';

/// Renders every setup step at a small phone size, to check by eye that the
/// main button is pinned and nothing is cut off.
void main() {
  for (final scale in [1.0, 1.3]) {
    final tag = '${(scale * 100).round()}';
    testWidgets('setup steps at $tag% text', (tester) async {
      await loadAppFonts();
      setPhoneScreen(tester, textScale: scale, systemBar: 48);
      final db = memoryDb();
      addTearDown(db.close);
      await tester.pumpWidget(shot(testApp(db)));
      await tester.pumpAndSettle();

      Future<void> step(String name, String button) async {
        await savePng(tester, 'setup_${name}_$tag');
        await tester.tap(find.text(button));
        await tester.pumpAndSettle();
      }

      await step('1_welcome', "Let's begin");
      await step('2_name', 'Next');
      await savePng(tester, 'setup_3_picker_$tag');
      for (final title in ['Screens off before bed', 'Wind-down moment']) {
        await tester.scrollUntilVisible(find.bySemanticsLabel(title), 120, scrollable: find.byType(Scrollable).last);
        await tester.ensureVisible(find.bySemanticsLabel(title));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel(title));
      }
      await tester.pump();
      await savePng(tester, 'setup_3_picker_picked_$tag');
      await tester.tap(find.textContaining('Continue'));
      await tester.pumpAndSettle();
      await step('4_reminders', 'Next');
      await savePng(tester, 'setup_5_seed_$tag');
    });
  }
}
