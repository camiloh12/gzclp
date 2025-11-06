

# **FUNCTIONAL SPECIFICATION: GZCLP Mobile Workout Tracker (FSD V1.0)**

## **1\. Executive Summary**

This Functional Specification Document (FSD) defines the complete functional and non-functional requirements for the GZCLP Mobile Workout Tracker. The application is designed to be a dedicated, automated logbook for the GZCL Linear Progression (GZCLP) strength program, originally developed by Cody LeFever. The core objective of this project is to create a highly reliable, cross-platform mobile application that manages the complexity of GZCLP's tier-based structure, progression rules, stage cycles, and failure resets, eliminating the user's reliance on spreadsheets or manual calculations.[1]

The scope is strictly limited to GZCLP program automation, workout logging, and performance tracking. The application must achieve deployment compatibility on both Android and iOS environments, prioritizing local data persistence and seamless performance to support the user in a typical gym setting where connectivity may be intermittent or nonexistent.[2]

## **2\. Technical Architecture and Stack Recommendation**

### **2.1. Cross-Platform Framework Analysis and Selection**

The requirement for simultaneous deployment on Android and iOS necessitates the use of a robust cross-platform development framework.[4] Two primary candidates were evaluated: React Native and Flutter.

React Native (RN), utilizing JavaScript, benefits from a vast existing community and well-established libraries. However, RN's architecture typically relies on a bridge to communicate with native modules, which can introduce performance overhead, particularly in data-intensive or highly responsive applications like a real-time fitness tracker.[5]

Flutter, utilizing the Dart language, compiles directly to native ARM code, essentially bypassing the performance bottlenecks associated with a bridge layer.[5] This architectural advantage offers developers greater control over performance tuning and results in a smoother, near-native user experience. For an application that requires rapid logging, complex conditional logic execution, and uninterrupted background processing (such as the rest timer), Flutter's ability to render complex user interfaces quickly is critical.[5] Given the need for fast, reliable interaction in a fitness environment, **Flutter (Dart)** is the selected technology stack. This selection minimizes potential performance degradation often associated with cross-platform frameworks and adheres to modern development standards for creating high-performance, single-codebase applications.

### **2.2. Data Persistence Strategy**

Reliability is paramount for a workout logging application; users must be able to log entire sessions successfully, regardless of gym Wi-Fi access.[3] Therefore, the application is mandated to operate using a hybrid data model centered on robust local storage.[2]

**Core Data Persistence:** The complex, relational nature of GZCLP tracking—where individual sets must link back to a session, which must then update the conditional CycleState for future workouts—demands a structured database solution. SQLite, implemented via the Flutter-compatible Drift package, is recommended for managing all core data, including workout logs and the progression state. Drift provides the necessary relational strength, structured querying capabilities, and transactional integrity required to manage the nuanced progression logic safely offline.[7]

**Implication of Local Database Architecture:** The integrity of the GZCLP progression logic hinges on accurate historical data. The system's success depends on the local database's capacity to maintain the complex linkages between the WorkoutSession, the CycleState, and individual WorkoutSet logs. Any failure in transactional updates upon session finalization would corrupt the historical anchor points required for T1 and T2 resets, rendering the progression algorithm unstable. Consequently, the use of a relational database with strict schema adherence and atomic updates for session finalization is non-negotiable.[7] For minor, non-critical settings (e.g., UI preferences), simpler key-value storage like SharedPreferences will be utilized.[2]

### **2.3. External and Native Integrations**

The functional requirements dictate several interactions with the native OS to ensure a seamless experience:

1. **Rest Timer:** A critical feature is the rest timer, which must continue execution and provide timely cues even when the application is backgrounded or the screen is locked.[8] This requires leveraging platform-specific services (e.g., utilizing packages like background\_hiit\_timer or similar methodologies) configured through platform channels to ensure reliable execution on both Android and iOS.[8]
2. **Unit Support:** The system must support Imperial (lbs) and Metric (kg) units. All weight input fields, internal storage, and display outputs must automatically convert and round weights based on the user's initial preference.[1]
3. **Notifications:** Local notifications must be implemented to alert the user when the rest timer completes or for potential schedule reminders.

