# GZCLP App Development Plan

## Overview

This document outlines the phased development approach for building the GZCLP Workout Tracker (Android/iOS/Web) from initial setup through production release. The plan prioritizes core functionality for MVP while ensuring the complex progression logic is solid before building UI layers.

**Development Strategy:** Mobile-first with web support for rapid development and testing. Web deployment enables faster iteration cycles during development while maintaining focus on native mobile performance.

## Development Philosophy

1. **Database-First**: Get the schema and data integrity right before building UI
2. **Logic-First**: Implement and thoroughly test progression algorithms before integration
3. **Offline-First**: Every feature must work without internet connectivity
4. **Test-Driven**: Critical progression logic requires comprehensive unit tests
5. **Incremental**: Each phase builds on previous phases and delivers testable functionality
6. **Web-Enabled**: Use web platform for faster development/testing while targeting mobile for production

---

## Phase 0: Project Foundation (Week 1)

### Objectives
Establish the Flutter project structure and development environment.

### Tasks
- [ ] Initialize Flutter project with appropriate package name
- [ ] Set up project structure (features/presentation/data/domain layers)
- [ ] Configure Drift for SQLite
  - Add dependencies: `drift`, `drift_flutter`, `build_runner`
  - Set up build configuration
- [ ] Choose and configure state management (Recommendation: BLoC for complex logic)
  - Add `flutter_bloc` dependency
  - Set up repository pattern
- [ ] Create basic app shell with navigation
- [ ] Set up unit testing framework
- [ ] Configure CI/CD pipeline (optional but recommended)

### Deliverables
- Runnable Flutter app with empty screens
- Database configuration ready
- State management scaffolding in place

### Testing
- Verify app builds and runs on web (Chrome), Android, and iOS platforms
- Confirm Drift code generation works

---

## Phase 1: Database Schema & Models (Week 1-2)

### Objectives
Create the complete data layer that will support all GZCLP functionality. This is the foundation for everything else.

### Tasks

#### 1.1 Define Drift Tables

**Lifts Table**
```dart
- lift_id (PK)
- name (String: "Squat", "Bench Press", "Deadlift", "Overhead Press")
- category (String: "lower" or "upper" - determines weight increment)
```

**CycleState Table** (CRITICAL)
```dart
- cycle_state_id (PK)
- lift_id (FK)
- current_tier (String: 'T1', 'T2', 'T3')
- current_stage (Int: 1, 2, or 3)
- next_target_weight (Real)
- last_stage1_success_weight (Real) // CRITICAL for T2 resets
- current_t3_amrap_volume (Int) // For T3 progression tracking
- last_updated (DateTime)
```

**WorkoutSession Table**
```dart
- session_id (PK)
- day_type (String: 'A', 'B', 'C', 'D')
- date_started (DateTime)
- date_completed (DateTime, nullable)
- is_finalized (Bool) // Critical flag
- session_notes (String, nullable)
```

**WorkoutSet Table**
```dart
- set_id (PK)
- session_id (FK)
- lift_id (FK)
- tier (String: 'T1', 'T2', 'T3')
- set_number (Int)
- target_reps (Int)
- actual_reps (Int, nullable)
- target_weight (Real)
- actual_weight (Real, nullable)
- is_amrap (Bool)
- set_notes (String, nullable)
```

**UserPreferences Table**
```dart
- preference_id (PK)
- unit_system (String: 'imperial' or 'metric')
- t1_rest_seconds (Int, default: 240)
- t2_rest_seconds (Int, default: 150)
- t3_rest_seconds (Int, default: 75)
- minimum_rest_hours (Int, default: 24)
- has_completed_onboarding (Bool)
```

**AccessoryExercise Table**
```dart
- exercise_id (PK)
- name (String)
- day_type (String: 'A', 'B', 'C', 'D')
- order_index (Int)
```

#### 1.2 Create DAOs (Data Access Objects)
- CycleStateDAO with methods for get/update by lift
- WorkoutSessionDAO with CRUD operations
- WorkoutSetDAO with batch insert capabilities
- UserPreferencesDAO for settings

#### 1.3 Write Unit Tests
- Test database creation
- Test foreign key constraints
- Test CRUD operations for each table
- Test transaction rollback on errors

### Deliverables
- Complete Drift schema definitions
- Generated Drift code (run `dart run build_runner build`)
- DAOs with basic CRUD operations
- Unit tests with >80% coverage

### Testing
- Database initialization succeeds
- Can insert/retrieve data for all tables
- Foreign key relationships work correctly
- Transactions maintain data integrity

