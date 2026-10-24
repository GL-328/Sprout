import 'package:flutter/material.dart';

/// Fades and slides its child in once, unless [enabled] is false.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.enabled = true, this.delay = Duration.zero});

  final Widget child;
  final bool enabled;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final total = const Duration(milliseconds: 420) + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/// A number that rolls smoothly to its new value.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({super.key, required this.value, this.style, this.enabled = true});

  final int value;
  final TextStyle? style;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: value.toDouble()),
    duration: enabled ? const Duration(milliseconds: 700) : Duration.zero,
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => Text('${v.round()}', style: style),
  );
}
