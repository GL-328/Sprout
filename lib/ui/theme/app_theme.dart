import 'package:flutter/material.dart';

import '../../domain/models/app_settings.dart';

/// Soft pastel palette with a warm accent.
class SproutColors {
  static const cream = Color(0xFFFFF8F0);
  static const paper = Color(0xFFFFFFFF);
  static const ink = Color(0xFF3B3346);
  static const inkSoft = Color(0xFF7A7089);
  static const night = Color(0xFF1F1B26);
  static const nightCard = Color(0xFF2B2635);
  static const nightInk = Color(0xFFF3EEF8);
  static const nightInkSoft = Color(0xFFB9B0C6);

  static const mint = Color(0xFFCDEBD9);
  static const sky = Color(0xFFCFE6F7);
  static const butter = Color(0xFFFFEDB8);
  static const blush = Color(0xFFFAD6DA);
  static const lilac = Color(0xFFE3D9F5);
  static const coin = Color(0xFFF4B740);

  static Color accent(AccentChoice choice) => switch (choice) {
    AccentChoice.peach => const Color(0xFFF59E7A),
    AccentChoice.sage => const Color(0xFF7FB890),
    AccentChoice.lilac => const Color(0xFFA48ADB),
    AccentChoice.sky => const Color(0xFF6FAEDD),
    AccentChoice.rose => const Color(0xFFE88AA4),
  };
}

class AppTheme {
  static const radius = 24.0;
  static const fontFamily = 'Nunito';

  static ThemeData build(Brightness brightness, AccentChoice accentChoice) {
    final dark = brightness == Brightness.dark;
    final accent = SproutColors.accent(accentChoice);
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      primary: accent,
      onPrimary: Colors.white,
      surface: dark ? SproutColors.nightCard : SproutColors.paper,
      onSurface: dark ? SproutColors.nightInk : SproutColors.ink,
      onSurfaceVariant: dark ? SproutColors.nightInkSoft : SproutColors.inkSoft,
    );
    final background = dark ? SproutColors.night : SproutColors.cream;
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: fontFamily, brightness: brightness);
    final text = base.textTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(100));
    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        // The text theme has no sizes yet at this point (Flutter adds them later),
        // so the title's size is set here, or it falls back to 14.
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: pill,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: pill,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: pill,
          textStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: pill,
        side: BorderSide.none,
        labelStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, color: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? SproutColors.night : SproutColors.cream,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : null),
      ),
    );
  }
}
