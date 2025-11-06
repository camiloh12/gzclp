import 'package:equatable/equatable.dart';

import '../../../domain/entities/workout_session_entity.dart';
import '../../../domain/entities/workout_set_entity.dart';
import '../../../domain/usecases/generate_workout_for_day.dart';

/// States for workout session management
abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WorkoutInitial extends WorkoutState {
  const WorkoutInitial();
}

/// Loading state
class WorkoutLoading extends WorkoutState {
  const WorkoutLoading();
}

/// No workout in progress - ready to start
class WorkoutReady extends WorkoutState {
  final WorkoutSessionEntity? lastSession;

  const WorkoutReady({this.lastSession});

  @override
  List<Object?> get props => [lastSession];
}

/// Workout plan generated, ready to start
class WorkoutPlanGenerated extends WorkoutState {
  final WorkoutPlan plan;
  final bool isMetric;

  const WorkoutPlanGenerated({
    required this.plan,
    required this.isMetric,
  });

  @override
  List<Object?> get props => [plan, isMetric];
}

/// Workout in progress
class WorkoutInProgress extends WorkoutState {
  final WorkoutSessionEntity session;
  final WorkoutPlan plan;
  final List<WorkoutSetEntity> sets;
  final bool isMetric;

  const WorkoutInProgress({
    required this.session,
    required this.plan,
    required this.sets,
    required this.isMetric,
  });

  /// Get sets for a specific tier
  List<WorkoutSetEntity> getSetsForTier(String tier) {
    return sets.where((set) => set.tier == tier).toList();
  }

  /// Get completed sets count
  int get completedSetsCount {
    return sets.where((set) => set.isCompleted).length;
  }

  /// Check if all sets are completed
  bool get allSetsCompleted {
    return sets.every((set) => set.isCompleted);
  }

  /// Get progress percentage
  double get progressPercentage {
    if (sets.isEmpty) return 0.0;
    return completedSetsCount / sets.length;
  }

  WorkoutInProgress copyWith({
    WorkoutSessionEntity? session,
    WorkoutPlan? plan,
    List<WorkoutSetEntity>? sets,
    bool? isMetric,
  }) {
    return WorkoutInProgress(
      session: session ?? this.session,
      plan: plan ?? this.plan,
      sets: sets ?? this.sets,
      isMetric: isMetric ?? this.isMetric,
    );
  }

  @override
  List<Object?> get props => [session, plan, sets, isMetric];
}

/// Completing workout (finalizing)
class WorkoutCompleting extends WorkoutState {
  const WorkoutCompleting();
}

/// Workout completed successfully
class WorkoutCompleted extends WorkoutState {
  final WorkoutSessionEntity session;

  const WorkoutCompleted(this.session);

  @override
  List<Object?> get props => [session];
}

/// Workout history loaded
class WorkoutHistoryLoaded extends WorkoutState {
  final List<WorkoutSessionEntity> sessions;

  const WorkoutHistoryLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

/// Error state
class WorkoutError extends WorkoutState {
  final String message;

  const WorkoutError(this.message);

  @override
  List<Object?> get props => [message];
}
