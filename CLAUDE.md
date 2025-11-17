# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GZCLP Mobile Workout Tracker - A cross-platform (Android/iOS/Web) application for automating the GZCL Linear Progression strength training program. The app eliminates manual spreadsheet tracking by managing tier-based structure, progression rules, stage cycles, and failure resets.

**Technology Stack:** Flutter (Dart) for cross-platform development, targeting native ARM compilation for optimal mobile performance.

**Development Strategy:** Mobile-first with web support for faster development, testing, and debugging. Web deployment enables rapid iteration during development while maintaining the primary focus on mobile user experience.

## Core Architecture

### Data Persistence Strategy

**Local-First Design:** The app must function completely offline. All core functionality (workout generation, logging, progression calculation, rest timer) operates without internet dependency.

**Primary Database:** SQLite via the Drift package handles all relational data:
- WorkoutSession logs
- WorkoutSet details (actual_reps, actual_weight, is_amrap flags)
- CycleState progression tracking
- Historical data for T2 reset anchors

**Platform-Specific Storage:**
- **Mobile (Android/iOS):** Native SQLite in app documents directory
- **Web (Browser):** IndexedDB for persistent browser storage (requires DriftWebOptions configuration)

**Critical Database Requirement:** The CycleState table maintains complex linkages between sessions, sets, and progression states. Session finalization must use atomic transactions to prevent corruption of historical anchor points required for T1 and T2 resets.

**Secondary Storage:** SharedPreferences for non-critical UI preferences and settings.

### GZCLP Progression Algorithm

The entire application revolves around accurately implementing Cody LeFever's GZCLP progression logic. This is the most complex and critical part of the system.

**Three-Tier Structure:**
- T1 (Tier 1): Primary compound lifts with 3 stages (5x3+, 6x2+, 10x1+)
- T2 (Tier 2): Secondary compound lifts with 3 stages (3x10, 3x8, 3x6)
- T3 (Tier 3): Accessory lifts with single stage (3x15+)

**Four-Day Rotation:** A→B→C→D→A cycling through Squat/Bench/Deadlift/OHP combinations with mandatory rest periods (24hr default, 18hr minimum) between sessions.

**T1 Progression Logic:**
- Success: Add weight (Lower: 10lbs/5kg, Upper: 5lbs/2.5kg)
- Failure: Keep weight, advance to next stage
- Stage 3 Failure: Reset to Stage 1 at 85% of new 5RM (user-tested) or 85% of last Stage 3 success weight

**T2 Progression Logic:**
- Success: Add weight (same increments as T1)
- Failure: Keep weight, advance to next stage
- Stage 3 Failure: Reset to Stage 1 at last_stage1_success_weight + 15-20lbs (7.5-10kg)
- **CRITICAL DATA FIELD:** `last_stage1_success_weight` in CycleState must be updated on every successful T2 Stage 1 completion. This historical anchor is essential for T2 resets.

**T3 Progression Logic:**
- Only increase weight if final AMRAP set achieves 25+ reps
- Small increment: 5lbs/2.5kg
- Otherwise maintain current weight

### Background Timer Implementation

**Critical Requirement:** Rest timer must continue running when app is backgrounded, screen is locked, or user switches apps.

**Implementation Strategy:**
- Platform-specific services via Flutter platform channels
- Consider packages like background_hiit_timer
- Local notifications for timer completion (audio/vibration cues)
- Tier-specific defaults: T1: 3-5min, T2: 2-3min, T3: 1-1.5min

### State Management

Use established Flutter patterns (BLoC or Provider) to ensure:
- Modular, testable code
- Separation of business logic from UI
- Scalable architecture for future updates
- Clean database schema migration paths

## Project Status

**Current Phase:** Phase 4 - Database Integration & Web Support ✅ **COMPLETE**
**Next Phase:** Phase 5 - T3 Accessory Exercises
**Last Updated:** 2025-11-06

**Recent Completion:** Fully integrated database with presentation layer, fixed web platform support with IndexedDB storage, resolved async/await bugs in BLoC pattern. App now fully functional end-to-end with onboarding and workout flows working on both mobile and web platforms.

