import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum Sfx {
  complete(0.6),
  seed(0.6),
  coin(0.5),
  harvest(0.55),
  plant(0.55),

  /// Small and quiet: button pops, switch clicks and hellos.
  tap(0.2, quick: true, variants: 3),
  toggle(0.2, quick: true),
  chirp(0.3, quick: true),
  mood(0.35),
  compost(0.45);

  const Sfx(this.volume, {this.quick = false, this.variants = 1});

  /// Every sound is soft; the little ones are softer still.
  final double volume;

  /// Short sounds that play on their own low-latency player, so a tap never
  /// cuts off a bigger sound.
  final bool quick;

  /// How many takes there are (`tap`, `tap2`, `tap3`), so repeats don't sound samey.
  final int variants;

  /// The file for take [i].
  String file(int i) => 'sounds/$name${i % variants == 0 ? '' : '${i % variants + 1}'}.wav';
}

/// The music for each plot: `assets/music/<plot>.ogg`.
String musicAsset(String envId) => 'music/$envId.ogg';

/// Optional soft sounds and music. Silent unless the user turns them on in
/// Settings.
abstract class SoundService {
  void play(Sfx sfx);

  /// Plays [envId]'s music, gently crossfading from whatever was playing.
  /// `null` fades the music out (Home hidden, or the app in the background).
  void setMusic(String? envId);

  void setEnabled(bool on);

  void setMusicEnabled(bool on);

  /// Stops everything, when the app swaps to another account.
  void dispose();
}

class SilentSoundService implements SoundService {
  const SilentSoundService();

  @override
  void play(Sfx sfx) {}

  @override
  void setMusic(String? envId) {}

  @override
  void setEnabled(bool on) {}

  @override
  void setMusicEnabled(bool on) {}

  @override
  void dispose() {}
}

class AudioSoundService implements SoundService {
  AudioSoundService({bool enabled = false, bool musicEnabled = false})
    : _enabled = enabled, // ignore: prefer_initializing_formals
      _musicEnabled = musicEnabled; // ignore: prefer_initializing_formals

  static const _musicVolume = 0.22;

  /// Sound effects mix in and never take Android's audio focus. Taking it
  /// made the garden music pause on every tap.
  static final _mixIn = AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();

  bool _enabled;
  bool _musicEnabled;
  final _effects = AudioPlayer();
  final _quick = AudioPlayer();
  final _lastQuick = <Sfx, DateTime>{};
  var _take = 0;

  AudioPlayer? _music;
  String? _wantTrack;
  String? _playingTrack;
  Timer? _fade;
  bool _resuming = false;

  @override
  void setEnabled(bool on) => _enabled = on;

  @override
  void dispose() {
    _fade?.cancel();
    for (final player in [_effects, _quick, ?_music]) {
      player.dispose().catchError((Object _) {});
    }
  }

  @override
  void setMusicEnabled(bool on) {
    _musicEnabled = on;
    _syncMusic();
  }

  @override
  void play(Sfx sfx) {
    if (!_enabled) return;
    if (sfx.quick) {
      // One tick per tap, even when a button and what it moves both ask.
      final now = DateTime.now();
      final last = _lastQuick[sfx];
      if (last != null && now.difference(last) < const Duration(milliseconds: 120)) return;
      _lastQuick[sfx] = now;
    }
    final player = sfx.quick ? _quick : _effects;
    player
        .play(
          AssetSource(sfx.file(_take++)),
          volume: sfx.volume,
          ctx: _mixIn,
          mode: sfx.quick ? PlayerMode.lowLatency : PlayerMode.mediaPlayer,
        )
        .catchError((Object e) {
          debugPrint('Sound failed: $e');
        });
  }

  @override
  void setMusic(String? envId) {
    _wantTrack = envId;
    _syncMusic();
  }

  /// Fades the current track out, then the wanted one in.
  void _syncMusic() {
    final target = _musicEnabled ? _wantTrack : null;
    if (target == _playingTrack) {
      // Something else (a call, another app) paused it: pick up again.
      final player = _music;
      if (target != null && player != null && player.state == PlayerState.paused && !_resuming) {
        _resuming = true;
        player.resume().catchError((Object _) {}).whenComplete(() => _resuming = false);
      }
      return;
    }
    _fadeTo(0, () async {
      final player = _music ??= AudioPlayer();
      try {
        if (target == null) {
          await player.pause();
        } else {
          await player.setReleaseMode(ReleaseMode.loop);
          await player.play(AssetSource(musicAsset(target)), volume: 0);
        }
        _playingTrack = target;
        if (target != null) _fadeTo(_musicVolume, null);
      } catch (e) {
        debugPrint('Music failed: $e');
      }
    });
  }

  void _fadeTo(double volume, Future<void> Function()? then) {
    _fade?.cancel();
    final player = _music;
    if (player == null || _playingTrack == null) {
      then?.call();
      return;
    }
    const steps = 10;
    final from = player.volume;
    var step = 0;
    _fade = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      step++;
      player.setVolume(from + (volume - from) * step / steps).catchError((Object _) {});
      if (step >= steps) {
        timer.cancel();
        then?.call();
      }
    });
  }
}
