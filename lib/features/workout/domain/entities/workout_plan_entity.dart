import '../entities/accessory_exercise_entity.dart';
import '../entities/lift_entity.dart';

/// Represents a complete workout plan for a day
class WorkoutPlanEntity {
  final String dayType;
  final LiftPlan t1Exercise;
  final LiftPlan t2Exercise;
  final List<T3Plan> t3Exercises;

  const WorkoutPlanEntity({
    required this.dayType,
    required this.t1Exercise,
    required this.t2Exercise,
    this.t3Exercises = const [],
  });
}

/// Represents the plan for a single lift in a workout
class LiftPlan {
  final LiftEntity lift;
  final String tier;
  final int stage;
  final double targetWeight;
  final int sets;
  final int reps;

  const LiftPlan({
    required this.lift,
    required this.tier,
    required this.stage,
    required this.targetWeight,
    required this.sets,
    required this.reps,
  });

  /// Get description of the set/rep scheme (e.g., "5x3+", "3x10")
  String get setRepScheme {
    if (tier == 'T1' || tier == 'T2') {
      return '${sets}x$reps'; // e.g., "5x3", "3x10"
    } else {
      return '${sets}x$reps+'; // T3 always has + for AMRAP
    }
  }
}

/// Represents the plan for a T3 accessory exercise
class T3Plan {
  final AccessoryExerciseEntity exercise;
  final double targetWeight;
  final int sets;
  final int reps;

  const T3Plan({
    required this.exercise,
    required this.targetWeight,
    required this.sets,
    required this.reps,
  });

  /// Get description of the set/rep scheme (always includes + for AMRAP)
  String get setRepScheme => '${sets}x$reps+';
}
