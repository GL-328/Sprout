import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/sound_service.dart';

/// A soft tick for every button in the app, from one place. A tap counts
/// when the finger lifts close to where it went down, on something that
/// says it is a button (Material buttons, and anything wrapped in
/// `Semantics(button: true)`). Scrolls and drags stay silent.
class TapSounds extends ConsumerStatefulWidget {
  const TapSounds({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<TapSounds> createState() => _TapSoundsState();
}

class _TapSoundsState extends ConsumerState<TapSounds> {
  final _downs = <int, (Offset, Duration)>{};

  bool _onButton(Offset position) {
    final result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(result, position, View.of(context).viewId);
    for (final entry in result.path) {
      final target = entry.target;
      if (target is SemanticsAnnotationsMixin) {
        final p = target.properties;
        if (p.button == true && p.enabled != false) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: (e) => _downs[e.pointer] = (e.position, e.timeStamp),
    onPointerCancel: (e) => _downs.remove(e.pointer),
    onPointerUp: (e) {
      final down = _downs.remove(e.pointer);
      if (down == null) return;
      final (at, time) = down;
      final quick = e.timeStamp - time < const Duration(milliseconds: 500);
      if (quick && (e.position - at).distance < 18 && _onButton(e.position)) {
        ref.read(soundServiceProvider).play(Sfx.tap);
      }
    },
    child: widget.child,
  );
}
