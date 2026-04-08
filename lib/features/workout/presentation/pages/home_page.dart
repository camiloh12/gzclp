import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/session_manager/session_manager_bloc.dart';
import '../bloc/session_manager/session_manager_event.dart';
import '../bloc/session_manager/session_manager_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<SessionManagerBloc>()..add(const CheckInProgressSession()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GZCLP Tracker'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.history),
              tooltip: 'History',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.settings),
              tooltip: 'Settings',
            ),
          ],
        ),
        body: BlocBuilder<SessionManagerBloc, SessionManagerState>(
          builder: (context, state) {
            if (state is SessionManagerInitial || state is SessionManagerLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SessionManagerError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<SessionManagerBloc>()
                    .add(const CheckInProgressSession()),
              );
            }
            if (state is SessionManagerInProgress) {
              return _HomeBody(
                activeCycle: state.activeCycle,
                currentWeek: state.currentWeek,
                completedDaysThisWeek: state.completedDaysThisWeek,
                child: _ResumeWorkoutCard(dayType: state.session.dayType),
              );
            }
            final noSession = state as SessionManagerNoSession;
            return _HomeBody(
              activeCycle: noSession.activeCycle,
              currentWeek: noSession.currentWeek,
              completedDaysThisWeek: noSession.completedDaysThisWeek,
              child: noSession.isCycleComplete
                  ? const _NewCycleButton()
                  : const _StartWorkoutButton(),
            );
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final dynamic activeCycle;
  final int currentWeek;
  final Set<String> completedDaysThisWeek;
  final Widget child;

  const _HomeBody({
    required this.activeCycle,
    required this.currentWeek,
    required this.completedDaysThisWeek,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            if (activeCycle != null) ...[
              Text(
                'Cycle ${activeCycle.cycleNumber} • Week $currentWeek of 12',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _WeekDayStatusRow(completedDays: completedDaysThisWeek),
              const SizedBox(height: 32),
            ],
            child,
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.dashboard),
              icon: const Icon(Icons.analytics),
              label: const Text('View Dashboard'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekDayStatusRow extends StatelessWidget {
  final Set<String> completedDays;
  const _WeekDayStatusRow({required this.completedDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['1', '2', '3', '4'].map((day) {
        final done = completedDays.contains(day);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.circle_outlined,
                color: done ? Colors.green : Colors.grey,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                'Day $day',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StartWorkoutButton extends StatelessWidget {
  const _StartWorkoutButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () =>
          Navigator.of(context).pushNamed(AppRoutes.startWorkout),
      icon: const Icon(Icons.add),
      label: const Text('Start Workout'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );
  }
}

class _NewCycleButton extends StatelessWidget {
  const _NewCycleButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () =>
          Navigator.of(context).pushNamed(AppRoutes.newCycle),
      icon: const Icon(Icons.refresh),
      label: const Text('Start New Cycle'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _ResumeWorkoutCard extends StatelessWidget {
  final String dayType;
  const _ResumeWorkoutCard({required this.dayType});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Workout in Progress — Day $dayType',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.activeWorkout),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Continue Workout'),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
