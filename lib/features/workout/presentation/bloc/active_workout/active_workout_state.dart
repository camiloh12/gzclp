import 'package:equatable/equatable.dart';
import '../../../domain/entities/workout_session_entity.dart';
import '../../../domain/entities/workout_set_entity.dart';

abstract class ActiveWorkoutState extends Equatable {
  const ActiveWorkoutState();

  @override
  List<Object?> get props => [];
}

class ActiveWorkoutInitial extends ActiveWorkoutState {
  const ActiveWorkoutInitial();
}

class ActiveWorkoutLoading extends ActiveWorkoutState {
  const ActiveWorkoutLoading();
}

class ActiveWorkoutLoaded extends ActiveWorkoutState {
  final WorkoutSessionEntity session;
  final List<WorkoutSetEntity> sets;
  final bool isMetric;

  const ActiveWorkoutLoaded({
    required this.session,
    required this.sets,
    required this.isMetric,
  });

  bool get allSetsCompleted {
    return sets.every((set) => set.actualReps != null && set.actualWeight != null);
  }

  int get completedSetsCount {
    return sets.where((set) => set.actualReps != null && set.actualWeight != null).length;
  }

  double get progressPercentage {
    if (sets.isEmpty) return 0.0;
    return completedSetsCount / sets.length;
  }

  ActiveWorkoutLoaded copyWith({
    WorkoutSessionEntity? session,
    List<WorkoutSetEntity>? sets,
    bool? isMetric,
  }) {
    return ActiveWorkoutLoaded(
      session: session ?? this.session,
      sets: sets ?? this.sets,
      isMetric: isMetric ?? this.isMetric,
    );
  }

  @override
  List<Object?> get props => [session, sets, isMetric];
}

class ActiveWorkoutCompleting extends ActiveWorkoutState {
  const ActiveWorkoutCompleting();
}

class ActiveWorkoutCompleted extends ActiveWorkoutState {
  final WorkoutSessionEntity session;

  const ActiveWorkoutCompleted(this.session);

  @override
  List<Object?> get props => [session];
}

class ActiveWorkoutCancelled extends ActiveWorkoutState {
  const ActiveWorkoutCancelled();
}

class ActiveWorkoutError extends ActiveWorkoutState {
  final String message;

  const ActiveWorkoutError(this.message);

  @override
  List<Object?> get props => [message];
}
