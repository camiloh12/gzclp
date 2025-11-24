import 'package:equatable/equatable.dart';

abstract class WorkoutGenerationEvent extends Equatable {
  const WorkoutGenerationEvent();

  @override
  List<Object?> get props => [];
}

class GenerateWorkout extends WorkoutGenerationEvent {
  final String dayType;

  const GenerateWorkout({required this.dayType});

  @override
  List<Object?> get props => [dayType];
}
