import 'package:flutter_test/flutter_test.dart';
import 'package:gzclp_tracker/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('should have correct workout days', () {
      expect(AppConstants.workoutDays, equals(['A', 'B', 'C', 'D']));
    });

    test('should have correct tiers', () {
      expect(AppConstants.tiers, equals(['T1', 'T2', 'T3']));
    });

    test('should have correct T1 stage configurations', () {
      expect(AppConstants.t1StageConfig[1]?['sets'], equals(5));
      expect(AppConstants.t1StageConfig[1]?['reps'], equals(3));
      expect(AppConstants.t1StageConfig[2]?['sets'], equals(6));
      expect(AppConstants.t1StageConfig[2]?['reps'], equals(2));
      expect(AppConstants.t1StageConfig[3]?['sets'], equals(10));
      expect(AppConstants.t1StageConfig[3]?['reps'], equals(1));
    });

    test('should have correct T2 stage configurations', () {
      expect(AppConstants.t2StageConfig[1]?['sets'], equals(3));
      expect(AppConstants.t2StageConfig[1]?['reps'], equals(10));
      expect(AppConstants.t2StageConfig[2]?['sets'], equals(3));
      expect(AppConstants.t2StageConfig[2]?['reps'], equals(8));
      expect(AppConstants.t2StageConfig[3]?['sets'], equals(3));
      expect(AppConstants.t2StageConfig[3]?['reps'], equals(6));
    });

    test('should have correct T3 configuration', () {
      expect(AppConstants.t3StageConfig['sets'], equals(3));
      expect(AppConstants.t3StageConfig['reps'], equals(15));
    });

    test('should have correct main lifts', () {
      expect(
        AppConstants.mainLifts,
        equals([
          'Squat',
          'Bench Press',
          'Deadlift',
          'Overhead Press',
        ]),
      );
    });

    test('should have correct T1 reset percentage', () {
      expect(AppConstants.t1ResetPercentage, equals(0.85));
    });

    test('should have correct T3 AMRAP threshold', () {
      expect(AppConstants.t3AmrapThreshold, equals(25));
    });
  });
}
