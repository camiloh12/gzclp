/// Pre-populated T3 accessory exercise suggestions for the GZCLP program
///
/// These are recommended accessory exercises organized by workout day.
/// Users can choose from these or create custom exercises.
class T3ExerciseSuggestions {
  /// Suggested T3 exercises for Day 1 (Squat focus)
  static const List<String> day1 = [
    'Leg Press',
    'Leg Curls',
    'Leg Extensions',
    'Romanian Deadlift',
    'Bulgarian Split Squat',
    'Goblet Squat',
    'Lunges',
    'Calf Raises',
    'Hack Squat',
    'Front Squat',
  ];

  /// Suggested T3 exercises for Day 2 (Bench Press focus)
  static const List<String> day2 = [
    'Dumbbell Flyes',
    'Cable Crossover',
    'Incline Dumbbell Press',
    'Tricep Pushdown',
    'Tricep Dips',
    'Skull Crushers',
    'Close-Grip Bench Press',
    'Pec Deck',
    'Machine Press',
    'Push-Ups',
  ];

  /// Suggested T3 exercises for Day 3 (Bench Press focus)
  static const List<String> day3 = [
    'Dumbbell Row',
    'Lat Pulldown',
    'Seated Cable Row',
    'Face Pulls',
    'Bicep Curls',
    'Hammer Curls',
    'Chest-Supported Row',
    'T-Bar Row',
    'Chin-Ups',
    'Cable Curl',
  ];

  /// Suggested T3 exercises for Day 4 (Deadlift focus)
  static const List<String> day4 = [
    'Barbell Row',
    'Lat Pulldown',
    'Cable Row',
    'Dumbbell Row',
    'Pull-Ups',
    'Chin-Ups',
    'Face Pulls',
    'Shrugs',
    'Good Mornings',
    'Back Extensions',
  ];

  /// Get suggestions for a specific day
  static List<String> forDay(String dayType) {
    switch (dayType) {
      case '1':
        return day1;
      case '2':
        return day2;
      case '3':
        return day3;
      case '4':
        return day4;
      default:
        return [];
    }
  }

  /// All suggested exercises across all days
  static List<String> get all => [
        ...day1,
        ...day2,
        ...day3,
        ...day4,
      ];

  /// Default T3 exercise selection (one per day)
  /// These can be auto-selected if user wants quick setup
  static Map<String, String> get defaults => {
        '1': 'Leg Press',
        '2': 'Dumbbell Flyes',
        '3': 'Lat Pulldown',
        '4': 'Barbell Row',
      };

  /// Get default exercises as a list with day types
  static List<Map<String, String>> getDefaultsAsList() {
    return defaults.entries
        .map((entry) => {
              'dayType': entry.key,
              'name': entry.value,
            })
        .toList();
  }
}
