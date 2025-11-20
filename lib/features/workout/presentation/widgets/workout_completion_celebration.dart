import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Celebration widget shown when workout is completed
class WorkoutCompletionCelebration extends StatefulWidget {
  final VoidCallback onDismiss;

  const WorkoutCompletionCelebration({
    super.key,
    required this.onDismiss,
  });

  @override
  State<WorkoutCompletionCelebration> createState() =>
      _WorkoutCompletionCelebrationState();
}

class _WorkoutCompletionCelebrationState
    extends State<WorkoutCompletionCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Auto dismiss after animation completes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Stack(
        children: [
          // Confetti particles
          ...List.generate(30, (index) {
            return _ConfettiParticle(
              controller: _controller,
              index: index,
            );
          }),
          // Center celebration message
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 100,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Workout Complete!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Great job! 💪',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Single confetti particle
class _ConfettiParticle extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const _ConfettiParticle({
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index);
    final startX = random.nextDouble();
    final endY = 1.0 + random.nextDouble() * 0.5;
    final color = _getRandomColor(random);
    final size = 6.0 + random.nextDouble() * 8.0;
    final rotation = random.nextDouble() * 2 * math.pi;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value;
        final x = startX + (random.nextDouble() - 0.5) * 0.3 * progress;
        final y = progress * endY;

        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y,
          child: Transform.rotate(
            angle: rotation * progress,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: random.nextBool()
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: random.nextBool()
                    ? BorderRadius.circular(2)
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    return colors[random.nextInt(colors.length)];
  }
}
