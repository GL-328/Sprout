import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/chunky.dart';

/// Large rounded card with a soft outline and lip. The building block of most screens.
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.color, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final fill = color ?? theme.colorScheme.surface;
    final radius = BorderRadius.circular(AppTheme.radius);
    // Painted cards: a soft outline and a solid lip, not a blurry shadow.
    return DecoratedBox(
      decoration: Chunky.box(fill, radius: radius, dark: dark),
      child: Material(
        color: fill,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
