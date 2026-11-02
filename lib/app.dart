import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/home_widgets.dart';
import 'core/providers.dart';
import 'domain/models/app_settings.dart';
import 'features/home/home_screen.dart';
import 'features/mood/mood_check_in_card.dart';
import 'features/journal/journal_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/update_controller.dart';
import 'features/shell/app_shell.dart';
import 'features/shop/shop_screen.dart';
import 'features/today/today_screen.dart';
import 'ui/theme/app_theme.dart';
import 'ui/widgets/tap_sounds.dart';
import 'features/home/garden_providers.dart';

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

class SproutApp extends ConsumerStatefulWidget {
  const SproutApp({super.key});

  @override
  ConsumerState<SproutApp> createState() => _SproutAppState();
}

class _SproutAppState extends ConsumerState<SproutApp> {
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<Uri?>? _widgetTaps;

  @override
  void initState() {
    super.initState();
    // Look for updates after the first frame and whenever the app comes back.
    final updates = ref.read(updateControllerProvider.notifier);
    _lifecycle = AppLifecycleListener(
      onHide: updates.onLeave,
      onPause: updates.onLeave,
      onResume: () async {
        await updates.onReturn();
        await updates.check();
      },
    );
    _widgetTaps = listenForWidgetLinks(ref.read(homeWidgetBridgeProvider), _openLink);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await updates.afterLaunch();
      await updates.check();
    });
  }

  /// A tap on a home-screen widget: Today opens the Today tab, a mood face
  /// opens the mood picker with that face chosen.
  Future<void> _openLink(WidgetLink link) async {
    if (!mounted || !ref.read(settingsProvider).onboardingDone) return;
    final router = ref.read(routerProvider);
    switch (link) {
      case TodayLink():
        router.go(Routes.today);
      case MoodLink(:final mood):
        router.go(Routes.home);
        // Wait for the app to be on screen (it may have only just started).
        BuildContext? context;
        for (var i = 0; i < 40 && mounted; i++) {
          await WidgetsBinding.instance.endOfFrame;
          context = router.routerDelegate.navigatorKey.currentContext;
          if (context != null && ref.read(todayMoodProvider).hasValue) break;
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        if (mounted && context != null && context.mounted) await showMoodSheet(context, ref, initial: mood);
    }
  }

  @override
  void dispose() {
    _widgetTaps?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keeps reminders in sync with settings and quests.
    ref.listen(reminderSyncProvider, (_, _) {});
    ref.listen(gardenNoticeSyncProvider, (_, _) {});
    ref.listen(homeWidgetSyncProvider, (_, _) {});
    final theme = ref.watch(settingsProvider.select((s) => s.theme));
    final accent = ref.watch(settingsProvider.select((s) => s.accent));
    return MaterialApp.router(
      title: 'Sprout',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootMessengerKey,
      theme: AppTheme.build(Brightness.light, accent),
      darkTheme: AppTheme.build(Brightness.dark, accent),
      themeMode: switch (theme) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      },
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => TapSounds(child: child ?? const SizedBox.shrink()),
    );
  }
}
