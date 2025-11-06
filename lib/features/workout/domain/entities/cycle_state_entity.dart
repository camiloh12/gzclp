import 'package:equatable/equatable.dart';

/// Domain entity representing the progression state of a lift
///
/// CRITICAL ENTITY - This is the heart of the GZCLP progression algorithm.
/// Tracks the current tier, stage, target weights, and historical anchors
/// needed for reset calculations.
class CycleStateEntity extends Equatable {
  /// Unique identifier
  final int id;

  /// ID of the lift this state belongs to
  final int liftId;

  /// Current tier: 'T1', 'T2', or 'T3'
  final String currentTier;

  /// Current stage within the tier
  /// T1: 1 (5x3+), 2 (6x2+), 3 (10x1+)
  /// T2: 1 (3x10), 2 (3x8), 3 (3x6)
  /// T3: 1 (3x15+) - only one stage
  final int currentStage;

  /// The weight programmed for the next workout of this lift at this tier
  final double nextTargetWeight;

  /// CRITICAL FIELD for T2 resets
  /// Records the weight successfully used during the last T2 Stage 1 (3x10) session
  /// Used to calculate reset weight: lastStage1SuccessWeight + 15-20 lbs / 7.5-10 kg
  final double? lastStage1SuccessWeight;

  /// For T3 progression tracking
  /// Tracks the reps achieved on the last AMRAP set
  /// Weight increases only if this value reaches 25+
  final int currentT3AmrapVolume;

  /// Timestamp of last update
  final DateTime lastUpdated;

  const CycleStateEntity({
    required this.id,
    required this.liftId,
    required this.currentTier,
    required this.currentStage,
    required this.nextTargetWeight,
    this.lastStage1SuccessWeight,
    this.currentT3AmrapVolume = 0,
    required this.lastUpdated,
  });

  /// Check if this is a T1 state
  bool get isT1 => currentTier == 'T1';

  /// Check if this is a T2 state
  bool get isT2 => currentTier == 'T2';

  /// Check if this is a T3 state
  bool get isT3 => currentTier == 'T3';

  /// Check if this is the first stage
  bool get isStage1 => currentStage == 1;

  /// Check if this is the second stage
  bool get isStage2 => currentStage == 2;

  /// Check if this is the third stage
  bool get isStage3 => currentStage == 3;

  /// Check if at the final stage for this tier
  bool get isAtFinalStage {
    if (isT3) return true; // T3 only has one stage
    return currentStage == 3; // T1 and T2 have 3 stages
  }

  /// Get the required rep count for this tier and stage
  /// For AMRAP sets, this is the minimum required (e.g., 3 for 5x3+)
  int getRequiredReps() {
    if (isT1) {
      switch (currentStage) {
        case 1:
          return 3; // 5x3+
        case 2:
          return 2; // 6x2+
        case 3:
          return 1; // 10x1+
        default:
          throw StateError('Invalid T1 stage: $currentStage');
      }
    } else if (isT2) {
      switch (currentStage) {
        case 1:
          return 10; // 3x10
        case 2:
          return 8; // 3x8
        case 3:
          return 6; // 3x6
        default:
          throw StateError('Invalid T2 stage: $currentStage');
      }
    } else if (isT3) {
      return 15; // 3x15+
    }
    throw StateError('Invalid tier: $currentTier');
  }

  /// Get the number of sets for this tier and stage
  int getRequiredSets() {
    if (isT1) {
      switch (currentStage) {
        case 1:
          return 5; // 5x3+
        case 2:
          return 6; // 6x2+
        case 3:
          return 10; // 10x1+
        default:
          throw StateError('Invalid T1 stage: $currentStage');
      }
    } else if (isT2 || isT3) {
      return 3; // Both T2 and T3 use 3 sets
    }
    throw StateError('Invalid tier: $currentTier');
  }

  /// Create a copy with updated fields
  CycleStateEntity copyWith({
    int? id,
    int? liftId,
    String? currentTier,
    int? currentStage,
    double? nextTargetWeight,
    double? lastStage1SuccessWeight,
    int? currentT3AmrapVolume,
    DateTime? lastUpdated,
  }) {
    return CycleStateEntity(
      id: id ?? this.id,
      liftId: liftId ?? this.liftId,
      currentTier: currentTier ?? this.currentTier,
      currentStage: currentStage ?? this.currentStage,
      nextTargetWeight: nextTargetWeight ?? this.nextTargetWeight,
      lastStage1SuccessWeight: lastStage1SuccessWeight ?? this.lastStage1SuccessWeight,
      currentT3AmrapVolume: currentT3AmrapVolume ?? this.currentT3AmrapVolume,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        id,
        liftId,
        currentTier,
        currentStage,
        nextTargetWeight,
        lastStage1SuccessWeight,
        currentT3AmrapVolume,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'CycleStateEntity(id: $id, liftId: $liftId, tier: $currentTier, '
        'stage: $currentStage, nextWeight: $nextTargetWeight, '
        'lastStage1Weight: $lastStage1SuccessWeight, '
        't3Amrap: $currentT3AmrapVolume)';
  }
}