### Critical Considerations
- **Data Integrity**: Use transactions for multi-table updates
- **Precision**: Use REAL type for weights (not INTEGER) to handle fractional plates
- **Historical Anchor**: `last_stage1_success_weight` must be updated atomically with session finalization

---

## Phase 2: Core Progression Logic (Week 2-3)

### Objectives
Implement the GZCLP progression algorithms with comprehensive testing. This is the most complex and critical part of the system.

### Tasks

#### 2.1 Create Progression Service Classes

**ProgressionCalculator** (base class or utility)
- Method: `calculateWeightIncrement(liftCategory: String, unitSystem: String): double`
  - Lower body: 10 lbs / 5 kg
  - Upper body: 5 lbs / 2.5 kg

**T1ProgressionService**
- Method: `evaluateT1Completion(sets: List<WorkoutSet>, currentStage: int): T1Result`
  - Input: All T1 sets for a lift
  - Logic: Check if minimum reps achieved on all sets
  - Output: success/failure + next stage/weight
- Method: `calculateT1Reset(currentWeight: double, optional new5RM: double): double`
  - Returns 85% of 5RM or 85% of Stage 3 success weight
- Method: `getT1StageConfig(stage: int): StageConfig`
  - Returns sets/reps for stage (5x3+, 6x2+, 10x1+)

**T2ProgressionService**
- Method: `evaluateT2Completion(sets: List<WorkoutSet>, currentStage: int): T2Result`
- Method: `calculateT2Reset(lastStage1Weight: double, unitSystem: String): double`
  - CRITICAL: Requires `lastStage1Weight` parameter
  - Returns lastStage1Weight + 15-20 lbs / 7.5-10 kg
- Method: `getT2StageConfig(stage: int): StageConfig`
  - Returns sets/reps for stage (3x10, 3x8, 3x6)

**T3ProgressionService**
- Method: `evaluateT3Completion(amrapSet: WorkoutSet, currentWeight: double): T3Result`
- Logic: Increase weight only if amrapSet.actual_reps >= 25
- Method: `getT3StageConfig(): StageConfig`
  - Returns 3x15+

**SessionFinalizationService** (orchestrates all progression logic)
- Method: `finalizeSession(sessionId: int): Future<void>`
  - Retrieves all sets for the session
  - Groups sets by lift and tier
  - Calls appropriate progression service for each tier
  - Updates CycleState for all affected lifts
  - Updates session.is_finalized = true
  - **All updates in single transaction**

#### 2.2 Comprehensive Unit Testing

Create test cases for **every scenario**:

**T1 Tests**
- ✓ Success at Stage 1 → weight increases
- ✓ Failure at Stage 1 → advance to Stage 2, maintain weight
- ✓ Success at Stage 2 → weight increases
- ✓ Failure at Stage 2 → advance to Stage 3, maintain weight
- ✓ Success at Stage 3 → weight increases
- ✓ Failure at Stage 3 → reset to Stage 1 with deload
- ✓ AMRAP set with different rep counts
- ✓ Lower body vs upper body increment differences
- ✓ Imperial vs metric unit handling

**T2 Tests**
- ✓ Success at Stage 1 → weight increases AND last_stage1_success_weight updated
- ✓ Failure at Stage 1 → advance to Stage 2
- ✓ Success at Stage 2 → weight increases
- ✓ Failure at Stage 2 → advance to Stage 3
- ✓ Success at Stage 3 → weight increases
- ✓ Failure at Stage 3 → reset to Stage 1 using last_stage1_success_weight
- ✓ Error handling when last_stage1_success_weight is null/missing

**T3 Tests**
- ✓ AMRAP < 25 reps → weight maintained
- ✓ AMRAP >= 25 reps → weight increases
- ✓ T3 increment (5 lbs / 2.5 kg)

**Integration Tests**
- ✓ Complete session with T1, T2, T3 lifts
- ✓ Multiple lifts progress independently
- ✓ Transaction rollback on error
- ✓ CycleState correctly updated for all lifts

### Deliverables
- Progression service classes with complete logic
- 50+ unit tests covering all scenarios
- Integration tests for session finalization
- Documentation of progression logic

### Testing
- All unit tests pass
- Edge cases handled (missing data, invalid states)
- Transaction atomicity verified
- Performance: Session finalization < 1 second

### Critical Considerations
- **T2 Historical Anchor**: Must update `last_stage1_success_weight` on every T2 Stage 1 success
- **Atomicity**: Use database transactions to prevent partial state updates
- **Validation**: Verify data integrity before running progression logic

---

## Phase 3: MVP - Basic Workout Flow (Week 3-4)

### Objectives
Create the minimum viable product: a user can log a workout and see the progression work.

### Tasks

