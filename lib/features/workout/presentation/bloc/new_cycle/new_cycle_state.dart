import 'package:equatable/equatable.dart';
import '../../../domain/entities/cycle_entity.dart';

abstract class NewCycleState extends Equatable {
  const NewCycleState();
  @override
  List<Object?> get props => [];
}

class NewCycleLoading extends NewCycleState {
  const NewCycleLoading();
}

class NewCycleReady extends NewCycleState {
  final CycleEntity completedCycle;
  final int totalWorkouts;
  final Map<int, double> lastCycleWeights;
  final bool? keepWeights;
  final Map<int, double> editedWeights;

  const NewCycleReady({
    required this.completedCycle,
    required this.totalWorkouts,
    required this.lastCycleWeights,
    this.keepWeights,
    this.editedWeights = const {},
  });

  NewCycleReady copyWith({
    bool? keepWeights,
    Map<int, double>? editedWeights,
  }) {
    return NewCycleReady(
      completedCycle: completedCycle,
      totalWorkouts: totalWorkouts,
      lastCycleWeights: lastCycleWeights,
      keepWeights: keepWeights ?? this.keepWeights,
      editedWeights: editedWeights ?? this.editedWeights,
    );
  }

  @override
  List<Object?> get props =>
      [completedCycle, totalWorkouts, lastCycleWeights, keepWeights, editedWeights];
}

class NewCycleCreating extends NewCycleState {
  const NewCycleCreating();
}

class NewCycleCreated extends NewCycleState {
  const NewCycleCreated();
}

class NewCycleError extends NewCycleState {
  final String message;
  const NewCycleError(this.message);
  @override
  List<Object?> get props => [message];
}