## **3\. GZCLP Core Logic Specification (The Progression Algorithm)**

The success of this application relies entirely on the accurate automation of Cody LeFever's GZCLP progression and deloading rules.[10] This section defines the specific conditional logic for Tiers 1, 2, and 3\.

### **3.1. GZCLP Tier and Stage Configuration**

The GZCLP program is structured around four core lifts (Squat, Bench Press, Deadlift, Overhead Press (OHP)) cycling through three tiers (T1, T2, T3).[10]

#### **Tier 1 (T1) \- Primary Compound Lift**

T1 lifts are focused on high intensity and low repetition volume per set, using a linear progression that attempts to maximize strength gain.[12] The final set of the T1 exercise is designated as an As Many Reps As Possible (AMRAP) set, although users are strongly advised to stop 1-2 reps shy of true muscular failure (Reps In Reserve, RIR).[10]

Tier 1 Stage Configuration

| Stage | Sets x Reps | Progression Focus | Rest Time |
| :---- | :---- | :---- | :---- |
| Stage 1 | 5 × 3+ | Strength Base | 3–5 min [10] |
| Stage 2 | 6 × 2+ | Strength Continuation | 3–5 min [10] |
| Stage 3 | 10 × 1+ | Intensity Peak | 3–5 min [10] |

#### **Tier 2 (T2) \- Secondary Compound Lift**

T2 lifts are secondary movements, typically the compound movement not featured as T1 that day. T2 focuses on medium intensity and volume.[11] The progression is similar to T1 but cycles through stages without the AMRAP requirement.[14]

Tier 2 Stage Configuration

| Stage | Sets x Reps | Progression Focus | Rest Time |
| :---- | :---- | :---- | :---- |
| Stage 1 | 3 × 10 | Hypertrophy / Volume Base | 2–3 min [10] |
| Stage 2 | 3 × 8 | Hypertrophy / Volume Consolidation | 2–3 min [10] |
| Stage 3 | 3 × 6 | Intensity Focus | 2–3 min [10] |

#### **Tier 3 (T3) \- Tertiary Accessory Lift**

T3 lifts are high-volume accessory movements designed to support the main lifts and address muscle imbalances. Only Stage 1 is used, and the progression is volume-dependent.[10]

Tier 3 Stage Configuration

| Stage | Sets x Reps | Progression Focus | Rest Time |
| :---- | :---- | :---- | :---- |
| Stage 1 | 3 × 15+ | Endurance / Volume Ceiling | 1–1.5 min [10] |

### **3.2. Program Structure and Schedule Logic**

The application must enforce the four-day rotating split (A, B, C, D).[10]

GZCLP Workout Schedule

| Day Type | Tier 1 (T1) | Tier 2 (T2) | Tier 3 (T3) |
| :---- | :---- | :---- | :---- |
| **A (Day 1\)** | Squat | Bench Press | Lat Pulldown / DB Row \+ 2-3 Accessories [10] |
| **B (Day 2\)** | Overhead Press (OHP) | Deadlift | Dumbbell Row / Lat Pulldown \+ 2-3 Accessories [10] |
| **C (Day 3\)** | Bench Press | Squat | Lat Pulldown / DB Row \+ 2-3 Accessories [10] |
| **D (Day 4\)** | Deadlift | Overhead Press (OHP) | Dumbbell Row / Lat Pulldown \+ 2-3 Accessories [10] |

**Scheduling Protocol:** The system determines the next workout sequentially (A → B → C → D → A).[10] A mandatory rest period (defaulting to 24 hours, minimum 18 hours) must be enforced between the completion of one session and the start of the next to ensure adequate recovery.[10]

