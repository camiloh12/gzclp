/// Pre-populated T3 accessory exercise suggestions for the GZCLP program
///
/// These are recommended accessory exercises organized by workout day.
/// Users can choose from these or create custom exercises.
class T3ExerciseSuggestions {
  /// Suggested T3 exercises for Day A (Squat focus)
  static const List<String> dayA = [
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

  /// Suggested T3 exercises for Day B (Bench Press focus)
  static const List<String> dayB = [
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

  /// Suggested T3 exercises for Day C (Bench Press focus)
  static const List<String> dayC = [
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

  /// Suggested T3 exercises for Day D (Deadlift focus)
  static const List<String> dayD = [
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
    switch (dayType.toUpperCase()) {
      case 'A':
        return dayA;
      case 'B':
        return dayB;
      case 'C':
        return dayC;
      case 'D':
        return dayD;
      default:
        return [];
    }
  }

  /// All suggested exercises across all days
  static List<String> get all => [
        ...dayA,
        ...dayB,
        ...dayC,
        ...dayD,
      ];

  /// Default T3 exercise selection (one per day)
  /// These can be auto-selected if user wants quick setup
  static Map<String, String> get defaults => {
        'A': 'Leg Press',
        'B': 'Dumbbell Flyes',
        'C': 'Lat Pulldown',
        'D': 'Barbell Row',
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
