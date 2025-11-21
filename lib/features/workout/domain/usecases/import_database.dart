import 'dart:convert';

import 'package:drift/drift.dart' as drift;

import '../../../../core/di/injection_container.dart';
import '../../data/datasources/local/app_database.dart';

/// Imports workout data from JSON format
class ImportDatabase {
  final AppDatabase _database = sl<AppDatabase>();

  /// Import data from JSON string
  /// Returns true if successful, throws exception on error
  Future<bool> call(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;

      // Validate version
      if (data['version'] != '1.0') {
        throw Exception('Unsupported data version: ${data['version']}');
      }

      // Import in transaction for atomicity
      await _database.transaction(() async {
        // Import preferences first
        if (data['preferences'] != null) {
          final prefs = data['preferences'] as Map<String, dynamic>;
          await _database.userPreferencesDao.updatePreferenceFields(
            unitSystem: prefs['unitSystem'] as String?,
            t1RestSeconds: prefs['t1RestSeconds'] as int?,
            t2RestSeconds: prefs['t2RestSeconds'] as int?,
            t3RestSeconds: prefs['t3RestSeconds'] as int?,
            minimumRestHours: prefs['minimumRestHours'] as int?,
          );
        }

        // Import lifts (update existing ones)
        final lifts = data['lifts'] as List<dynamic>;
        for (final liftData in lifts) {
          final lift = liftData as Map<String, dynamic>;
          final id = lift['id'] as int;

          // Check if lift exists
          final existing = await _database.liftsDao.getLiftById(id);
          if (existing != null) {
            // Update existing lift
            await _database.liftsDao.updateLift(
              Lift(
                id: id,
                name: lift['name'] as String,
                category: lift['category'] as String,
              ),
            );
          }
        }

        // Import cycle states
        final cycleStates = data['cycleStates'] as List<dynamic>;
        for (final csData in cycleStates) {
          final cs = csData as Map<String, dynamic>;
          await _database.cycleStatesDao.updateCycleState(
            CycleState(
              id: cs['id'] as int,
              liftId: cs['liftId'] as int,
              currentTier: cs['currentTier'] as String,
              currentStage: cs['currentStage'] as int,
              nextTargetWeight: (cs['nextTargetWeight'] as num).toDouble(),
              lastStage1SuccessWeight: cs['lastStage1SuccessWeight'] != null
                  ? (cs['lastStage1SuccessWeight'] as num).toDouble()
                  : null,
              currentT3AmrapVolume: cs['currentT3AmrapVolume'] as int,
              lastUpdated: DateTime.parse(cs['lastUpdated'] as String),
            ),
          );
        }

        // Import accessories (delete existing and insert new)
        await _database.delete(_database.accessoryExercises).go();
        final accessories = data['accessories'] as List<dynamic>;
        for (final accData in accessories) {
          final acc = accData as Map<String, dynamic>;
          await _database.accessoryExercisesDao.insertAccessory(
            AccessoryExerciseCompanion.insert(
              dayType: acc['dayType'] as String,
              name: acc['name'] as String,
              orderIndex: acc['orderIndex'] as int,
            ),
          );
        }

        // Import sessions
        final sessions = data['sessions'] as List<dynamic>;
        final sessionIdMap = <int, int>{}; // old ID -> new ID

        for (final sessionData in sessions) {
          final session = sessionData as Map<String, dynamic>;
          final oldId = session['id'] as int;

          final newId = await _database.into(_database.workoutSessions).insert(
            WorkoutSessionCompanion.insert(
              dayType: session['dayType'] as String,
              dateStarted: DateTime.parse(session['dateStarted'] as String),
              dateCompleted: session['dateCompleted'] != null
                  ? drift.Value(DateTime.parse(session['dateCompleted'] as String))
                  : const drift.Value.absent(),
              isFinalized: drift.Value(session['isFinalized'] as bool),
              sessionNotes: session['sessionNotes'] != null
                  ? drift.Value(session['sessionNotes'] as String)
                  : const drift.Value.absent(),
            ),
          );

          sessionIdMap[oldId] = newId;
        }

        // Import sets
        final sets = data['sets'] as List<dynamic>;
        for (final setData in sets) {
          final set = setData as Map<String, dynamic>;
          final oldSessionId = set['sessionId'] as int;
          final newSessionId = sessionIdMap[oldSessionId];

          if (newSessionId != null) {
            await _database.into(_database.workoutSets).insert(
              WorkoutSetCompanion.insert(
                sessionId: newSessionId,
                liftId: set['liftId'] as int,
                tier: set['tier'] as String,
                setNumber: set['setNumber'] as int,
                targetReps: set['targetReps'] as int,
                targetWeight: (set['targetWeight'] as num).toDouble(),
                actualReps: set['actualReps'] != null
                    ? drift.Value(set['actualReps'] as int)
                    : const drift.Value.absent(),
                actualWeight: set['actualWeight'] != null
                    ? drift.Value((set['actualWeight'] as num).toDouble())
                    : const drift.Value.absent(),
                isAmrap: drift.Value(set['isAmrap'] as bool),
                setNotes: set['setNotes'] != null
                    ? drift.Value(set['setNotes'] as String)
                    : const drift.Value.absent(),
                exerciseName: set['exerciseName'] != null
                    ? drift.Value(set['exerciseName'] as String)
                    : const drift.Value.absent(),
              ),
            );
          }
        }
      });

      return true;
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