### Phase 0 Accomplishments ✓

✅ **Project Initialized:** Flutter project created with package name `com.gzclp.tracker`
✅ **Clean Architecture:** Full feature-based folder structure established
✅ **Dependencies Configured:** Drift, BLoC, GetIt, Dartz, and testing packages installed
✅ **Core Infrastructure:**
  - Dependency injection container (GetIt)
  - App constants and configuration
  - Error handling (Exceptions & Failures)
  - UseCase base classes
  - Build configuration for Drift code generation

✅ **Basic App Shell:** Material Design 3 app with theme support
✅ **Testing Framework:** Unit test infrastructure with passing tests
✅ **Code Quality:** Passes `flutter analyze` with no issues
✅ **Build Verification:** Successfully builds for web platform

### Phase 1 Accomplishments ✓

✅ **Database Schema Designed:** Complete Drift table definitions for all 6 core tables
✅ **Tables Implemented:**
  - `Lifts` - Main compound lifts (Squat, Bench, Deadlift, OHP)
  - `CycleStates` - **CRITICAL** progression state tracking with `last_stage1_success_weight` field
  - `WorkoutSessions` - Workout session records with finalization tracking
  - `WorkoutSets` - Individual set logging with AMRAP support
  - `UserPreferences` - App settings and configuration
  - `AccessoryExercises` - T3 accessory exercise management

✅ **Database Access Objects (DAOs):** 6 comprehensive DAOs with full CRUD operations
  - LiftsDao - Lift management with category filtering
  - CycleStatesDao - Progression state with transaction support for atomic updates
  - WorkoutSessionsDao - Session management and finalization
  - WorkoutSetsDao - Set tracking with tier and lift filtering
  - UserPreferencesDao - User preferences with field-level updates
  - AccessoryExercisesDao - Accessory exercise management with reordering

✅ **Critical Features Implemented:**
  - Foreign key cascades enabled via `PRAGMA foreign_keys = ON`
  - Unique constraints on (liftId, currentTier) and (dayType, orderIndex)
  - Transaction support for atomic multi-table updates
  - Reorder logic with constraint-safe implementation

✅ **Code Generation:** Drift code successfully generated (app_database.g.dart)
✅ **Dependency Injection:** AppDatabase registered as singleton in DI container
✅ **Testing:** 30 comprehensive database tests - **ALL PASSING**
  - 6 LiftsDao tests
  - 5 CycleStatesDao tests (including transaction atomicity)
  - 5 WorkoutSessionsDao tests
  - 6 WorkoutSetsDao tests
  - 3 UserPreferencesDao tests
  - 4 AccessoryExercisesDao tests
  - 1 Foreign key cascade test

✅ **Code Quality:** Zero issues - passes `flutter analyze` with clean output
✅ **Total Test Coverage:** 39 tests passing (8 core constants + 1 widget + 30 database)

### Phase 2 Accomplishments ✓

✅ **Domain Entities Created:** Pure business objects (4 entities)
  - `LiftEntity` - Lift representation with weight increment logic
  - `CycleStateEntity` ⭐ - **CRITICAL** progression state tracking
  - `WorkoutSessionEntity` - Session lifecycle management
  - `WorkoutSetEntity` - Individual set tracking with AMRAP support

✅ **Repository Interfaces Defined:** Clean separation of concerns (4 interfaces)
  - `LiftRepository`, `CycleStateRepository`, `WorkoutSessionRepository`, `WorkoutSetRepository`
  - All using `Either<Failure, T>` pattern for explicit error handling

✅ **Repository Implementations:** Database integration (4 implementations)
  - Entity ↔ Database model conversion
  - Full CRUD operations with error handling
  - Transaction support for atomic updates

✅ **T1 Progression Logic:** Stage-based progression with resets
  - 5x3+ → 6x2+ → 10x1+ → Reset at 85%
  - AMRAP-based success criteria
  - Practical weight rounding

