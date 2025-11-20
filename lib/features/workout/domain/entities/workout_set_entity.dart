import 'package:equatable/equatable.dart';

/// Domain entity representing an individual set within a workout session
///
/// Records both programmed (target) and actual (performed) values.
/// AMRAP sets are critical for progression decisions.
class WorkoutSetEntity extends Equatable {
  /// Unique identifier
  final int id;

  /// ID of the session this set belongs to
  final int sessionId;

  /// ID of the lift being performed
  final int liftId;

  /// Tier for this set: 'T1', 'T2', or 'T3'
  final String tier;

  /// Set number within this lift (1, 2, 3, etc.)
  final int setNumber;

  /// Target (programmed) reps for this set
  final int targetReps;

  /// Actual reps performed (null if not yet logged)
  final int? actualReps;

  /// Target (programmed) weight for this set
  final double targetWeight;

  /// Actual weight used (null if not yet logged)
  /// Allows for user adjustments if bar was heavier/lighter than expected
  final double? actualWeight;

  /// Is this an AMRAP (As Many Reps As Possible) set?
  /// AMRAP sets are crucial for progression decisions
  final bool isAmrap;

  /// Optional notes about this specific set
  final String? setNotes;

  /// Exercise name (used for T3 accessory exercises)
  /// For T1/T2, this is null and liftId is used to determine name
  final String? exerciseName;

  const WorkoutSetEntity({
    required this.id,
    required this.sessionId,
    required this.liftId,
    required this.tier,
    required this.setNumber,
    required this.targetReps,
    this.actualReps,
    required this.targetWeight,
    this.actualWeight,
    this.isAmrap = false,
    this.setNotes,
    this.exerciseName,
  });

  /// Check if this set has been completed (actualReps logged)
  bool get isCompleted => actualReps != null;

  /// Check if the set was successful (met or exceeded target reps)
  bool get isSuccessful {
    if (!isCompleted) return false;
    return actualReps! >= targetReps;
  }

  /// Check if the set was failed (did not meet target reps)
  bool get isFailed {
    if (!isCompleted) return false;
    return actualReps! < targetReps;
  }

  /// Get the weight actually used (defaults to target if not specified)
  double get effectiveWeight => actualWeight ?? targetWeight;

  /// Get the reps actually performed (null if not completed)
  int? get effectiveReps => actualReps;

  /// Calculate rep difference from target (positive = exceeded, negative = fell short)
  int? get repDifference {
    if (!isCompleted) return null;
    return actualReps! - targetReps;
  }

  /// Create a copy with updated fields
  WorkoutSetEntity copyWith({
    int? id,
    int? sessionId,
    int? liftId,
    String? tier,
    int? setNumber,
    int? targetReps,
    int? actualReps,
    double? targetWeight,
    double? actualWeight,
    bool? isAmrap,
    String? setNotes,
    String? exerciseName,
  }) {
    return WorkoutSetEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      liftId: liftId ?? this.liftId,
      tier: tier ?? this.tier,
      setNumber: setNumber ?? this.setNumber,
      targetReps: targetReps ?? this.targetReps,
      actualReps: actualReps ?? this.actualReps,
      targetWeight: targetWeight ?? this.targetWeight,
      actualWeight: actualWeight ?? this.actualWeight,
      isAmrap: isAmrap ?? this.isAmrap,
      setNotes: setNotes ?? this.setNotes,
      exerciseName: exerciseName ?? this.exerciseName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        liftId,
        tier,
        setNumber,
        targetReps,
        actualReps,
        targetWeight,
        actualWeight,
        isAmrap,
        setNotes,
        exerciseName,
      ];

  @override
  String toString() {
    return 'WorkoutSetEntity(id: $id, lift: $liftId, tier: $tier, '
        'set: $setNumber, target: ${targetReps}x$targetWeight, '
        'actual: ${actualReps ?? "?"}x${actualWeight ?? targetWeight}, '
        'amrap: $isAmrap)';
  }
}
