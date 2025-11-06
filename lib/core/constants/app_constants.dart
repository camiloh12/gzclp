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

  // Default Rest Times (seconds)
  static const int defaultT1RestSeconds = 240;  // 4 minutes
  static const int defaultT2RestSeconds = 150;  // 2.5 minutes
  static const int defaultT3RestSeconds = 75;   // 1.25 minutes

  // Minimum rest between workouts (hours)
  static const int defaultMinimumRestHours = 24;
  static const int absoluteMinimumRestHours = 18;

  // Weight increments (lbs)
  static const double lowerBodyIncrementLbs = 10.0;
  static const double upperBodyIncrementLbs = 5.0;

  // Weight increments (kg)
  static const double lowerBodyIncrementKg = 5.0;
  static const double upperBodyIncrementKg = 2.5;

  // T3 Progression threshold
  static const int t3AmrapThreshold = 25;

  // T3 Weight increments
  static const double t3IncrementLbs = 5.0;
  static const double t3IncrementKg = 2.5;

  // T1 Reset percentage
  static const double t1ResetPercentage = 0.85;  // 85% of 5RM

  // T2 Reset increment (lbs)
  static const double t2ResetIncrementLbs = 17.5;  // 15-20 lbs average

  // T2 Reset increment (kg)
  static const double t2ResetIncrementKg = 8.75;   // 7.5-10 kg average

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

  // Unit Systems
  static const String unitSystemImperial = 'imperial';
  static const String unitSystemMetric = 'metric';

  // Stage Configurations
  // T1
  static const Map<int, Map<String, int>> t1StageConfig = {
    1: {'sets': 5, 'reps': 3},   // 5x3+
    2: {'sets': 6, 'reps': 2},   // 6x2+
    3: {'sets': 10, 'reps': 1},  // 10x1+
  };

  // T2
  static const Map<int, Map<String, int>> t2StageConfig = {
    1: {'sets': 3, 'reps': 10},  // 3x10
    2: {'sets': 3, 'reps': 8},   // 3x8
    3: {'sets': 3, 'reps': 6},   // 3x6
  };

  // T3
  static const Map<String, int> t3StageConfig = {
    'sets': 3,
    'reps': 15,  // 3x15+
  };
}