✅ **T2 Progression Logic:** ⭐⭐ Most complex tier
  - 3x10 → 3x8 → 3x6 → Reset with historical anchor
  - **CRITICAL:** `lastStage1SuccessWeight` tracking for proper resets
  - All sets must meet target (no AMRAP)

✅ **T3 Progression Logic:** AMRAP-based simple progression
  - 3x15+ with 25+ rep threshold
  - Small increments (5 lbs / 2.5 kg)
  - No stage transitions

✅ **Session Finalization Orchestrator:** ⭐⭐⭐ **MOST CRITICAL**
  - `FinalizeWorkoutSession` - Ties all progression logic together
  - Groups sets by lift/tier
  - Applies appropriate progression for each
  - Atomic multi-state updates via transaction
  - Prevents duplicate progression application

✅ **Workout Generation:** Day-based lift assignment
  - 4-day GZCLP rotation (A/B/C/D)
  - Generates programmed weights from current cycle states
  - Set/rep scheme determination

✅ **Dependency Injection:** All components registered
  - 4 Repositories, 5 Use Cases
  - Proper dependency graph
  - Ready for UI layer integration

✅ **Code Quality:** Zero errors, zero warnings
  - Compiles cleanly
  - Follows clean architecture
  - Comprehensive documentation

### Phase 3 Accomplishments ✓

✅ **BLoC State Management:** Complete event-driven architecture
  - OnboardingBloc - Manages first-time setup flow
  - WorkoutBloc - Handles workout session lifecycle
  - Full event/state pattern for predictable state changes

✅ **Onboarding Flow:** Three-step setup wizard
  - Welcome screen with app introduction
  - Unit system selection (metric/imperial)
  - Training max input for all 4 main lifts
  - Automatic T1/T2/T3 weight calculation
  - Database initialization on completion

✅ **Workout Screens:** Complete user journey
  - Splash screen with onboarding status check
  - Home page with workout status
  - Start workout page with day selection (A/B/C/D)
  - Active workout page with set logging
  - Progress tracking and completion flow

✅ **UI Components:** Reusable widgets
  - SetCard - Individual set logging with AMRAP support
  - RestTimerWidget - Countdown timer between sets
  - Onboarding step widgets - Modular setup components
  - Material Design 3 theming (light/dark modes)

✅ **Navigation:** Complete routing system
  - Named routes (splash, onboarding, home, start workout, active workout)
  - Proper back stack management
  - State preservation across navigation

### Phase 4 Accomplishments ✓

✅ **Database Integration:** Full BLoC-to-database connection
  - OnboardingBloc integrated with lift and cycle state repositories
  - WorkoutBloc integrated with session and set repositories
  - Atomic transactions for data integrity
  - Error handling with Either pattern

✅ **Web Platform Support:** Cross-platform database
  - Added `sqlite3` package for web compatibility
  - Compiled drift_worker.dart to JavaScript for browser
  - IndexedDB storage for persistent web data
  - Identical functionality across mobile and web

✅ **Critical Bug Fixes:** Async/await corrections
  - Fixed unawaited fold() calls in WorkoutBloc
  - Resolved infinite loading screen after onboarding
  - Proper async state transitions in BLoC handlers

✅ **Session Management:** Complete workflow
  - Session creation and persistence
  - Set logging with immediate database writes
  - Session finalization with progression application
  - Session recovery after interruptions

✅ **Onboarding Completion:** End-to-end flow
  - Lift initialization in database
  - Cycle state creation for all 12 combinations (4 lifts × 3 tiers)
  - User preferences persistence
  - Smooth navigation to home after setup

✅ **Code Quality:** Production-ready codebase
  - Git repository initialized
  - Clean compilation (0 errors, 0 warnings)
  - All tests passing (39 tests)
  - Updated .gitignore for web artifacts

