import 'package:flutter/material.dart';

import 'core/di/injection_container.dart' as di;
import 'core/routes/app_routes.dart';
import 'features/workout/presentation/pages/active_workout_page.dart';
import 'features/workout/presentation/pages/dashboard_page.dart';
import 'features/workout/presentation/pages/home_page.dart';
import 'features/workout/presentation/pages/onboarding_page.dart';
import 'features/workout/presentation/pages/splash_page.dart';
import 'features/workout/presentation/pages/start_workout_page.dart';
import 'features/workout/presentation/pages/workout_history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const GZCLPApp());
}

class GZCLPApp extends StatelessWidget {
  const GZCLPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GZCLP Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashPage(),
        AppRoutes.onboarding: (context) => const OnboardingPage(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.startWorkout: (context) => const StartWorkoutPage(),
        AppRoutes.activeWorkout: (context) => const ActiveWorkoutPage(),
        AppRoutes.history: (context) => const WorkoutHistoryPage(),
        AppRoutes.dashboard: (context) => const DashboardPage(),
      },
    );
  }
}
