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
    this.musicOn = false,
    this.reducedMotion = false,
    this.remindersOn = false,
    this.checkInReminderMinutes = 9 * 60,
    this.notifyQuests = false,
    this.notifyFruit = false,
    this.notifyGrown = false,
    this.autoUpdate = true,
  });

  final String name;
  final bool onboardingDone;
  final Set<QuestCategory> focusAreas;
  final ThemePreference theme;
  final AccentChoice accent;
  final bool soundOn;

  /// Gentle music on Home that changes with the plot.
  final bool musicOn;
  final bool reducedMotion;

  /// The daily check-in reminder. Off unless the user turns it on.
  final bool remindersOn;

  /// Time of the daily check-in reminder, in minutes after midnight.
  final int checkInReminderMinutes;

  /// Reminders for the quests the user gave a reminder time.
  final bool notifyQuests;

  /// A notification when a plant has fruit ready to pick.
  final bool notifyFruit;

  /// A notification when a plant is fully grown.
  final bool notifyGrown;

  /// Check GitHub for a newer build and install it. On unless turned off.
  final bool autoUpdate;

  AppSettings copyWith({
    String? name,
    bool? onboardingDone,
    Set<QuestCategory>? focusAreas,
    ThemePreference? theme,
    AccentChoice? accent,
    bool? soundOn,
    bool? musicOn,
    bool? reducedMotion,
    bool? remindersOn,
    int? checkInReminderMinutes,
    bool? notifyQuests,
    bool? notifyFruit,
    bool? notifyGrown,
    bool? autoUpdate,
  }) => AppSettings(
    name: name ?? this.name,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    focusAreas: focusAreas ?? this.focusAreas,
    theme: theme ?? this.theme,
    accent: accent ?? this.accent,
    soundOn: soundOn ?? this.soundOn,
    musicOn: musicOn ?? this.musicOn,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    remindersOn: remindersOn ?? this.remindersOn,
    checkInReminderMinutes: checkInReminderMinutes ?? this.checkInReminderMinutes,
    notifyQuests: notifyQuests ?? this.notifyQuests,
    notifyFruit: notifyFruit ?? this.notifyFruit,
    notifyGrown: notifyGrown ?? this.notifyGrown,
    autoUpdate: autoUpdate ?? this.autoUpdate,
  );

  Map<String, String> toEntries() => {
    'name': name,
    'onboarding_done': '$onboardingDone',
    'focus_areas': focusAreas.map((c) => c.id).join(','),
    'theme': theme.name,
    'accent': accent.name,
    'sound_on': '$soundOn',
    'music_on': '$musicOn',
    'reduced_motion': '$reducedMotion',
    'reminders_on': '$remindersOn',
    'check_in_reminder_minutes': '$checkInReminderMinutes',
    'notify_quests': '$notifyQuests',
    'notify_fruit': '$notifyFruit',
    'notify_grown': '$notifyGrown',
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
      musicOn: e['music_on'] == 'true',
      reducedMotion: e['reduced_motion'] == 'true',
      remindersOn: e['reminders_on'] == 'true',
      checkInReminderMinutes: int.tryParse(e['check_in_reminder_minutes'] ?? '') ?? d.checkInReminderMinutes,
      // Quest reminders used to come with the one reminders switch, so they
      // stay on for anyone who had reminders on before this choice existed.
      notifyQuests: (e['notify_quests'] ?? e['reminders_on']) == 'true',
      notifyFruit: e['notify_fruit'] == 'true',
      notifyGrown: e['notify_grown'] == 'true',
      autoUpdate: e['auto_update'] != 'false',
    );
  }
}