### **3.3. T1 Progression and Cycle Reset**

The T1 progression is conditional on set completion and requires specific weight increments or stage transitions upon failure.[10]

**Standard Progression:** Following any T1 session, if the user successfully completes the entire prescribed volume for the current stage (e.g., 5 × 3+ means 5 sets of 3 reps minimum), the system calculates the **Next Target Weight** using linear increments:

* Lower Body (Squat, Deadlift): Add 10 lbs or 5 kg.[10]
* Upper Body (Bench, OHP): Add 5 lbs or 2.5 kg.[10]

**Stage Transition (Failure):** If the user fails to complete the minimum required total repetitions for the T1 lift (i.e., fails to hit the required number of reps on any non-AMRAP set, or fails to hit the minimum reps on the AMRAP set), the weight is maintained, but the system transitions the lift to the next stage.[10]

* Stage 1 Failure → Stage 2 (6 × 2+).
* Stage 2 Failure → Stage 3 (10 × 1+).

**Cycle Reset Protocol (T1 Deload):** When failure occurs at Stage 3 (10 × 1+), the progression cycle for that lift is deemed exhausted. The program does not use a fixed 10% deload but rather cycles back to Stage 1 with a new, accurately calculated starting weight.[11]

1. **Official Method:** The system must prompt the user to test for a new 5 Repetition Maximum (5RM) for that specific lift.[10] The new starting weight for Stage 1 (5 × 3+) will be **85% of the newly tested 5RM**.[10]
2. **Simplified Method:** As an alternative, the system may offer to calculate the new starting weight as 85% of the last successfully completed weight in the Stage 3 (10 × 1+) scheme.[15] However, the 5RM test remains the recommended protocol for accurately establishing a fresh training max.

### **3.4. T2 Progression and Cycle Reset**

T2 lifts follow a similar staged progression, dictated by set completion.[14]

**Standard Progression:** If the user successfully completes all prescribed sets and reps (e.g., 3 × 10), the system applies the base linear increment (10 lbs/5 kg for lower body, 5 lbs/2.5 kg for upper body) to the next target weight.[14]

**Stage Transition (Failure):** If the user fails to complete the total required repetitions for the T2 lift, the system transitions the lift to the next stage, keeping the weight constant.[14]

* Stage 1 Failure → Stage 2 (3 × 8).
* Stage 2 Failure → Stage 3 (3 × 6).

**Cycle Reset Protocol (T2 Deload):** When failure occurs at Stage 3 (3 × 6), the T2 cycle is reset to Stage 1 (3 × 10).[10] The new starting weight is calculated by recalling the weight used during the **last successful Stage 1 (3 × 10) session**, and adding a predefined buffer of **15–20 lbs or 7.5–10 kg** to that historical weight.[10] This process eliminates the guesswork of deloading by using a proven historical baseline rather than a simple percentage reduction.

The T2 reset requires a robust data field (last\_stage1\_success\_weight) that acts as a reliable "historical anchor." This data point must be meticulously recorded and stored in the CycleState upon the *successful completion* of any T2 Stage 1 session. If this specific historical reference is missing or corrupted, the T2 reset logic cannot function as intended, leading to an inaccurate or unsustainable progression.[10]

### **3.5. T3 Progression**

T3 progression is high-volume based, relying on performance in the final AMRAP set.[10]

**Progression Condition:** Weight should only be increased if the user achieves a volume ceiling of **25 or more actual repetitions** during the final AMRAP set of the 3 × 15+ scheme.[10] If 25+ reps are achieved, a small, fixed increment (recommended: 5 lbs or 2.5 kg) is applied for the next session.

**Maintenance:** If the user fails to reach the 25-rep threshold, the weight must remain the same for the next workout.[10]

