import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum Sfx {
  complete(0.6),
  seed(0.6),
  coin(0.5),
  harvest(0.55),
  plant(0.55),

  /// Small and quiet: taps, swipes and hellos.
  tap(0.18, quick: true),
  swipe(0.15, quick: true),
  pop(0.22, quick: true),
  chirp(0.3, quick: true),
  mood(0.35),
  compost(0.45);

  const Sfx(this.volume, {this.quick = false});

  /// Every sound is soft; the little ones are softer still.
  final double volume;

  /// Short sounds that play on their own low-latency player, so a tap never
  /// cuts off a bigger sound.
  final bool quick;
}

/// Optional soft sounds. Silent unless the user turns sound on in Settings.
abstract class SoundService {
  void play(Sfx sfx);

  /// Starts or stops the garden ambience.
  void setAmbient(bool on);

  void setEnabled(bool on);
}

class SilentSoundService implements SoundService {
  const SilentSoundService();

  @override
  void play(Sfx sfx) {}

  @override
  void setAmbient(bool on) {}

  @override
  void setEnabled(bool on) {}
}

class AudioSoundService implements SoundService {
  AudioSoundService({bool enabled = false}) : _enabled = enabled; // ignore: prefer_initializing_formals

  bool _enabled;
  bool _wantAmbient = false;
  final _effects = AudioPlayer();
  final _quick = AudioPlayer();
  AudioPlayer? _ambient;

  @override
  void setEnabled(bool on) {
    _enabled = on;
    _syncAmbient();
  }

  @override
  void play(Sfx sfx) {
    if (!_enabled) return;
    final player = sfx.quick ? _quick : _effects;
    player
        .play(
          AssetSource('sounds/${sfx.name}.wav'),
          volume: sfx.volume,
          mode: sfx.quick ? PlayerMode.lowLatency : PlayerMode.mediaPlayer,
        )
        .catchError((Object e) {
          debugPrint('Sound failed: $e');
        });
  }

  @override
  void setAmbient(bool on) {
    _wantAmbient = on;
    _syncAmbient();
  }

  Future<void> _syncAmbient() async {
    try {
      if (_enabled && _wantAmbient) {
        final player = _ambient ??= AudioPlayer();
        if (player.state != PlayerState.playing) {
          await player.setReleaseMode(ReleaseMode.loop);
          await player.play(AssetSource('sounds/ambient.wav'), volume: 0.25);
        }
      } else {
        await _ambient?.pause();
      }
    } catch (e) {
      debugPrint('Ambient sound failed: $e');
    }
  }
}
