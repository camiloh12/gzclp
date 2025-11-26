import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/datasources/local/app_database.dart';

/// Performance dashboard showing current lift status and statistics
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _database = sl<AppDatabase>();
  bool _isLoading = true;
  List<Lift> _lifts = [];
  List<CycleState> _cycleStates = [];
  List<WorkoutSession> _recentSessions = [];
  int _totalWorkouts = 0;
  UserPreference? _preferences;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final lifts = await _database.liftsDao.getAllLifts();
      final cycleStates = await _database.cycleStatesDao.getAllCycleStates();
      final sessions = await _database.workoutSessionsDao.getFinalizedSessions();
      final prefs = await _database.userPreferencesDao.getPreferences();

      setState(() {
        _lifts = lifts;
        _cycleStates = cycleStates;
        _recentSessions = sessions.take(5).toList();
        _totalWorkouts = sessions.length;
        _preferences = prefs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getUnitLabel() {
    return _preferences?.unitSystem == 'metric' ? 'kg' : 'lbs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics summary
                    _buildStatsSummary(),
                    const SizedBox(height: 24),

                    // Lift status cards
                    Text(
                      'Current Lift Status',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ..._lifts.map((lift) => _buildLiftStatusCard(lift)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsSummary() {
    final currentStreak = _calculateCurrentStreak();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.fitness_center,
                    label: 'Total Workouts',
                    value: '$_totalWorkouts',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    icon: Icons.local_fire_department,
                    label: 'Current Streak',
                    value: '$currentStreak days',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _calculateCurrentStreak() {
    if (_recentSessions.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (final session in _recentSessions.reversed) {
      final sessionDate = DateTime(
        session.dateStarted.year,
        session.dateStarted.month,
        session.dateStarted.day,
      );

      if (lastDate == null) {
        // First session
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final diff = todayDate.difference(sessionDate).inDays;

        if (diff > 7) {
          // Session too old, no current streak
          return 0;
        }
        streak = 1;
        lastDate = sessionDate;
      } else {
        final diff = lastDate.difference(sessionDate).inDays;
        if (diff <= 7) {
          // Within a week, count it
          streak++;
          lastDate = sessionDate;
        } else {
          // Gap too large, stop counting
          break;
        }
      }
    }

    return streak;
  }

  Widget _buildLiftStatusCard(Lift lift) {
    // Get cycle states for this lift
    final t1State = _cycleStates.firstWhere(
      (cs) => cs.liftId == lift.id && cs.currentTier == 'T1',
      orElse: () => CycleState(
        id: 0,
        cycleId: 1, // Default to cycle 1
        liftId: lift.id,
        currentTier: 'T1',
        currentStage: 1,
        nextTargetWeight: 0,
        lastStage1SuccessWeight: null,
        currentT3AmrapVolume: 0,
        lastUpdated: DateTime.now(),
      ),
    );

    final t2State = _cycleStates.firstWhere(
      (cs) => cs.liftId == lift.id && cs.currentTier == 'T2',
      orElse: () => CycleState(
        id: 0,
        cycleId: 1, // Default to cycle 1
        liftId: lift.id,
        currentTier: 'T2',
        currentStage: 1,
        nextTargetWeight: 0,
        lastStage1SuccessWeight: null,
        currentT3AmrapVolume: 0,
        lastUpdated: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getLiftColor(lift.category),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              _getLiftIcon(lift.name),
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        title: Text(
          lift.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          'T1 Stage ${t1State.currentStage} • ${t1State.nextTargetWeight} ${_getUnitLabel()}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTierRow(
                  'T1',
                  t1State.currentStage,
                  t1State.nextTargetWeight,
                  Colors.red,
                ),
                const SizedBox(height: 12),
                _buildTierRow(
                  'T2',
                  t2State.currentStage,
                  t2State.nextTargetWeight,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierRow(String tier, int stage, double weight, Color color) {
    String stageLabel;
    switch (tier) {
      case 'T1':
        stageLabel = stage == 1
            ? '5x3+'
            : stage == 2
                ? '6x2+'
                : '10x1+';
        break;
      case 'T2':
        stageLabel = stage == 1
            ? '3x10'
            : stage == 2
                ? '3x8'
                : '3x6';
        break;
      default:
        stageLabel = '3x15+';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tier,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Stage $stage: $stageLabel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            '$weight ${_getUnitLabel()}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLiftColor(String category) {
    return category == 'lower' ? Colors.deepPurple : Colors.teal;
  }

  IconData _getLiftIcon(String liftName) {
    if (liftName.toLowerCase().contains('squat')) {
      return Icons.airline_seat_legroom_normal;
    } else if (liftName.toLowerCase().contains('bench')) {
      return Icons.hotel;
    } else if (liftName.toLowerCase().contains('dead')) {
      return Icons.fitness_center;
    } else if (liftName.toLowerCase().contains('press')) {
      return Icons.arrow_upward;
    }
    return Icons.fitness_center;
  }
}

/// Stat item widget for summary cards
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