**AMRAP Effort Calibration:** For both T1 and T3 AMRAP sets, the logging interface must integrate user guidance on effort level. The GZCL method emphasizes performing AMRAP sets with 1-2 Reps In Reserve (RIR 9 or 8 on the RPE/RIR scale) to prevent excessive fatigue and ensure sustainable progression, rather than pushing to absolute muscular failure (RIR 0).[10] The system must explicitly track the actual\_reps achieved on these sets to allow for post-session analysis of volume capacity.

## **4\. Functional Requirements (FR)**

### **4.1. User Onboarding and Initial Setup**

The application must guide the user through the essential setup steps required to begin the GZCLP program.

1. **FR 4.1.1 Unit Selection:** The user must explicitly choose either Imperial (lbs) or Metric (kg) units. This selection drives all subsequent weight displays and calculations.[1]
2. **FR 4.1.2 Initial Max Input:** The application requires the user to input their estimated 5RM for the four core lifts: Squat, Bench Press, Deadlift, and OHP. The system should provide an integrated calculator to assist users who may only know their 1RM.[14]
3. **FR 4.1.3 Initial Weight Calculation:** The system automatically establishes the starting T1 weight for all four lifts by calculating 85% of the provided 5RM.[14]
4. **FR 4.1.4 T3 Accessory Selection:** The user must select the accessory exercises for each of the four workout days (A, B, C, D). The system must provide a list of recommended accessories (e.g., Lat Pulldowns, DB Rows, Triceps Pushdowns, Curls).[10] The accessory count should be customizable, typically 3 or more lifts per day.[10]

### **4.2. Workout Session Management**

The workout interface must be intuitive, minimizing the cognitive load on the user during the session.[1]

1. **FR 4.2.1 Workout Generation:** The application automatically generates the workout for the day (A, B, C, or D), determining the T1 and T2 assignments based on the progression rules and the previous session's state.[10]
2. **FR 4.2.2 Set Target Display:** For every scheduled set, the interface must clearly display the Target Weight and Target Reps (e.g., 3 × 10 at 225 lbs).
3. **FR 4.2.3 In-Session Logging:** Users must be able to log the *Actual Reps* and *Actual Weight* used for each set immediately after completion. The input weight fields should default to the calculated Target Weight to expedite logging.
4. **FR 4.2.4 AMRAP Flagging and Guidance:** T1 and T3 sets designated as AMRAP must be clearly marked (+). Upon logging the AMRAP set, the application should display context-sensitive guidance reminding the user to stop 1-2 reps short of failure (RIR 1-2).[10]
5. **FR 4.2.5 Workout Review and Finalization:** Upon logging the final set, the user enters a review screen. Once finalized, the application must immediately execute the T1, T2, and T3 progression algorithms (Sections 3.3, 3.4, 3.5) and update the CycleState database table atomically to prevent data corruption.
6. **FR 4.2.6 Exercise Notes:** Functionality to add specific notes for any set or a general note for the entire workout session is required for tracking subjective feedback.[1]

### **4.3. Rest Timer Implementation (Critical Feature)**

The rest timer functionality must be highly reliable, running seamlessly in the background.

1. **FR 4.3.1 Auto-Start Timer:** The rest timer automatically initiates upon the completion and logging of any set. The duration must default to the Tier-specific rest time (T1: 3-5 min, T2: 2-3 min, T3: 1-1.5 min).[10]
2. **FR 4.3.2 In-App Display:** The timer must maintain a persistent, visible countdown display on the active workout screen.
3. **FR 4.3.3 Background Operation:** The timer must utilize native services to continue running and tracking time when the app is minimized, the device screen is locked, or the user navigates to other applications. Auditory and/or vibratory cues must be delivered via local notifications upon timer completion.[8]
4. **FR 4.3.4 Timer Customization:** Users must be able to adjust the default rest duration for each tier and possess the ability to pause, skip, or reset the current timer countdown.[1]

### **4.4. History and Analytics**

The application must provide comprehensive tools for monitoring long-term progress.[1]