#### 3.1 Workout Generation Logic
- Service: `WorkoutGeneratorService`
  - Method: `getNextWorkoutDay(): String` ('A', 'B', 'C', 'D')
  - Logic: Looks at last finalized session, returns next in sequence
  - Checks minimum rest period (24 hours default)
- Method: `generateWorkout(dayType: String): WorkoutTemplate`
  - Returns list of lifts with tier assignments
  - Pulls next_target_weight from CycleState
  - Generates set templates based on current stage

#### 3.2 Workout Screen UI
- Display workout day (A, B, C, D)
- List of lifts grouped by tier (T1, T2, T3)
- For each lift:
  - Lift name
  - Current stage indicator (e.g., "Stage 1: 5x3+")
  - Target weight
- Expandable sections for each lift

#### 3.3 Set Logging Interface
- For each set:
  - Display: Set number, Target reps, Target weight
  - Input: Actual weight (pre-filled with target)
  - Input: Actual reps
  - Checkbox: "Set completed"
- Simple, fast input (number pads for weight/reps)
- Visual distinction for AMRAP sets (+)

#### 3.4 Session Finalization
- "Finish Workout" button
- Review screen showing all logged sets
- "Confirm & Save" triggers:
  - SessionFinalizationService.finalizeSession()
  - Success message with progression summary
  - Navigate to workout summary

#### 3.5 Basic Workout History
- List of past sessions (date, day type)
- Tap to view session details
- Show all sets logged for that session

### Deliverables
- Working workout flow: start → log → finalize
- Basic UI (functionality over aesthetics)
- Workout history view
- Integration between UI and progression logic

### Testing
- Manual testing: Complete full A/B/C/D cycle
- Verify progression logic triggers correctly
- Test success and failure scenarios
- Confirm CycleState updates after finalization

### MVP Definition
At the end of Phase 3, the app should:
- ✓ Generate workouts automatically
- ✓ Allow logging of sets with actual weight/reps
- ✓ Apply progression logic correctly
- ✓ Store workout history
- ✓ Function completely offline

---

## Phase 4: Rest Timer Implementation (Week 4-5)

### Objectives
Add the critical rest timer feature that works in background.

### Tasks

#### 4.1 Research & Setup
- Evaluate packages: `background_hiit_timer`, `flutter_background_service`, `workmanager`
- Set up platform-specific permissions (Android: WAKE_LOCK, iOS: background modes)
- Configure local notifications package

#### 4.2 Timer Service
- Service: `RestTimerService`
  - Start timer with duration (seconds)
  - Pause/resume timer
  - Cancel timer
  - Query remaining time
- Store timer state for recovery
- Background execution setup for Android/iOS

#### 4.3 UI Integration
- Persistent timer display on workout screen
- Visual countdown (minutes:seconds)
- Audio/haptic feedback at completion
- Local notification when timer completes
- Quick actions: +30s, -30s, skip, pause

#### 4.4 Auto-Start Logic
- After set is logged, auto-start timer
- Use tier-based defaults:
  - T1: 240 seconds (4 min)
  - T2: 150 seconds (2.5 min)
  - T3: 75 seconds (1.25 min)
- User can adjust before or during countdown

### Deliverables
- Working rest timer with background operation
- Local notifications on completion
- Timer persists across app backgrounding
- Timer customization settings

### Testing
- Background timer continues when app minimized
- Timer continues when screen locked
- Notification delivered on completion
- Test on both Android and iOS
- Test with phone calls interrupting timer

### Critical Considerations
- **Platform Differences**: iOS and Android handle background tasks differently
- **Battery Optimization**: Ensure timer survives aggressive battery savers
- **State Recovery**: Timer state must survive app termination

---

## Phase 5: Onboarding Flow (Week 5)

### Objectives
Create a smooth first-run experience to set up the user's program.

### Tasks

#### 5.1 Onboarding Screens
- Screen 1: Welcome + Program explanation
- Screen 2: Unit selection (Imperial / Metric)
  - Large, clear buttons
  - Store in UserPreferences
- Screen 3: 5RM Input
  - Input fields for 4 main lifts
  - Optional: 1RM to 5RM calculator
  - Validation: weights must be positive
- Screen 4: Calculate Starting Weights
  - Display: "Your starting weights (85% of 5RM)"
  - Show calculated T1 starting weights
  - Allow manual adjustment if needed
- Screen 5: T3 Accessory Selection
  - For each day (A, B, C, D)
  - Pre-populated suggestions
  - Ability to add custom exercises
  - Reorderable list

