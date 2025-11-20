/// Route names for the application
class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  /// Splash/loading screen
  static const String splash = '/';

  /// Onboarding flow
  static const String onboarding = '/onboarding';

  /// Home screen (main app)
  static const String home = '/home';

  /// Start workout (day selection)
  static const String startWorkout = '/start-workout';

  /// Active workout session
  static const String activeWorkout = '/active-workout';

  /// Workout history
  static const String history = '/history';

  /// Performance dashboard
  static const String dashboard = '/dashboard';

  /// Settings
  static const String settings = '/settings';
}
