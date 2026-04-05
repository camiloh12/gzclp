# UX Refactor: Week/Cycle Flow

**Date:** 2026-04-05
**Branch:** `feature/ux-refactor`
**Status:** Approved

## Overview

Refactor the app's UX to surface the existing 12-rotation cycle model as a meaningful week/cycle concept. Replace the onboarding flow with a cycle creation flow, rename workout days from letters to numbers, and add a new cycle screen for end-of-cycle transitions.

The GZCLP progression logic (T1/T2/T3 stage advancement, success/failure rules) is unchanged.

---

## Section 1: Data Layer

### DB Migration (schema version bump)

**`WorkoutSessions.dayType`** — migrate stored values:
- 'A' → '1'
- 'B' → '2'
- 'C' → '3'
- 'D' → '4'

**`AccessoryExercises.dayType`** — same migration as above.

**`WorkoutSessions.rotationPosition`** — drop this column. It stored A=1, B=2, C=3, D=4 as an integer, which is now identical to `dayType` cast to int. Removing it eliminates the redundancy.

### Code changes in data layer

- All DAO methods that filter or reference `dayType` updated to use `'1'`/`'2'`/`'3'`/`'4'`
- Lift-to-day assignment map updated:
  - Day `'1'`: T1=Squat, T2=OHP
  - Day `'2'`: T1=Bench Press, T2=Deadlift
  - Day `'3'`: T1=Bench Press, T2=Squat
  - Day `'4'`: T1=Deadlift, T2=OHP

---

## Section 2: Cycle Logic

### Week number

`currentWeek = completedRotations + 1` while the cycle is active. Derived on the fly — no new table or column required.

### New session `rotationNumber` assignment

When a new session is created, it is assigned `rotationNumber = completedRotations + 1`. This is the current in-progress week.

### Week completion detection

A rotation N is complete when the DB contains 4 finalized sessions (`isFinalized = true`) with `rotationNumber = N` for the active cycle. Checked as a derived query after each session finalization.

### Incrementing `completedRotations`

Hooked into the existing `FinalizeWorkoutSession` use case. After applying progression, check if all 4 days of the current `rotationNumber` are finalized. If yes, increment `completedRotations` on the active cycle.

### End-of-cycle detection

When `completedRotations >= 12`, the home screen replaces "Start Workout" with "Start New Cycle". No regular workouts can be started until a new cycle is created.

### `StartNewCycle` use case — updated

Accepts a `NewCycleWeightOption` parameter:

- **`keepWeights`** — uses each lift's `nextTargetWeight` from the last cycle's CycleStates as-is
- **`customWeights(Map<liftId, double>)`** — uses user-supplied weights per lift

Both paths:
- Always reset all T1/T2/T3 stages to Stage 1
- Clear `lastStage1SuccessWeight` (T2 anchor reset)
- Reset `currentT3AmrapVolume` to 0

### Cycle 1 creation replaces onboarding

The splash screen check changes from `hasCompletedOnboarding` (SharedPreferences flag) to "does an active cycle exist?" (DB query). If no active cycle exists, the cycle creation flow is shown. The `OnboardingBloc` and onboarding pages are repurposed as the cycle creation flow.

---

## Section 3: UI/UX

### Cycle creation flow (was: onboarding)

Three steps, same as current onboarding but reframed as cycle creation:

1. **Welcome + unit selection** — unchanged content, reframed copy
2. **Set starting weights** — "Set your starting weights for Cycle 1" — per-lift weight inputs, same calculation logic as current onboarding step 3
3. On confirm: creates Cycle 1, initializes lifts and CycleStates, navigates to home

### Home screen

- Remove the stale "Phase 3: UI Implementation" placeholder text
- Add header: "Cycle 1 • Week 3 of 12"
- Add weekly day status row: "Day 1 ✓  Day 2 ✓  Day 3 —  Day 4 —"
- "Start Workout" button unchanged
- When `completedRotations >= 12`: replace "Start Workout" with "Start New Cycle" button

### Day picker (`StartWorkoutPage`)

- Page title changes to "Week 3 of 12"
- Day cards renamed: "Day 1", "Day 2", "Day 3", "Day 4"
- Days already completed this week show a checkmark badge
- Days remain tappable regardless (user may do days out of order)
- Lift display per card unchanged (just renumbered)

### Active workout page

- AppBar title changes from "Day B Workout" to "Week 3 • Day 2"

### New cycle screen

Shown when user taps "Start New Cycle" from the home screen.

- Summary header: "Cycle N complete — 12 weeks, X workouts"
- Two options:
  - **Keep weights** — one tap, proceeds immediately
  - **Adjust weights** — reveals per-lift weight inputs pre-filled with last cycle's `nextTargetWeight`; user edits then confirms
- On confirm: calls updated `StartNewCycle` use case, navigates to home

---

## What Is Not Changing

- GZCLP progression logic (T1/T2/T3 stage advancement, AMRAP rules, success/failure criteria)
- Rest timer
- Workout history page
- Settings page
- Dashboard page (cycle progress card already uses `completedRotations`)
- Database schema for `Cycles`, `CycleStates`, `Lifts`, `WorkoutSets`, `UserPreferences`
