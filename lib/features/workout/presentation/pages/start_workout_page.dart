import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../workout/data/datasources/local/app_database.dart';
import '../../../workout/domain/entities/accessory_exercise_entity.dart';
import '../../../workout/domain/repositories/accessory_exercise_repository.dart';
import '../bloc/active_workout/active_workout_bloc.dart';
import '../bloc/active_workout/active_workout_event.dart';
import '../bloc/active_workout/active_workout_state.dart';

/// Start workout page - day selection
class StartWorkoutPage extends StatefulWidget {
  const StartWorkoutPage({super.key});

  @override
  State<StartWorkoutPage> createState() => _StartWorkoutPageState();
}

class _StartWorkoutPageState extends State<StartWorkoutPage> {
  final Map<String, List<AccessoryExerciseEntity>> _t3ExercisesByDay = {};
  bool _isLoadingT3 = true;
  Set<String> _completedDaysThisWeek = {};
  int _currentWeek = 1;

  @override
  void initState() {
    super.initState();
    _loadT3Exercises();
    _loadCycleInfo();
  }

  Future<void> _loadT3Exercises() async {
    final accessoryRepo = sl<AccessoryExerciseRepository>();

    // Load T3 exercises for all days
    for (final day in ['1', '2', '3', '4']) {
      final result = await accessoryRepo.getAccessoriesForDay(day);
      result.fold(
        (_) => _t3ExercisesByDay[day] = [],
        (exercises) => _t3ExercisesByDay[day] = exercises,
      );
    }

    setState(() {
      _isLoadingT3 = false;
    });
  }

  Future<void> _loadCycleInfo() async {
    final db = sl<AppDatabase>();
    final activeCycle = await db.cyclesDao.getActiveCycle();
    if (activeCycle != null) {
      final currentWeek = activeCycle.completedRotations + 1;
      final sessions = await db.workoutSessionsDao
          .getFinalizedDayTypesForRotation(activeCycle.id, currentWeek);
      if (mounted) {
        setState(() {
          _currentWeek = currentWeek;
          _completedDaysThisWeek = sessions;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ActiveWorkoutBloc>(),
      child: BlocConsumer<ActiveWorkoutBloc, ActiveWorkoutState>(
        listener: (context, state) {
          if (state is ActiveWorkoutLoaded) {
            // Navigate to active workout page
            Navigator.of(context).pushReplacementNamed(AppRoutes.activeWorkout);
          } else if (state is ActiveWorkoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ActiveWorkoutLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Start Workout')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return _buildDaySelection(context);
        },
      ),
    );
  }

  Widget _buildDaySelection(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Workout'),
      ),
      body: _isLoadingT3
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Week $_currentWeek of 12',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a day to train',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDayCard(
                          context,
                          '1',
                          'Squat',
                          'Overhead Press',
                          _t3ExercisesByDay['1'] ?? [],
                          _completedDaysThisWeek,
                        ),
                        const SizedBox(height: 12),
                        _buildDayCard(
                          context,
                          '2',
                          'Bench Press',
                          'Deadlift',
                          _t3ExercisesByDay['2'] ?? [],
                          _completedDaysThisWeek,
                        ),
                        const SizedBox(height: 12),
                        _buildDayCard(
                          context,
                          '3',
                          'Bench Press',
                          'Squat',
                          _t3ExercisesByDay['3'] ?? [],
                          _completedDaysThisWeek,
                        ),
                        const SizedBox(height: 12),
                        _buildDayCard(
                          context,
                          '4',
                          'Deadlift',
                          'Overhead Press',
                          _t3ExercisesByDay['4'] ?? [],
                          _completedDaysThisWeek,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    String dayType,
    String t1Lift,
    String t2Lift,
    List<AccessoryExerciseEntity> t3Exercises,
    Set<String> completedDays,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          // Start workout for selected day
          context.read<ActiveWorkoutBloc>().add(StartWorkout(dayType: dayType));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: completedDays.contains(dayType)
                          ? Colors.green
                          : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: completedDays.contains(dayType)
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text(
                              dayType,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day $dayType',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (completedDays.contains(dayType))
                          Text(
                            'Done this week',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _buildLiftRow(context, 'T1', t1Lift),
              const SizedBox(height: 4),
              _buildLiftRow(context, 'T2', t2Lift),
              // Display T3 exercises
              if (t3Exercises.isNotEmpty) ...[
                const SizedBox(height: 4),
                for (final t3Exercise in t3Exercises)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: _buildLiftRow(context, 'T3', t3Exercise.name),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiftRow(BuildContext context, String tier, String liftName) {
    Color backgroundColor;
    Color textColor;

    switch (tier) {
      case 'T1':
        backgroundColor = Colors.red.withValues(alpha: 0.2);
        textColor = Colors.red.shade900;
        break;
      case 'T2':
        backgroundColor = Colors.blue.withValues(alpha: 0.2);
        textColor = Colors.blue.shade900;
        break;
      case 'T3':
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green.shade900;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.2);
        textColor = Colors.grey.shade900;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tier,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            liftName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
