import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// True when animations should be kept to a minimum, either because the user
/// chose "Reduce motion" in Sprout or turned animations off system-wide.
bool reduceMotion(BuildContext context, WidgetRef ref) =>
    ref.watch(settingsProvider.select((s) => s.reducedMotion)) || MediaQuery.of(context).disableAnimations;

/// Duration helper: [normal] unless motion is reduced.
Duration motionDuration(BuildContext context, WidgetRef ref, Duration normal) =>
    reduceMotion(context, ref) ? Duration.zero : normal;