#### 5.2 Initial Database Population
- Create 4 Lift records (Squat, Bench, Deadlift, OHP)
- Create CycleState records for each lift:
  - T1: Stage 1, calculated starting weight
  - T2: Stage 1, calculated starting weight
  - T3: Stage 1, user-selected weight or default
- Mark has_completed_onboarding = true

#### 5.3 Onboarding Skip/Return
- Show onboarding only on first launch
- "Skip for now" option that creates defaults
- Ability to re-run onboarding from settings

### Deliverables
- Complete onboarding flow
- Database initialized with starting values
- Settings to modify units and weights later

### Testing
- Fresh install goes through onboarding
- All data correctly populated in database
- Units correctly applied throughout app
- Skip functionality works

---

## Phase 6: Enhanced UI/UX (Week 6)

### Objectives
Improve user experience with better visuals, guidance, and error handling.

### Tasks

#### 6.1 AMRAP Set Enhancements
- Visual indicator for AMRAP sets (distinct color/icon)
- When logging AMRAP set, show guidance dialog:
  - "This is an AMRAP set (As Many Reps As Possible)"
  - "Stop 1-2 reps before failure (RIR 1-2)"
  - "Focus on maintaining good form"
- Display previous AMRAP performance if available

#### 6.2 Notes & Annotations
- Add notes button for each set
- Session-level notes field
- Common quick-notes: "Easy", "Tough", "Failed rep X", "Form breakdown"
- Notes display in history view

#### 6.3 Visual Feedback & Animations
- Set completion animations
- Progress indicators
- Success/failure visual cues
- Celebration animation on workout completion
- Smooth transitions between screens

#### 6.4 Error Handling
- Graceful handling of database errors
- User-friendly error messages
- Retry mechanisms for failed operations
- Validation feedback (e.g., "Please log all sets before finishing")

#### 6.5 Responsive Design
- Support different screen sizes
- Landscape orientation support
- Tablet layouts
- Accessibility considerations

### Deliverables
- Polished UI with animations
- AMRAP guidance integrated
- Notes functionality working
- Error handling throughout app

### Testing
- Manual UI/UX testing
- Test on various device sizes
- Accessibility audit
- Error scenario testing

---

## Phase 7: History & Analytics (Week 6-7)

### Objectives
Provide users with detailed tracking and progress visualization.

### Tasks

#### 7.1 Enhanced Workout History
- List view with filtering:
  - By date range
  - By day type (A/B/C/D)
  - By lift
- Summary stats per session:
  - Total volume (weight × reps)
  - Session duration
  - Sets completed/total
- Search functionality

#### 7.2 Lift Progression Charts
- Line chart for each main lift showing weight over time
- Visual markers for:
  - Stage transitions (color changes)
  - Resets/deloads (annotations)
  - PRs (personal records)
- Zoom/pan functionality
- Toggle between lifts

#### 7.3 Performance Dashboard
- Current status for each lift:
  - Current tier & stage
  - Current working weight
  - Next target weight
  - Days since last workout
- Statistics:
  - Total workouts completed
  - Current streak
  - Max AMRAP reps by lift
  - Total volume lifted (all time)

#### 7.4 Exercise History by Lift
- Detailed view for each exercise
- Table view of all sets ever logged
- Filter by date, stage, success/failure
- Export data (CSV)

### Deliverables
- Comprehensive history views
- Graphical progress charts
- Performance dashboard
- Data export functionality

### Testing
- Test with various history lengths (0 workouts, 10, 100+)
- Chart rendering performance
- Data accuracy in analytics
- Export file format validation

---

## Phase 8: Production Readiness (Week 7-8)

### Objectives
Prepare the app for public release with polish, testing, and deployment setup.

### Tasks

#### 8.1 Comprehensive Testing
- **Unit Tests**: >80% code coverage
- **Integration Tests**: Critical user flows
- **Widget Tests**: All major screens
- **E2E Tests**: Complete workout cycles (A→B→C→D→A)
- **Platform Tests**: Both iOS and Android
- **Edge Cases**:
  - App interrupted during workout
  - Session recovery after crash
  - Database migration scenarios
  - Extremely long workout histories

#### 8.2 Performance Optimization
- Profile app performance
- Optimize database queries (add indexes)
- Lazy loading for long lists
- Image/asset optimization
- Reduce app bundle size
- Memory leak detection

#### 8.3 Crash Handling & Recovery
- Integrate crash reporting (Sentry, Firebase Crashlytics)
- Implement session recovery:
  - Detect incomplete session on app start
  - Offer to resume or discard
  - Restore timer state if active
- Graceful degradation for missing data

#### 8.4 Settings & Customization
- Settings screen:
  - Unit system
  - Default rest times per tier
  - Minimum rest between workouts
  - Notification preferences
  - Data management (backup/restore)
