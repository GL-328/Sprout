import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers.dart';
import 'domain/models/app_settings.dart';
import 'features/home/home_screen.dart';
import 'features/journal/journal_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/shop/shop_screen.dart';
import 'features/today/today_screen.dart';
import 'ui/theme/app_theme.dart';

abstract final class Routes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const today = '/today';
  static const journal = '/journal';
  static const shop = '/shop';
  static const settings = '/settings';
}

GoRouter buildRouter({required bool onboardingDone}) => GoRouter(
  initialLocation: onboardingDone ? Routes.home : Routes.onboarding,
  routes: [
    GoRoute(path: Routes.onboarding, builder: (context, state) => const OnboardingScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: Routes.home, builder: (c, s) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: Routes.today, builder: (c, s) => const TodayScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: Routes.journal, builder: (c, s) => const JournalScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: Routes.shop, builder: (c, s) => const ShopScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: Routes.settings, builder: (c, s) => const SettingsScreen())],
        ),
      ],
    ),
  ],
);

final routerProvider = Provider<GoRouter>((ref) {
  final router = buildRouter(onboardingDone: ref.read(initialSettingsProvider).onboardingDone);
  ref.onDispose(router.dispose);
  return router;
});

class SproutApp extends ConsumerWidget {
  const SproutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps reminders in sync with settings and quests.
    ref.listen(reminderSyncProvider, (_, _) {});
    final theme = ref.watch(settingsProvider.select((s) => s.theme));
    final accent = ref.watch(settingsProvider.select((s) => s.accent));
    return MaterialApp.router(
      title: 'Sprout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light, accent),
      darkTheme: AppTheme.build(Brightness.dark, accent),
      themeMode: switch (theme) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
