import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum Sfx { complete, seed, coin, harvest, plant }

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
  AudioPlayer? _ambient;

  @override
  void setEnabled(bool on) {
    _enabled = on;
    _syncAmbient();
  }

  @override
  void play(Sfx sfx) {
    if (!_enabled) return;
    _effects.play(AssetSource('sounds/${sfx.name}.wav'), volume: 0.6).catchError((Object e) {
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