1. **FR 4.4.1 Workout History Log:** A clear, chronological list of all past WorkoutSessions, including date, day type, and key performance indicators.
2. **FR 4.4.2 Lift Progression Chart:** Graphical representations for each core lift, detailing the weight progression path over time, clearly marking points of stage transition and cycle resets.
3. **FR 4.4.3 Performance Metrics:** Display of core statistics, including total session volume (weight × reps) and the maximum reps achieved during T1 and T3 AMRAP sets across the user's history.
4. **FR 4.4.4 Lift Status Display:** A dedicated dashboard element that immediately communicates the current status of each core lift, including the current tier, progression stage, current working weight, and the calculated next target weight.

## **5\. Non-Functional Requirements (NFR)**

### **5.1. Performance and Responsiveness**

The application must deliver a smooth and quick user experience to avoid disruption during training sessions.[19]

1. **NFR 5.1.1 Launch Time:** The application must initiate and render the main dashboard within 3 seconds on all supported target devices.[19]
2. **NFR 5.1.2 Logging Latency:** The action of submitting a completed set and writing the data to the local database must complete in less than 0.5 seconds to support high-frequency logging.
3. **NFR 5.1.3 Progression Calculation Speed:** The complex set of algorithmic calculations required to update the CycleState upon workout finalization must execute in less than 1.0 second.

### **5.2. Reliability and Availability**

1. **NFR 5.2.1 Offline Availability:** The core functionality, including workout generation, logging, progression calculation, and rest timer operation, must be fully functional without dependence on an internet connection.[2]
2. **NFR 5.2.2 Data Persistence during Interruption:** Any active workout session must be automatically saved and restorable in case of device interruption, application crash, or backgrounding due to an incoming call. The critical nature of the background timer (FR 4.3.3) and the in-progress state management (NFR 5.2.2) necessitates rigorous Quality Assurance (QA) testing on platform-specific native plugins to guarantee continuity against iOS/Android power management and memory cleanup protocols.[3]
3. **NFR 5.2.3 Availability:** The system is required to maintain 24/7 availability for logging workouts, minimizing any potential idle time.[3]

### **5.3. Security and Maintainability**

1. **NFR 5.3.1 Data Security:** All locally stored user data, including personal preferences and lift history, must be secured via standard OS sandbox permissions.[1]
2. **NFR 5.3.2 Code Maintainability:** The application code must utilize established Flutter state management patterns (e.g., BLoC or Provider) to ensure the logic remains modular, scalable, and easy to maintain during future updates or database schema migrations.[7]
3. **NFR 5.3.3 Unit Precision:** To guarantee the accuracy of progression, especially when dealing with half-step increments (2.5 kg or 5 lb plates), all internal weight calculations and storage must utilize high-precision floating-point numbers. Rounding should only occur at the display layer, based on the user's unit preference.

## **6\. Data Model Specification**

The local data model is the core component that manages the state of the GZCLP program. The structure below defines the critical entities, ensuring robust relational integrity for progression calculations.

### **6.1. Core Data Entities and Schema**

Table 6.1.3: Progression State (CycleState)

| Field Name | Data Type | Notes |
| :---- | :---- | :---- |
| cycle\_state\_id | PK (Integer) | Unique state ID. |
| lift\_id | FK (Integer) | Links to the specific lift. |
| current\_tier | String ('T1', 'T2', 'T3') | The current tier assignment. |
| current\_stage | Integer (1, 2, or 3\) | The current progression stage (5 × 3+, 3 × 10, etc.).[10] |
| next\_target\_weight | Numeric | The calculated weight for the *next* workout session. |
| last\_stage1\_success\_weight | Numeric | **T2 Anchor:** Weight used during the LAST successful T2 Stage 1 (3 × 10) session (used for T2 reset calculation).[10] |
| current\_t3\_amrap\_volume | Integer | Running total of achieved reps on T3 AMRAPs since last weight increase. |

