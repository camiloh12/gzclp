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
      expect(AppConstants.T1.stageConfig[1]?['sets'], equals(5));
      expect(AppConstants.T1.stageConfig[1]?['reps'], equals(3));
      expect(AppConstants.T1.stageConfig[2]?['sets'], equals(6));
      expect(AppConstants.T1.stageConfig[2]?['reps'], equals(2));
      expect(AppConstants.T1.stageConfig[3]?['sets'], equals(10));
      expect(AppConstants.T1.stageConfig[3]?['reps'], equals(1));
    });

    test('should have correct T2 stage configuration', () {
      expect(AppConstants.T2.stageConfig[1]?['sets'], equals(3));
      expect(AppConstants.T2.stageConfig[1]?['reps'], equals(10));
      expect(AppConstants.T2.stageConfig[2]?['sets'], equals(3));
      expect(AppConstants.T2.stageConfig[2]?['reps'], equals(8));
      expect(AppConstants.T2.stageConfig[3]?['sets'], equals(3));
      expect(AppConstants.T2.stageConfig[3]?['reps'], equals(6));
    });

    test('should have correct T3 stage configuration', () {
      expect(AppConstants.T3.stageConfig['sets'], equals(3));
      expect(AppConstants.T3.stageConfig['reps'], equals(15));
    });

    test('should have correct lift names', () {
      expect(AppConstants.liftSquat, equals('Squat'));
      expect(AppConstants.liftBench, equals('Bench Press'));
      expect(AppConstants.liftDeadlift, equals('Deadlift'));
      expect(AppConstants.liftOhp, equals('Overhead Press'));
    });

    test('should have correct progression values', () {
      expect(AppConstants.T1.resetPercentage, equals(0.85));
      expect(AppConstants.T3.amrapThreshold, equals(25));
    });
  });
}