### Project Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── di/                 # Dependency injection
│   ├── error/              # Error handling
│   ├── usecases/           # Base use case classes
│   └── utils/              # Utility functions
├── features/
│   ├── workout/            # Workout logging feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── progression/        # Progression logic feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── onboarding/         # Onboarding flow
│   │   └── presentation/
│   └── settings/           # App settings
│       └── presentation/
└── main.dart               # App entry point
```

### Installed Dependencies

**Core:**
- `flutter_bloc: ^8.1.6` - State management
- `drift: ^2.20.3` - SQLite database ORM
- `drift_flutter: ^0.2.1` - Flutter integration for Drift
- `sqlite3: ^2.4.6` - Web platform support
- `sqlite3_flutter_libs: ^0.5.24` - Mobile platform support
- `get_it: ^8.0.2` - Dependency injection
- `dartz: ^0.10.1` - Functional programming (Either, Option)
- `equatable: ^2.0.5` - Value equality
- `shared_preferences: ^2.3.3` - Local key-value storage
- `path_provider: ^2.1.4` - File system paths
- `intl: ^0.19.0` - Internationalization and date formatting

**Development:**
- `build_runner: ^2.4.13` - Code generation
- `drift_dev: ^2.20.3` - Drift code generator
- `mockito: ^5.4.4` - Mocking for tests
- `bloc_test: ^9.1.7` - BLoC testing utilities
- `flutter_lints: ^5.0.0` - Linting rules

### Prerequisites Met

✓ Flutter SDK (stable channel v3.35.7)
✓ Dart SDK (v3.9.2)
✓ Build tools configured
✓ Git repository initialized
✓ All dependencies resolved

## Development Commands

```bash
# Run the app on web (fastest for development/testing)
flutter run -d chrome --web-port=8080

# Run the app on mobile emulator
flutter run -d <device-id>

# List available devices
flutter devices

# Run tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Build for web (development)
flutter build web

# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Check for issues
flutter analyze

# Format code
flutter format .

# Generate Drift/SQLite code
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch
```

### Testing Requirements (Linux)

For running database tests on Linux, the SQLite library must be available. If tests fail with `libsqlite3.so: cannot open shared object file`:

```bash
# Create symlink to SQLite library
mkdir -p ~/.local/lib
ln -sf /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 ~/.local/lib/libsqlite3.so

# Run tests with library path
LD_LIBRARY_PATH=~/.local/lib:$LD_LIBRARY_PATH flutter test
```

This setup is already configured and working. All 39 tests pass successfully.

## Key Implementation Considerations

### Weight Precision

All internal calculations must use high-precision floating-point numbers to handle fractional plates (2.5kg, 5lb). Rounding should only occur at the display layer based on user's unit preference (Imperial/Metric).

### AMRAP Guidance

The UI must provide contextual guidance for AMRAP sets, reminding users to stop 1-2 reps short of failure (RIR 1-2) to ensure sustainable progression. Track actual_reps achieved for post-session volume analysis.

### Session Finalization Flow

When a workout session is finalized:
1. Calculate success/failure for each tier based on completed reps vs. target reps
2. Update CycleState for all affected lifts (T1, T2, T3)
3. Store historical anchors (especially T2 last_stage1_success_weight)
4. Calculate next_target_weight for each lift
5. Advance or reset stages as required
6. Commit all changes atomically to prevent data corruption

### Data Recovery

Implement robust recovery for interrupted sessions:
- Auto-save in-progress workouts
- Restore state after crashes or calls
- Maintain timer state across app lifecycle events
- Test rigorously against iOS/Android power management

## Functional Specification Reference

The complete functional specification is in `FUNCTIONAL_SPECIFICATION.md`. Key sections:
- Section 3: GZCLP Core Logic Specification (progression algorithms)
- Section 4: Functional Requirements
- Section 5: Non-Functional Requirements (performance: <3s launch, <0.5s logging, offline-first)
- Section 6: Data Model Specification (database schema)

## Future Roadmap

**Phase 2 (Post-MVP):** Cloud synchronization service (Firebase or Supabase) for:
- Data backup
- Multi-device sync
- Protection against device loss

**Current Priority:** Local persistence must be rock-solid before considering cloud features.