Table 6.1.5: Detailed Set Log (WorkoutSet)

| Field Name | Data Type | Notes |
| :---- | :---- | :---- |
| set\_id | PK (Integer) | Unique set ID. |
| session\_id | FK (Integer) | Links to the workout session. |
| lift\_id | FK (Integer) | Links to the specific lift performed. |
| set\_number | Integer | Sequence number within the lift. |
| target\_reps | Integer | Reps programmed for this set. |
| actual\_reps | Integer | **User Input:** Actual reps completed (critical for T1/T3 AMRAP logging). |
| target\_weight | Numeric | Weight programmed for this set. |
| actual\_weight | Numeric | **User Input:** Actual weight used. |
| is\_amrap | Boolean | Flag if this set was intended as an AMRAP set. |

## **7\. Conclusions and Future Roadmap**

The primary mandate of this FSD—automating the GZCLP program across Android and iOS—is best achieved by coupling the high-performance Flutter framework with a robust local relational database like SQLite via Drift. This technical foundation addresses the critical non-functional requirement of full offline reliability, ensuring the application remains functional even in environments with poor network access.[2]

The successful implementation relies heavily on precisely codifying the conditional logic, particularly the distinct and complex reset protocols for T1 and T2 lifts. The requirement for the T2 reset protocol to reference the "last successful Stage 1 weight" (Section 3.4) mandates careful design of the CycleState data entity to maintain this crucial historical reference point.

While the current specification focuses on local persistence, a mandatory future development phase must integrate a cloud synchronization service (e.g., Firebase or Supabase).[2] This will address the long-term risk associated with storing critical progression history only on the local device, providing necessary data backup and allowing for multi-device synchronization. Furthermore, adherence to explicit application store requirements regarding data privacy and security (including encrypting data in transit, where applicable) must be verified during deployment.[1] The technical design outlined in this document provides a secure, reliable, and highly functional blueprint for the immediate development of the GZCLP Mobile Workout Tracker.

#### **Works cited**

