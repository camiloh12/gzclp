/// Lift type IDs for the main compound lifts
class LiftType {
  LiftType._();

  static const int squat = 1;
  static const int benchPress = 2;
  static const int deadlift = 3;
  static const int overheadPress = 4;
}

/// Application-wide constants
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // App Metadata
  static const String appName = 'GZCLP Tracker';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'gzclp_tracker.db';
  static const int databaseVersion = 1;

  // Workout Program Constants
  static const List<String> workoutDays = ['A', 'B', 'C', 'D'];
  static const List<String> tiers = ['T1', 'T2', 'T3'];
  static const List<int> stages = [1, 2, 3];

  // Minimum rest between workouts (hours)
  static const int defaultMinimumRestHours = 24;
  static const int absoluteMinimumRestHours = 18;

  // Unit Systems
  static const String unitSystemImperial = 'imperial';
  static const String unitSystemMetric = 'metric';

  // Main Lifts
  static const List<String> mainLifts = [
    'Squat',
    'Bench Press',
    'Deadlift',
    'Overhead Press',
  ];

  // Individual Lift Names
  static const String liftSquat = 'Squat';
  static const String liftBench = 'Bench Press';
  static const String liftDeadlift = 'Deadlift';
  static const String liftOhp = 'Overhead Press';

  // Lift Categories
  static const String liftCategoryLower = 'lower';
  static const String liftCategoryUpper = 'upper';

  // Nested grouping for T1
  static const t1 = _T1();
  static const T1 = _T1(); // Alias for backward compatibility with my recent changes

  // Nested grouping for T2
  static const t2 = _T2();
  static const T2 = _T2();

  // Nested grouping for T3
  static const t3 = _T3();
  static const T3 = _T3();

  // Nested grouping for Increments
  static const increments = _Increments();
  static const Increments = _Increments();
}

class _T1 {
  const _T1();
  final int restSeconds = 240; // 4 minutes
  final double resetPercentage = 0.85; // 85% of 5RM
  
  final Map<int, Map<String, int>> stageConfig = const {
    1: {'sets': 5, 'reps': 3},   // 5x3+
    2: {'sets': 6, 'reps': 2},   // 6x2+
    3: {'sets': 10, 'reps': 1},  // 10x1+
  };
}

class _T2 {
  const _T2();
  final int restSeconds = 120; // 2 minutes
  final double resetIncrementLbs = 10.0; // Reset weight increment (lbs) - conservative
  final double resetIncrementKg = 5.0;   // Reset weight increment (kg) - conservative
  
  final Map<int, Map<String, int>> stageConfig = const {
    1: {'sets': 3, 'reps': 10},  // 3x10
    2: {'sets': 3, 'reps': 8},   // 3x8
    3: {'sets': 3, 'reps': 6},   // 3x6
  };
}

class _T3 {
  const _T3();
  final int restSeconds = 90; // 60-90 seconds
  final int amrapThreshold = 25; // Reps needed to increase weight
  final double incrementLbs = 10.0;
  final double incrementKg = 5.0;
  
  final Map<String, int> stageConfig = const {
    'sets': 3, 
    'reps': 15, // 3x15+
  };
}

class _Increments {
  const _Increments();
  final double lowerBodyLbs = 10.0;
  final double upperBodyLbs = 5.0;
  final double lowerBodyKg = 5.0;
  final double upperBodyKg = 2.5;
}