- About screen with version info

#### 8.5 Data Backup & Recovery
- Export full database to JSON
- Import database from backup
- Clear all data option (with confirmation)
- Data integrity validation on import

#### 8.6 App Store Preparation
- **Android (Google Play)**:
  - App signing setup
  - Store listing (description, screenshots, icon)
  - Privacy policy page
  - Content rating
- **iOS (App Store)**:
  - Apple Developer account setup
  - App Store listing
  - Privacy nutrition labels
  - TestFlight beta testing
- Screenshots for various device sizes
- App icon design (1024×1024)

#### 8.7 Documentation
- User guide / Help section in app
- FAQ
- Privacy policy
- Terms of service
- Developer documentation for maintenance

### Deliverables
- Production-ready app on both platforms
- Comprehensive test coverage
- Crash reporting configured
- App store listings submitted
- User documentation complete

### Testing
- Beta testing with real users
- Load testing with large datasets
- Battery usage analysis
- Network behavior verification (offline mode)
- Accessibility compliance check

---

## Post-Launch (Future Phases)

### Phase 9: Cloud Sync (Optional Enhancement)
- Set up Firebase or Supabase backend
- Implement authentication
- Sync CycleState, sessions, and sets to cloud
- Multi-device support
- Conflict resolution for offline edits
- Automatic backup

### Phase 10: Advanced Features
- Custom exercise library
- Video form guides
- Plate calculator (show which plates to load)
- Workout reminders/scheduling
- Training metrics (velocity, RPE tracking)
- Social features (optional)
- Integration with wearables

### Phase 11: Program Variations
- Support for other GZCL variants (VDIP, The Rippler, etc.)
- Custom program builder
- Periodization support
- Deload weeks

---

## Risk Management

### High-Risk Areas

1. **Background Timer Reliability**
   - Risk: Timer stops on iOS/Android battery optimization
   - Mitigation: Extensive testing on various devices, multiple backup notification mechanisms

2. **T2 Reset Logic Complexity**
   - Risk: Missing `last_stage1_success_weight` causes reset failure
   - Mitigation: Database constraints, validation before finalization, fallback logic

3. **Data Corruption**
   - Risk: Incomplete transaction during session finalization
   - Mitigation: Atomic transactions, database integrity checks, backup mechanism

4. **Cross-Platform Inconsistencies**
   - Risk: Different behavior on iOS vs Android
   - Mitigation: Platform-specific testing, abstraction layers, early multi-platform testing

### Mitigation Strategies
- Test progression logic exhaustively before UI integration
- Implement database transaction rollback on errors
- Add data validation at every entry point
- Create automated test suite for regression prevention
- Beta test with real users before public launch

---

## Success Criteria

### MVP Success (End of Phase 3)
- User can complete a full GZCLP cycle (A→B→C→D)
- Progression logic correctly updates weights and stages
- App functions completely offline
- No data loss during session

### Production Success (End of Phase 8)
- 99.9% crash-free rate
- Background timer works on 95%+ of devices
- Session finalization < 1 second
- App launch < 3 seconds
- Set logging < 0.5 seconds
- Positive user feedback on beta tests
- Successful app store submissions

---

## Timeline Estimate

- **Phase 0**: 1 week
- **Phase 1**: 1 week
- **Phase 2**: 1-2 weeks (most critical, don't rush)
- **Phase 3**: 1-2 weeks
- **Phase 4**: 1 week
- **Phase 5**: 1 week
- **Phase 6**: 1 week
- **Phase 7**: 1 week
- **Phase 8**: 1-2 weeks

**Total**: 8-12 weeks for production-ready MVP with analytics

This timeline assumes a single developer working full-time. Adjust based on:
- Team size
- Experience with Flutter
- Complexity of platform-specific features
- Testing thoroughness required

---

## Development Best Practices

1. **Commit Often**: Small, focused commits with clear messages
2. **Test First**: Write tests for progression logic before implementation
3. **Database Migrations**: Version all schema changes with migration scripts
4. **Code Reviews**: Even solo developers should review their own PRs
5. **Performance Monitoring**: Profile regularly, don't optimize prematurely
6. **User Feedback**: Beta test early and often
7. **Documentation**: Document complex logic (especially progression algorithms)

---

## Next Steps

1. Review this plan with stakeholders
2. Set up development environment (Phase 0)
3. Begin Phase 1: Database schema implementation
4. Establish testing framework and CI/CD
5. Regular check-ins to adjust timeline based on actual progress

**Remember**: The progression logic (Phase 2) is the heart of this application. Invest the time to get it right before building UI layers.
