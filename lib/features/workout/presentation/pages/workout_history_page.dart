import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/workout_session_entity.dart';
import '../bloc/workout/workout_bloc.dart';
import '../bloc/workout/workout_event.dart';
import '../bloc/workout/workout_state.dart';

/// Workout history page showing past workout sessions
class WorkoutHistoryPage extends StatefulWidget {
  const WorkoutHistoryPage({super.key});

  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  String? _filterDayType;
  final _dateFormat = DateFormat('MMM d, yyyy');
  final _timeFormat = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutBloc>()..add(const LoadWorkoutHistory()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout History'),
          actions: [
            // Filter button
            PopupMenuButton<String?>(
              icon: Icon(
                _filterDayType != null ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
              tooltip: 'Filter by day',
              onSelected: (value) {
                setState(() {
                  _filterDayType = value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: null,
                  child: Text('All Days'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'A',
                  child: Text('Day A'),
                ),
                const PopupMenuItem(
                  value: 'B',
                  child: Text('Day B'),
                ),
                const PopupMenuItem(
                  value: 'C',
                  child: Text('Day C'),
                ),
                const PopupMenuItem(
                  value: 'D',
                  child: Text('Day D'),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<WorkoutBloc, WorkoutState>(
          builder: (context, state) {
            if (state is WorkoutLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WorkoutError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading history',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<WorkoutBloc>().add(const LoadWorkoutHistory());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is WorkoutHistoryLoaded) {
              final sessions = _filterDayType == null
                  ? state.sessions
                  : state.sessions.where((s) => s.dayType == _filterDayType).toList();

              if (sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _filterDayType == null
                            ? 'No workout history yet'
                            : 'No workouts for Day $_filterDayType',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _filterDayType == null
                            ? 'Complete your first workout to see it here!'
                            : 'Try removing the filter to see all workouts',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (_filterDayType != null) ...[
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _filterDayType = null;
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Filter'),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return _WorkoutSessionCard(
                    session: session,
                    dateFormat: _dateFormat,
                    timeFormat: _timeFormat,
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

/// Card displaying a single workout session
class _WorkoutSessionCard extends StatelessWidget {
  final WorkoutSessionEntity session;
  final DateFormat dateFormat;
  final DateFormat timeFormat;

  const _WorkoutSessionCard({
    required this.session,
    required this.dateFormat,
    required this.timeFormat,
  });

  Color _getDayTypeColor() {
    switch (session.dayType) {
      case 'A':
        return Colors.red;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.green;
      case 'D':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Duration? _getSessionDuration() {
    if (session.dateCompleted != null) {
      return session.dateCompleted!.difference(session.dateStarted);
    }
    return null;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = _getSessionDuration();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to session details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session details coming soon!'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Day type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getDayTypeColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Day ${session.dayType}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Date
                  Text(
                    dateFormat.format(session.dateStarted),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  // Time
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(session.dateStarted),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (duration != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(duration),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),

              // Notes (if any)
              if (session.sessionNotes != null && session.sessionNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          session.sessionNotes!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
