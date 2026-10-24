import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Settings key set once the first-run tips have been seen.
const tutorialDoneKey = 'tutorial_done';

final tutorialDoneProvider = FutureProvider<bool>(
  (ref) async => await ref.watch(settingsRepositoryProvider).readValue(tutorialDoneKey) == 'true',
);

const _tips = [
  ('🌱', 'Finish quests to fill your Seed Meter. Every 3 earns a seed.'),
  ('➕', 'Tap a "+" ring to plant a seed. Use the arrows to visit each spot.'),
  ('🎒', 'Your Bag holds your seeds and fruit. Sell fruit in the Shop.'),
];

/// Three gentle first-run tips on Home, shown once. Skippable.
class HomeTutorial extends ConsumerStatefulWidget {
  const HomeTutorial({super.key});

  @override
  ConsumerState<HomeTutorial> createState() => _HomeTutorialState();
}

class _HomeTutorialState extends ConsumerState<HomeTutorial> {
  int _step = 0;

  Future<void> _finish() async {
    await ref.read(settingsRepositoryProvider).writeValue(tutorialDoneKey, 'true');
    ref.invalidate(tutorialDoneProvider);
  }

  @override
  Widget build(BuildContext context) {
    final done = ref.watch(tutorialDoneProvider).value ?? true;
    if (done) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final (emoji, text) = _tips[_step];
    final last = _step == _tips.length - 1;
    return Material(
      color: const Color(0xFF3B3346).withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, height: 1.35)),
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${_step + 1} of ${_tips.length}',
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(width: 8),
                if (!last)
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Skip', style: TextStyle(color: Colors.white70)),
                  ),
                TextButton(
                  onPressed: last ? _finish : () => setState(() => _step++),
                  child: Text(last ? 'Got it' : 'Next', style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
