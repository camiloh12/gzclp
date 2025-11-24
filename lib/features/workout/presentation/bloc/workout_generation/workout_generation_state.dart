import 'package:equatable/equatable.dart';
import '../../../domain/entities/workout_plan_entity.dart';

abstract class WorkoutGenerationState extends Equatable {
  const WorkoutGenerationState();

  @override
  List<Object?> get props => [];
}

class WorkoutGenerationInitial extends WorkoutGenerationState {
  const WorkoutGenerationInitial();
}

class WorkoutGenerationLoading extends WorkoutGenerationState {
  const WorkoutGenerationLoading();
}

class WorkoutGenerationLoaded extends WorkoutGenerationState {
  final WorkoutPlanEntity plan;
  final bool isMetric;

  const WorkoutGenerationLoaded({
    required this.plan,
    required this.isMetric,
  });

  @override
  List<Object?> get props => [plan, isMetric];
}

class WorkoutGenerationError extends WorkoutGenerationState {
  final String message;

  const WorkoutGenerationError(this.message);

  @override
  List<Object?> get props => [message];
}
