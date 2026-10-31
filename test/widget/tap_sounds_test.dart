import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/core/providers.dart';
import 'package:sprout/core/sound_service.dart';
import 'package:sprout/ui/widgets/tap_sounds.dart';

class _Recorder implements SoundService {
  final played = <Sfx>[];

  @override
  void play(Sfx sfx) => played.add(sfx);

  @override
  void setMusic(String? envId) {}

  @override
  void setEnabled(bool on) {}

  @override
  void setMusicEnabled(bool on) {}
}

void main() {
  testWidgets('buttons tick; scrolls and plain text stay quiet', (tester) async {
    final sounds = _Recorder();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [soundServiceProvider.overrideWithValue(sounds)],
        child: MaterialApp(
          builder: (context, child) => TapSounds(child: child!),
          home: Scaffold(
            body: ListView(
              children: [
                FilledButton(onPressed: () {}, child: const Text('Go')),
                const Text('Just words'),
                for (var i = 0; i < 30; i++) SizedBox(height: 60, child: Text('Row $i')),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    expect(sounds.played, [Sfx.tap]);

    await tester.tap(find.text('Just words'));
    expect(sounds.played, [Sfx.tap], reason: 'not a button');

    await tester.drag(find.text('Go'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(sounds.played, [Sfx.tap], reason: 'a scroll is not a tap');
  });
}
