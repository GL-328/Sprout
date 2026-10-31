import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Large rounded card with a soft shadow. The building block of most screens.
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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF8C6E5A).withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
