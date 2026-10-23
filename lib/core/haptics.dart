import 'dart:async';

import 'package:flutter/services.dart';

/// Soft haptic taps. Fire and forget.
abstract final class Haptics {
  static void selection() => unawaited(HapticFeedback.selectionClick());
  static void light() => unawaited(HapticFeedback.lightImpact());
  static void medium() => unawaited(HapticFeedback.mediumImpact());
}
