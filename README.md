# GZCLP Workout Tracker

A cross-platform Flutter application (Android/iOS/Web) for automating the GZCL Linear Progression (GZCLP) strength training program. This app eliminates manual spreadsheet tracking by automatically managing tier-based structure, progression rules, stage cycles, and failure resets.

**Development Strategy:** Mobile-first with web support for rapid development and testing. Web deployment enables faster iteration cycles during development while maintaining focus on native mobile performance.

## Project Status

**Current Phase:** ✅ Phase 4 COMPLETE - Fully Functional App

### Completed Phases

- ✅ **Phase 0:** Project Foundation - Flutter setup, clean architecture, dependencies
- ✅ **Phase 1:** Database Schema & Models - SQLite/Drift database with 6 tables, 30 passing tests
- ✅ **Phase 2:** Core Progression Logic - Complete GZCLP algorithm implementation
- ✅ **Phase 3:** UI Implementation - Complete presentation layer with BLoC pattern
- ✅ **Phase 4:** Database Integration & Web Support - Full end-to-end functionality, IndexedDB for web

### App Status

**🎉 Fully Functional MVP** - The app now supports complete workout tracking:
- ✅ Onboarding flow with unit selection and lift initialization
- ✅ Workout session creation and logging
- ✅ Automatic GZCLP progression algorithm
- ✅ Session recovery after interruptions
- ✅ Cross-platform (Android, iOS, Web)

### Next Phases

- **Phase 5:** T3 Accessory Exercises
- **Phase 6:** Advanced Features (history, progress tracking, PRs)
- **Phase 7:** Cloud Sync (optional, post-MVP)

## Features Implemented

### Database Layer (Phase 1)
- **6 Core Tables:** Lifts, CycleStates, WorkoutSessions, WorkoutSets, UserPreferences, AccessoryExercises
- **DAOs with CRUD operations** for all tables
- **Foreign key cascades** and unique constraints
- **Transaction support** for atomic updates
- **30 comprehensive database tests** - all passing

### Business Logic (Phase 2)
- **T1 Progression:** 5x3+ → 6x2+ → 10x1+ → reset at 85%
- **T2 Progression:** 3x10 → 3x8 → 3x6 → reset with historical anchor
- **T3 Progression:** 3x15+ AMRAP-based (25+ reps threshold)
- **Session Finalization:** Atomic multi-state updates
- **Workout Generation:** 4-day rotation (A/B/C/D)
- **Clean Architecture:** Domain entities, repository pattern, use cases

### Presentation Layer (Phase 3)
- **BLoC State Management:** OnboardingBloc & WorkoutBloc with full event/state handling
- **5 Complete Screens:** Splash, Onboarding, Home, Start Workout, Active Workout
- **Reusable UI Components:** SetCard, RestTimerWidget, Onboarding steps
- **Material Design 3:** Light/dark themes with system preference support
- **Complete User Flows:** Onboarding → Day Selection → Set Logging → Completion
- **Progress Tracking:** Visual indicators, set counters, completion states
- **Form Validation:** Real-time input validation for weights and reps
- **Navigation:** Named routes with proper back stack management

## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/          # App-wide constants (GZCLP rules)
│   ├── di/                 # Dependency injection (GetIt)
│   ├── error/              # Error handling (Exceptions & Failures)
│   └── usecases/           # Base use case classes
│
├── features/
│   └── workout/
│       ├── data/
│       │   ├── datasources/local/    # Drift database & DAOs
│       │   └── repositories/         # Repository implementations
│       ├── domain/
│       │   ├── entities/             # Business objects
│       │   ├── repositories/         # Repository interfaces
│       │   └── usecases/             # Business logic
│       └── presentation/             # UI (BLoCs, Pages, Widgets)
│
└── main.dart               # App entry point
```

### Technology Stack

- **Flutter SDK:** v3.35.7
- **Dart:** v3.9.2
- **Database:**
  - Mobile: SQLite via Drift ORM
  - Web: IndexedDB via Drift ORM
- **State Management:** BLoC pattern (flutter_bloc)
- **Dependency Injection:** GetIt
- **Functional Programming:** Dartz (Either type)
- **Testing:** flutter_test, bloc_test, mockito
- **Platforms:** Android, iOS, Web (Chrome)

## Getting Started

### Prerequisites

- Flutter SDK (stable channel v3.35.7 or later)
- Dart SDK (v3.9.2 or later)
- Android Studio / VS Code with Flutter plugins
- For Linux: SQLite3 development libraries

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd gzclp_tracker
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Drift code:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Verify installation:**
   ```bash
   flutter analyze
   # Should output: No issues found!
   ```

### Running the App

**Web (recommended for development/testing):**
```bash
flutter run -d chrome --web-port=8080
```
*Web provides fastest hot reload and debugging experience during development.*

**Android:**
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

**iOS:**
```bash
flutter run -d <ios-device-id>
```

## Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test Suite

```bash
# Database tests
flutter test test/features/workout/data/datasources/local/app_database_test.dart

