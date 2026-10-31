import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/haptics.dart';
import '../../ui/layout/insets.dart';
import '../../ui/theme/chunky.dart';

/// Scaffold with the floating, rounded bottom navigation bar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (icon: Icons.local_florist_outlined, selected: Icons.local_florist, label: 'Home'),
    (icon: Icons.check_circle_outline, selected: Icons.check_circle, label: 'Today'),
    (icon: Icons.menu_book_outlined, selected: Icons.menu_book, label: 'Journal'),
    (icon: Icons.storefront_outlined, selected: Icons.storefront, label: 'Shop'),
    (icon: Icons.settings_outlined, selected: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final navHeight = AppInsets.shellNavHeight(MediaQuery.viewPaddingOf(context).bottom);
    return Scaffold(
      extendBody: true,
      body: ShellInsets(navBarHeight: navHeight, child: navigationShell),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, AppInsets.navBarMargin),
        // Labels stay readable but never outgrow the bar at large font sizes.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.15,
          child: _FloatingNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (i) {
              Haptics.selection();
              navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);
            },
          ),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: AppInsets.navBar,
      decoration: Chunky.box(
        scheme.surface,
        radius: BorderRadius.circular(34),
        dark: theme.brightness == Brightness.dark,
        lipHeight: 4,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          for (final (i, tab) in AppShell._tabs.indexed)
            Expanded(
              child: Semantics(
                selected: i == currentIndex,
                button: true,
                label: tab.label,
                child: InkResponse(
                  onTap: () => onTap(i),
                  radius: 36,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 1),
                    // The selected tab is a little painted pill in the accent colour.
                    decoration: i == currentIndex
                        ? Chunky.box(scheme.primary, radius: BorderRadius.circular(26), lipHeight: 2.5)
                        : BoxDecoration(borderRadius: BorderRadius.circular(26)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == currentIndex ? tab.selected : tab.icon,
                          color: i == currentIndex ? Colors.white : scheme.onSurfaceVariant,
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            tab.label,
                            maxLines: 1,
                            softWrap: false,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: i == currentIndex ? Colors.white : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
