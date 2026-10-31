import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/logic/ben.dart';
import '../../ui/art/character_art.dart';
import '../../ui/widgets/motion.dart';

const benLinesAsset = 'assets/content/ben_lines.json';

final benLinesProvider = FutureProvider<BenLines>(
  (ref) async => BenLines.fromJson(jsonDecode(await rootBundle.loadString(benLinesAsset)) as Map<String, dynamic>),
);

class BenState {
  const BenState(this.text, this.mood);

  final String text;
  final BenMood mood;
}

/// What Ben is saying and how he looks right now.
final benProvider = NotifierProvider<BenController, BenState>(BenController.new);

class BenController extends Notifier<BenState> {
  final _random = math.Random();
  Timer? _settle;

  @override
  BenState build() {
    ref.onDispose(() => _settle?.cancel());
    final lines = ref.watch(benLinesProvider).value;
    final today = ref.watch(clockProvider).now();
    return BenState(
      lines == null ? 'Hello! Lovely to see you.' : 'Fun fact: ${lines.factOfTheDay(today)}',
      BenMood.idle,
    );
  }

  void _say(String text, BenMood mood) {
    state = BenState(text, mood);
    _settle?.cancel();
    _settle = Timer(const Duration(milliseconds: 1600), () => state = BenState(state.text, BenMood.idle));
  }

  /// Tapping Ben: a greeting, a tip or some encouragement, never the same twice.
  void chat() {
    final lines = ref.read(benLinesProvider).value;
    if (lines != null) _say(lines.chat(_random, previous: state.text), BenMood.talking);
  }

  /// A short warm reaction after buying, selling, composting or unlocking.
  void react(BenLineType type) {
    final lines = ref.read(benLinesProvider).value;
    if (lines != null) {
      _say(
        lines.pick([type], _random, previous: state.text),
        type == BenLineType.noCoins ? BenMood.talking : BenMood.happy,
      );
    }
  }
}

/// Ben's little shop window: a soft sky, a striped awning, Ben behind his
/// counter and his speech bubble. Tap him for a new line.
class BenWindow extends ConsumerStatefulWidget {
  const BenWindow({super.key, this.height = 196});

  final double height;

  @override
  ConsumerState<BenWindow> createState() => _BenWindowState();
}

class _BenWindowState extends ConsumerState<BenWindow> with SingleTickerProviderStateMixin {
  late final _life = AnimationController(vsync: this, duration: const Duration(seconds: 5));

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calm = reduceMotion(context, ref);
    if (calm) {
      if (_life.isAnimating) _life.stop();
    } else if (!_life.isAnimating) {
      _life.repeat();
    }
    final ben = ref.watch(benProvider);
    final now = ref.watch(nowProvider).value ?? ref.watch(clockProvider).now();
    final hour = now.hour + now.minute / 60;

    // A painted frame: a soft outline over the scene and a lip underneath.
    const frame = Color(0xFFDCC9B6);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: frame, offset: Offset(0, 3))],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: frame, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: widget.height,
          child: AnimatedBuilder(
            animation: _life,
            builder: (context, _) {
              final t = calm ? 0.0 : _life.value;
              // A quick blink near the end of each loop.
              final blink = t > 0.94 ? math.sin((t - 0.94) / 0.06 * math.pi) : 0.0;
              final sway = math.sin(t * 2 * math.pi);
              final bob = ben.mood == BenMood.idle || calm ? 0.0 : (math.sin(t * 2 * math.pi * 10).abs());
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _StallPainter(hour: hour)),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 34,
                    child: Semantics(
                      button: true,
                      label: 'Ben the shopkeeper. Tap to chat',
                      excludeSemantics: true,
                      onTap: () => ref.read(benProvider.notifier).chat(),
                      child: GestureDetector(
                        onTap: () => ref.read(benProvider.notifier).chat(),
                        child: characterArt.ben(
                          mood: ben.mood,
                          size: widget.height * 0.7,
                          blink: blink,
                          sway: sway,
                          bob: bob,
                        ),
                      ),
                    ),
                  ),
                  Positioned(left: 0, right: 0, bottom: 0, height: 40, child: CustomPaint(painter: _CounterPainter())),
                  Positioned(
                    left: widget.height * 0.7 + 4,
                    right: 12,
                    top: 30,
                    child: _SpeechBubble(text: ben.text, reduceMotion: calm),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text, required this.reduceMotion});

  final String text;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 260),
    transitionBuilder: (child, a) => FadeTransition(
      opacity: a,
      child: ScaleTransition(
        scale: Tween(begin: 0.92, end: 1.0).animate(a),
        alignment: Alignment.centerLeft,
        child: child,
      ),
    ),
    child: Container(
      key: ValueKey(text),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Text(
        text,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13.5, height: 1.3, fontWeight: FontWeight.w700, color: Color(0xFF3B3346)),
      ),
    ),
  );
}

/// The soft sky behind the stall and its striped awning.
class _StallPainter extends CustomPainter {
  _StallPainter({required this.hour});

  final double hour;

  @override
  void paint(Canvas canvas, Size size) {
    final night = hour < 6 || hour >= 20;
    final evening = hour >= 17 && !night;
    final colors = night
        ? const [Color(0xFF3E4A7E), Color(0xFF6E6A9E)]
        : evening
        ? const [Color(0xFFF7C1AE), Color(0xFFFFE7CC)]
        : const [Color(0xFFCFE8F7), Color(0xFFFFF4E4)];
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(rect),
    );
    // A distant hill and a couple of bushes.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.75, size.height * 0.92),
        width: size.width * 0.9,
        height: size.height * 0.5,
      ),
      Paint()..color = (night ? const Color(0xFF4F7A68) : const Color(0xFFB9DFB0)),
    );
    // Striped, scalloped awning.
    final stripe = size.width / 9;
    for (var i = 0; i < 9; i++) {
      final paint = Paint()..color = i.isEven ? const Color(0xFFF7A58C) : const Color(0xFFFFF4E4);
      canvas.drawRect(Rect.fromLTWH(i * stripe, 0, stripe + 0.5, 18), paint);
      canvas.drawArc(Rect.fromLTWH(i * stripe, 8, stripe, 20), 0, math.pi, true, paint);
    }
  }

  @override
  bool shouldRepaint(_StallPainter old) => old.hour != hour;
}

/// The wooden counter Ben stands behind, with a few fruit crates.
class _CounterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final top = Rect.fromLTWH(0, 0, size.width, 10);
    canvas.drawRect(top, Paint()..color = const Color(0xFFC99A6E));
    canvas.drawRect(Rect.fromLTWH(0, 10, size.width, size.height - 10), Paint()..color = const Color(0xFFDDB386));
    final plank = Paint()
      ..color = const Color(0xFFC99A6E)
      ..strokeWidth = 1.5;
    for (var x = size.width / 6; x < size.width; x += size.width / 6) {
      canvas.drawLine(Offset(x, 12), Offset(x, size.height), plank);
    }
    // Fruit piled on the counter.
    const fruit = [Color(0xFFE8574F), Color(0xFFFFC93C), Color(0xFF8CC97E), Color(0xFFE5486B), Color(0xFFFFA07A)];
    for (var i = 0; i < 7; i++) {
      final x = size.width * (0.55 + i * 0.06);
      canvas.drawCircle(Offset(x, -4 - (i % 2) * 3), 7, Paint()..color = fruit[i % fruit.length]);
    }
  }

  @override
  bool shouldRepaint(_CounterPainter old) => false;
}