# Core constants tests
flutter test test/core/constants/app_constants_test.dart
```

### Linux-Specific Setup for Tests

If tests fail with `libsqlite3.so: cannot open shared object file`:

```bash
# Create symlink to SQLite library
mkdir -p ~/.local/lib
ln -sf /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 ~/.local/lib/libsqlite3.so

# Run tests with library path
LD_LIBRARY_PATH=~/.local/lib:$LD_LIBRARY_PATH flutter test
```

### Test Coverage

**Current Status:** 39 tests passing
- 8 core constants tests
- 1 widget test
- 30 database tests (DAO operations, constraints, transactions)

## Development

### Code Generation

After modifying Drift table definitions:

```bash
# Regenerate database code
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
dart run build_runner watch
```

### Code Quality

```bash
# Static analysis
flutter analyze

# Format code
flutter format .
```

## Project Documentation

Detailed documentation for each phase:

- **[FUNCTIONAL_SPECIFICATION.md](FUNCTIONAL_SPECIFICATION.md)** - Complete app requirements
- **[DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md)** - 7-phase development roadmap
- **[CLAUDE.md](CLAUDE.md)** - AI assistant guidance and project status
- **[PHASE_0_SUMMARY.md](PHASE_0_SUMMARY.md)** - Foundation setup details
- **[PHASE_1_SUMMARY.md](PHASE_1_SUMMARY.md)** - Database implementation details
- **[PHASE_2_SUMMARY.md](PHASE_2_SUMMARY.md)** - Progression logic implementation
- **[PHASE_3_SUMMARY.md](PHASE_3_SUMMARY.md)** - UI implementation details
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Flutter installation guide

### Platform Notes

**Web Support:** The app runs on web browsers for development and testing. Note that web deployment uses IndexedDB for storage, which requires proper Drift configuration. The primary target remains native mobile platforms for optimal performance.

## GZCLP Program Overview

The app implements the GZCL Linear Progression program with:

### Three-Tier Structure
- **T1 (Tier 1):** Primary compound lifts - 3 stages (5x3+, 6x2+, 10x1+)
- **T2 (Tier 2):** Secondary compound lifts - 3 stages (3x10, 3x8, 3x6)
- **T3 (Tier 3):** Accessory lifts - single stage (3x15+)

### Four-Day Rotation
- **Day A:** Squat (T1), Overhead Press (T2)
- **Day B:** Bench Press (T1), Deadlift (T2)
- **Day C:** Bench Press (T1), Squat (T2)
- **Day D:** Deadlift (T1), Overhead Press (T2)

### Progression Rules
- **T1 Success:** AMRAP set meets target → add weight
- **T1 Failure:** AMRAP set fails → advance stage or reset (85%)
- **T2 Success:** All sets meet target → add weight
- **T2 Failure:** Any set fails → advance stage or reset (historical anchor + increment)
- **T3 Success:** AMRAP ≥ 25 reps → add weight (5 lbs / 2.5 kg)

## Core Implementation Highlights

### Critical Features

1. **Atomic Session Finalization**
   ```dart
   await finalizeWorkoutSession(FinalizeSessionParams(
     sessionId: sessionId,
     isMetric: isMetric,
   ));
   ```
   - Applies progression to all lifts atomically
   - Prevents duplicate updates via `isFinalized` flag

2. **T2 Historical Anchor Tracking**
   ```dart
   // CRITICAL: Updated on every successful T2 Stage 1
   lastStage1SuccessWeight: currentState.nextTargetWeight
   ```
   - Essential for proper T2 reset calculations

3. **Transaction-Based Updates**
   ```dart
   await cycleStateRepository.updateCycleStatesInTransaction(updatedStates);
   ```
   - ALL state updates or NONE (data integrity)

## Contributing

This is a personal project, but suggestions and feedback are welcome.

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter format` before committing
- Ensure `flutter analyze` passes with no issues
- Write tests for new features

## License

[To be determined]

## Acknowledgments

- **Cody Lefever** - Creator of GZCL training methodology
- **Flutter Team** - Amazing cross-platform framework
- **Drift** - Type-safe SQLite ORM for Dart

---

**Built with Flutter for maximum cross-platform compatibility and native performance.**
