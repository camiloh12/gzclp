import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

/// Rest timer widget - displays countdown for rest periods between sets
class RestTimerWidget extends StatefulWidget {
  final int? initialSeconds;

  const RestTimerWidget({
    super.key,
    this.initialSeconds,
  });

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds ?? AppConstants.T1.restSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isRunning = false;
        });
        // Could add notification/sound here
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.initialSeconds ?? AppConstants.T1.restSeconds;
      _isRunning = false;
    });
  }

  void _addTime(int seconds) {
    setState(() {
      _remainingSeconds += seconds;
    });
  }

  void _skipTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListTile(
          leading: const Icon(Icons.timer),
          title: const Text('Rest Timer'),
          trailing: IconButton(
            icon: const Icon(Icons.expand_more),
            onPressed: () {
              setState(() {
                _isExpanded = true;
              });
            },
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: _remainingSeconds == 0
          ? Colors.green.withValues(alpha: 0.1)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: _remainingSeconds == 0
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rest Timer',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.expand_less),
                  onPressed: () {
                    setState(() {
                      _isExpanded = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Timer display
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _remainingSeconds == 0
                    ? Colors.green.withValues(alpha: 0.2)
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatTime(_remainingSeconds),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds == 0
                          ? Colors.green.shade900
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
            if (_remainingSeconds == 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Rest Complete - Ready for Next Set!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Control buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_isRunning)
                  ElevatedButton.icon(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  )
                else if (_remainingSeconds > 0)
                  ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                if (_remainingSeconds > 0)
                  ElevatedButton.icon(
                    onPressed: _skipTimer,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Skip'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Quick add time buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _addTime(30),
                  child: const Text('+30s'),
                ),
                TextButton(
                  onPressed: () => _addTime(60),
                  child: const Text('+1m'),
                ),
                TextButton(
                  onPressed: () => _addTime(120),
                  child: const Text('+2m'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
