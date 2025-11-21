import 'dart:convert';

import '../../../../core/di/injection_container.dart';
import '../../data/datasources/local/app_database.dart';

/// Exports all workout data to JSON format
class ExportDatabase {
  final AppDatabase _database = sl<AppDatabase>();

  /// Export all data as JSON string
  Future<String> call() async {
    final lifts = await _database.liftsDao.getAllLifts();
    final cycleStates = await _database.cycleStatesDao.getAllCycleStates();
    final sessions = await _database.workoutSessionsDao.getFinalizedSessions();
    final preferences = await _database.userPreferencesDao.getPreferences();
    final accessories = await _database.accessoryExercisesDao.getAllAccessories();

    // Get all sets for finalized sessions
    final List<Map<String, dynamic>> allSets = [];
    for (final session in sessions) {
      final sets = await _database.workoutSetsDao.getSetsForSession(session.id);
      allSets.addAll(sets.map((s) => {
            'id': s.id,
            'sessionId': s.sessionId,
            'liftId': s.liftId,
            'tier': s.tier,
            'setNumber': s.setNumber,
            'targetReps': s.targetReps,
            'targetWeight': s.targetWeight,
            'actualReps': s.actualReps,
            'actualWeight': s.actualWeight,
            'isAmrap': s.isAmrap,
            'setNotes': s.setNotes,
            'exerciseName': s.exerciseName,
          }));
    }

    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'lifts': lifts
          .map((l) => {
                'id': l.id,
                'name': l.name,
                'category': l.category,
              })
          .toList(),
      'cycleStates': cycleStates
          .map((cs) => {
                'id': cs.id,
                'liftId': cs.liftId,
                'currentTier': cs.currentTier,
                'currentStage': cs.currentStage,
                'nextTargetWeight': cs.nextTargetWeight,
                'lastStage1SuccessWeight': cs.lastStage1SuccessWeight,
                'currentT3AmrapVolume': cs.currentT3AmrapVolume,
                'lastUpdated': cs.lastUpdated.toIso8601String(),
              })
          .toList(),
      'sessions': sessions
          .map((s) => {
                'id': s.id,
                'dayType': s.dayType,
                'dateStarted': s.dateStarted.toIso8601String(),
                'dateCompleted': s.dateCompleted?.toIso8601String(),
                'isFinalized': s.isFinalized,
                'sessionNotes': s.sessionNotes,
              })
          .toList(),
      'sets': allSets,
      'accessories': accessories
          .map((a) => {
                'id': a.id,
                'dayType': a.dayType,
                'name': a.name,
                'orderIndex': a.orderIndex,
              })
          .toList(),
      'preferences': preferences != null
          ? {
              'unitSystem': preferences.unitSystem,
              't1RestSeconds': preferences.t1RestSeconds,
              't2RestSeconds': preferences.t2RestSeconds,
              't3RestSeconds': preferences.t3RestSeconds,
              'minimumRestHours': preferences.minimumRestHours,
            }
          : null,
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }
}
