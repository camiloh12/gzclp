import '../constants/app_constants.dart';

/// Helper class for mapping lift IDs to display names
class LiftNameHelper {
  LiftNameHelper._();

  /// Get the display name for a lift ID
  static String getLiftName(int liftId) {
    switch (liftId) {
      case LiftType.squat:
        return AppConstants.liftSquat;
      case LiftType.benchPress:
        return AppConstants.liftBench;
      case LiftType.deadlift:
        return AppConstants.liftDeadlift;
      case LiftType.overheadPress:
        return AppConstants.liftOhp;
      default:
        return 'Unknown Lift';
    }
  }

  /// Get the short name for a lift ID
  static String getLiftShortName(int liftId) {
    switch (liftId) {
      case LiftType.squat:
        return 'Squat';
      case LiftType.benchPress:
        return 'Bench';
      case LiftType.deadlift:
        return 'Deadlift';
      case LiftType.overheadPress:
        return 'OHP';
      default:
        return '?';
    }
  }

  /// Get the lift category (lower/upper)
  static String getLiftCategory(int liftId) {
    switch (liftId) {
      case LiftType.squat:
      case LiftType.deadlift:
        return AppConstants.liftCategoryLower;
      case LiftType.benchPress:
      case LiftType.overheadPress:
        return AppConstants.liftCategoryUpper;
      default:
        return '';
    }
  }
}
