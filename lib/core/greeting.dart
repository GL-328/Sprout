/// A friendly greeting that changes with the time of day.
String greetingFor(DateTime now, String name) {
  final who = name.trim().isEmpty ? '' : ', ${name.trim()}';
  final h = now.hour;
  if (h >= 5 && h < 12) return 'Good morning$who';
  if (h >= 12 && h < 17) return 'Good afternoon$who';
  if (h >= 17 && h < 22) return 'Good evening$who';
  return 'Peaceful night$who';
}
