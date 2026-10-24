import '../../domain/models/enums.dart';

class PremadeQuest {
  const PremadeQuest(this.key, this.title, this.description, this.category, this.difficulty);

  /// Stable id. Never change it, or users' added quests lose their link.
  final String key;
  final String title;
  final String description;
  final QuestCategory category;
  final Difficulty difficulty;
}

const _s = Difficulty.small;
const _m = Difficulty.medium;
const _b = Difficulty.big;

const premadeQuests = <PremadeQuest>[
  // Sleep
  PremadeQuest(
    'sleep_screens_off',
    'Screens off before bed',
    'Put the phone down 30 minutes before sleep.',
    QuestCategory.sleep,
    _m,
  ),
  PremadeQuest(
    'sleep_same_time',
    'Head to bed on time',
    'Aim for your usual bedtime tonight.',
    QuestCategory.sleep,
    _m,
  ),
  PremadeQuest('sleep_wind_down', 'Wind-down moment', 'Dim the lights and do something calm.', QuestCategory.sleep, _s),
  PremadeQuest('sleep_nap', 'Rest your eyes', 'Lie down for a short rest, even 10 minutes.', QuestCategory.sleep, _s),
  PremadeQuest(
    'sleep_full_night',
    'A full night of sleep',
    'Give yourself 7 or more hours tonight.',
    QuestCategory.sleep,
    _b,
  ),
  PremadeQuest('sleep_bed_made', 'Fresh pillow', 'Fluff your pillow or change the sheets.', QuestCategory.sleep, _s),

  // Movement
  PremadeQuest(
    'move_outside',
    'Step outside for 5 minutes',
    'Fresh air counts, even on the doorstep.',
    QuestCategory.movement,
    _s,
  ),
  PremadeQuest(
    'move_stretch',
    'Have a big stretch',
    'Reach up high and roll your shoulders.',
    QuestCategory.movement,
    _s,
  ),
  PremadeQuest('move_walk', 'Go for a walk', 'Any distance, any speed.', QuestCategory.movement, _m),
  PremadeQuest(
    'move_dance',
    'Dance to one song',
    'Pick a favourite and move however you like.',
    QuestCategory.movement,
    _s,
  ),
  PremadeQuest(
    'move_workout',
    'A proper workout',
    'A run, a class, a swim, whatever feels good.',
    QuestCategory.movement,
    _b,
  ),
  PremadeQuest('move_stairs', 'Take the stairs', 'Or any little extra bit of movement.', QuestCategory.movement, _s),

  // Mind
  PremadeQuest(
    'mind_breathe',
    'Three slow breaths',
    'In through the nose, out through the mouth.',
    QuestCategory.mind,
    _s,
  ),
  PremadeQuest('mind_gratitude', 'One good thing', 'Notice something that went okay today.', QuestCategory.mind, _s),
  PremadeQuest('mind_journal', 'Write a few lines', 'Jot down how today is going.', QuestCategory.mind, _m),
  PremadeQuest(
    'mind_meditate',
    'Sit quietly for 10 minutes',
    'A meditation, or simply being still.',
    QuestCategory.mind,
    _m,
  ),
  PremadeQuest('mind_hobby', 'Time for a hobby', 'Read, draw, play, make something you enjoy.', QuestCategory.mind, _b),
  PremadeQuest(
    'mind_kind_words',
    'Be kind to yourself',
    'Say one kind thing to yourself, out loud or in your head.',
    QuestCategory.mind,
    _s,
  ),

  // Social
  PremadeQuest('social_text', 'Text someone you like', 'A quick hello is plenty.', QuestCategory.social, _s),
  PremadeQuest(
    'social_call',
    'Call a friend or family member',
    'Even a five-minute catch-up.',
    QuestCategory.social,
    _m,
  ),
  PremadeQuest('social_compliment', 'Give a compliment', 'Tell someone something nice.', QuestCategory.social, _s),
  PremadeQuest('social_meet', 'See someone in person', 'Coffee, a walk, a visit.', QuestCategory.social, _b),
  PremadeQuest('social_thanks', 'Say thank you', 'Thank someone for something small or big.', QuestCategory.social, _s),

  // Home
  PremadeQuest(
    'home_tidy',
    'Tidy one small spot',
    'A shelf, a desk corner, the bedside table.',
    QuestCategory.home,
    _s,
  ),
  PremadeQuest('home_dishes', 'Do the dishes', 'Future you will be grateful.', QuestCategory.home, _m),
  PremadeQuest('home_laundry', 'A load of laundry', 'Wash, dry, or put away. Any step counts.', QuestCategory.home, _m),
  PremadeQuest('home_window', 'Open a window', 'Let some fresh air in.', QuestCategory.home, _s),
  PremadeQuest('home_plant', 'Water a houseplant', 'Or say hello to one.', QuestCategory.home, _s),
  PremadeQuest('home_deep_clean', 'Clean a whole room', 'Pick one room and give it some love.', QuestCategory.home, _b),

  // Food and water
  PremadeQuest('food_water', 'Drink a glass of water', 'Small sips count too.', QuestCategory.foodWater, _s),
  PremadeQuest(
    'food_breakfast',
    'Eat something in the morning',
    'Anything at all is a good start.',
    QuestCategory.foodWater,
    _s,
  ),
  PremadeQuest('food_fruit', 'Have some fruit or veg', 'A handful is great.', QuestCategory.foodWater, _s),
  PremadeQuest('food_cook', 'Cook a meal', 'Something simple and warm.', QuestCategory.foodWater, _m),
  PremadeQuest('food_bottle', 'Fill your water bottle', 'Keep it nearby for later.', QuestCategory.foodWater, _s),
  PremadeQuest(
    'food_meal_prep',
    'Prepare food for tomorrow',
    'Make lunch ahead, or plan a meal.',
    QuestCategory.foodWater,
    _b,
  ),

  // Study/Work
  PremadeQuest(
    'work_one_task',
    'Do one small task',
    'The tiniest step on something you need to do.',
    QuestCategory.studyWork,
    _s,
  ),
  PremadeQuest('work_focus', 'Focus for 25 minutes', 'One focus session, then a break.', QuestCategory.studyWork, _m),
  PremadeQuest('work_break', 'Take a real break', 'Step away from the screen for a bit.', QuestCategory.studyWork, _s),
  PremadeQuest(
    'work_plan',
    'Plan tomorrow',
    'Write down two or three things for tomorrow.',
    QuestCategory.studyWork,
    _s,
  ),
  PremadeQuest(
    'work_big',
    'Finish something big',
    'A chapter, an assignment, a project step.',
    QuestCategory.studyWork,
    _b,
  ),
  PremadeQuest('work_inbox', 'Clear a few messages', 'Reply to or archive a handful.', QuestCategory.studyWork, _m),
];

/// Quests suggested when the user picks a focus area in onboarding.
const starterKeysByCategory = <QuestCategory, List<String>>{
  QuestCategory.sleep: ['sleep_wind_down', 'sleep_screens_off'],
  QuestCategory.movement: ['move_outside', 'move_stretch'],
  QuestCategory.mind: ['mind_breathe', 'mind_gratitude'],
  QuestCategory.social: ['social_text'],
  QuestCategory.home: ['home_tidy', 'home_window'],
  QuestCategory.foodWater: ['food_water', 'food_fruit'],
  QuestCategory.studyWork: ['work_one_task', 'work_break'],
};

/// Used when no focus areas were picked.
const defaultStarterKeys = ['food_water', 'move_outside', 'mind_breathe', 'social_text'];

PremadeQuest? premadeByKey(String key) {
  for (final q in premadeQuests) {
    if (q.key == key) return q;
  }
  return null;
}
