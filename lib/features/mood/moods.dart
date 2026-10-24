import 'package:flutter/material.dart';

/// The five check-in options, from 1 to 5.
class MoodOption {
  const MoodOption(this.value, this.emoji, this.label, this.color);

  final int value;
  final String emoji;
  final String label;
  final Color color;
}

const moodOptions = [
  MoodOption(1, '😣', 'Rough', Color(0xFFB9C6E4)),
  MoodOption(2, '😔', 'Low', Color(0xFFC9D6EA)),
  MoodOption(3, '😐', 'Okay', Color(0xFFE6E1C8)),
  MoodOption(4, '🙂', 'Good', Color(0xFFCDEBC6)),
  MoodOption(5, '😄', 'Great', Color(0xFFFFE2A8)),
];

MoodOption moodOption(int value) => moodOptions[(value - 1).clamp(0, 4)];

/// A kind reply to each mood.
String moodReply(int value) => switch (value) {
  1 => "Thank you for telling me. It's okay to have hard days. Be extra gentle with yourself today 💙",
  2 => 'Noted, with care. Even one tiny quest is plenty today.',
  3 => 'Okay is a perfectly fine place to be.',
  4 => "Lovely, glad today's feeling good.",
  _ => 'Wonderful! Your garden is glowing with you ☀️',
};