1. GZCL Workout Logger \- Apps on Google Play, accessed October 30, 2025, [https://play.google.com/store/apps/details?id=co.braindead.gzcl\&hl=en\_US](https://play.google.com/store/apps/details?id=co.braindead.gzcl&hl=en_US)  
2. Data Persistence in Dart/Flutter: Choosing the Right Tool for the Job \- Medium, accessed October 30, 2025, [https://medium.com/@mahmoud-saeed/data-persistence-in-dart-flutter-choosing-the-right-tool-for-the-job-6d65536c53cb](https://medium.com/@mahmoud-saeed/data-persistence-in-dart-flutter-choosing-the-right-tool-for-the-job-6d65536c53cb)  
3. Functional and Non-Functional Requirements for Mobile App \- Lvivity, accessed October 30, 2025, [https://lvivity.com/functional-and-non-functional-requirements](https://lvivity.com/functional-and-non-functional-requirements)  
4. Multi-platform fitness apps – Engineering for Android, iOS, and wearables \- Touchlane, accessed October 30, 2025, [https://touchlane.com/multi-platform-fitness-apps-engineering-for-android-ios-and-wearables/](https://touchlane.com/multi-platform-fitness-apps-engineering-for-android-ios-and-wearables/)  
5. React Native vs Flutter: What to Choose in 2025 | BrowserStack, accessed October 30, 2025, [https://www.browserstack.com/guide/flutter-vs-react-native](https://www.browserstack.com/guide/flutter-vs-react-native)  
6. Flutter vs. React Native in 2025 — Detailed Analysis \- Nomtek, accessed October 30, 2025, [https://www.nomtek.com/blog/flutter-vs-react-native](https://www.nomtek.com/blog/flutter-vs-react-native)  
7. Flutter Database Guide | Choose the Right Fit for Your App \- Kody Technolab, accessed October 30, 2025, [https://kodytechnolab.com/blog/how-to-choose-right-database-for-flutter/](https://kodytechnolab.com/blog/how-to-choose-right-database-for-flutter/)  
8. background\_hiit\_timer | Flutter package \- Pub.dev, accessed October 30, 2025, [https://pub.dev/packages/background\_hiit\_timer](https://pub.dev/packages/background_hiit_timer)  
9. Flutter simple background timer example \- Stack Overflow, accessed October 30, 2025, [https://stackoverflow.com/questions/59523225/flutter-simple-background-timer-example](https://stackoverflow.com/questions/59523225/flutter-simple-background-timer-example)  
10. GZCLP \- The Fitness Wiki, accessed October 30, 2025, [https://thefitness.wiki/routines/gzclp/](https://thefitness.wiki/routines/gzclp/)  
11. Here's a quick summary of the GZCLP linear progression for novice lifters (infographic) : r/Fitness \- Reddit, accessed October 30, 2025, [https://www.reddit.com/r/Fitness/comments/6pjiwd/heres\_a\_quick\_summary\_of\_the\_gzclp\_linear/](https://www.reddit.com/r/Fitness/comments/6pjiwd/heres_a_quick_summary_of_the_gzclp_linear/)  
12. GZCLP: A 5-Minute Explainer \+ Infographic For New Lifters \- Say No To Broscience, accessed October 30, 2025, [https://www.saynotobroscience.com/gzclp-infographic/](https://www.saynotobroscience.com/gzclp-infographic/)  
13. For GZCLP what constitutes failure? : r/gzcl \- Reddit, accessed October 30, 2025, [https://www.reddit.com/r/gzcl/comments/1ccrn83/for\_gzclp\_what\_constitutes\_failure/](https://www.reddit.com/r/gzcl/comments/1ccrn83/for_gzclp_what_constitutes_failure/)  
14. GZCLP program explained \- Liftosaur, accessed October 30, 2025, [https://www.liftosaur.com/programs/gzclp](https://www.liftosaur.com/programs/gzclp)  
15. How are you resetting your T1s on GZCLP? : r/gzcl \- Reddit, accessed October 30, 2025, [https://www.reddit.com/r/gzcl/comments/9yqdne/how\_are\_you\_resetting\_your\_t1s\_on\_gzclp/](https://www.reddit.com/r/gzcl/comments/9yqdne/how_are_you_resetting_your_t1s_on_gzclp/)  
16. A Guide To Using RPE In Your Training \- Ripped Body, accessed October 30, 2025, [https://rippedbody.com/rpe/](https://rippedbody.com/rpe/)  
17. What GZCLP T3 (and T2?) exercises to add? : r/gzcl \- Reddit, accessed October 30, 2025, [https://www.reddit.com/r/gzcl/comments/52sepe/what\_gzclp\_t3\_and\_t2\_exercises\_to\_add/](https://www.reddit.com/r/gzcl/comments/52sepe/what_gzclp_t3_and_t2_exercises_to_add/)  
18. Progressions schemes, and exercise selection : r/gzcl \- Reddit, accessed October 30, 2025, [https://www.reddit.com/r/gzcl/comments/10ha2sx/progressions\_schemes\_and\_exercise\_selection/](https://www.reddit.com/r/gzcl/comments/10ha2sx/progressions_schemes_and_exercise_selection/)  
19. Functional vs Non-Functional Requirements: Understanding the Core Differences and Examples \- Ironhack, accessed October 30, 2025, [https://www.ironhack.com/us/blog/functional-vs-non-functional-requirements-understanding-the-core-differences-and](https://www.ironhack.com/us/blog/functional-vs-non-functional-requirements-understanding-the-core-differences-and)  
20. GZCL Method Workout Logger 4+ \- App Store, accessed October 30, 2025, [https://apps.apple.com/us/app/gzcl-method-workout-logger/id1517032809](https://apps.apple.com/us/app/gzcl-method-workout-logger/id1517032809)