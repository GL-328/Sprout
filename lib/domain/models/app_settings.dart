import 'enums.dart';

enum ThemePreference { system, light, dark }

/// Accent colours the user can pick. The colour values live in the theme.
enum AccentChoice { peach, sage, lilac, sky, rose }

/// User preferences and onboarding state.
class AppSettings {
  const AppSettings({
    this.name = '',
    this.onboardingDone = false,
    this.focusAreas = const {},
    this.theme = ThemePreference.system,
    this.accent = AccentChoice.peach,
    this.soundOn = false,
    this.reducedMotion = false,
    this.remindersOn = false,
    this.checkInReminderMinutes = 9 * 60,
    this.autoUpdate = true,
  });

  final String name;
  final bool onboardingDone;
  final Set<QuestCategory> focusAreas;
  final ThemePreference theme;
  final AccentChoice accent;
  final bool soundOn;
  final bool reducedMotion;

  /// Master switch for gentle reminders. Off unless the user turns it on.
  final bool remindersOn;

  /// Time of the daily check-in reminder, in minutes after midnight.
  final int checkInReminderMinutes;

  /// Check GitHub for a newer build and install it. On unless turned off.
  final bool autoUpdate;

  AppSettings copyWith({
    String? name,
    bool? onboardingDone,
    Set<QuestCategory>? focusAreas,
    ThemePreference? theme,
    AccentChoice? accent,
    bool? soundOn,
    bool? reducedMotion,
    bool? remindersOn,
    int? checkInReminderMinutes,
    bool? autoUpdate,
  }) => AppSettings(
    name: name ?? this.name,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    focusAreas: focusAreas ?? this.focusAreas,
    theme: theme ?? this.theme,
    accent: accent ?? this.accent,
    soundOn: soundOn ?? this.soundOn,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    remindersOn: remindersOn ?? this.remindersOn,
    checkInReminderMinutes: checkInReminderMinutes ?? this.checkInReminderMinutes,
    autoUpdate: autoUpdate ?? this.autoUpdate,
  );

  Map<String, String> toEntries() => {
    'name': name,
    'onboarding_done': '$onboardingDone',
    'focus_areas': focusAreas.map((c) => c.id).join(','),
    'theme': theme.name,
    'accent': accent.name,
    'sound_on': '$soundOn',
    'reduced_motion': '$reducedMotion',
    'reminders_on': '$remindersOn',
    'check_in_reminder_minutes': '$checkInReminderMinutes',
    'auto_update': '$autoUpdate',
  };

  static AppSettings fromEntries(Map<String, String> e) {
    const d = AppSettings();
    T pick<T extends Enum>(List<T> values, String? name, T fallback) =>
        values.firstWhere((v) => v.name == name, orElse: () => fallback);
    final focus = (e['focus_areas'] ?? '').split(',').where((s) => s.isNotEmpty);
    return AppSettings(
      name: e['name'] ?? d.name,
      onboardingDone: e['onboarding_done'] == 'true',
      focusAreas: {
        for (final id in focus)
          if (QuestCategory.values.any((c) => c.id == id)) QuestCategory.fromId(id),
      },
      theme: pick(ThemePreference.values, e['theme'], d.theme),
      accent: pick(AccentChoice.values, e['accent'], d.accent),
      soundOn: e['sound_on'] == 'true',
      reducedMotion: e['reduced_motion'] == 'true',
      remindersOn: e['reminders_on'] == 'true',
      checkInReminderMinutes: int.tryParse(e['check_in_reminder_minutes'] ?? '') ?? d.checkInReminderMinutes,
      autoUpdate: e['auto_update'] != 'false',
    );
  }
}
