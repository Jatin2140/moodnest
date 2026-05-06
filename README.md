# MoodNest 🌿

> **Your nest of calm** — a mental wellness Flutter app with mood tracking, guided meditations, breathing exercises, journaling, and a living Calm Garden that grows with your streaks.

---

## Screenshots

| Dashboard | Mood Check-in | Breathing Orb |
|-----------|--------------|---------------|
| *(run app → screenshot)* | *(run app → screenshot)* | *(run app → screenshot)* |

| Meditation Player | Insights + Garden | Journal Compose |
|-------------------|-------------------|-----------------|
| *(run app → screenshot)* | *(run app → screenshot)* | *(run app → screenshot)* |

---

## Features

### Core
- **Mood Tracking** — Daily check-in with 5 emoji moods, optional note, and tag chips (work, sleep, social, health…)
- **Guided Meditations** — 8 curated sessions grouped by intent (Sleep, Focus, Reset, Body Scan) with audio playback, scrub, and 15s skip
- **Breathing Exercises** — Box, 4-7-8, Coherent, and Energiser patterns with an animated `CustomPainter` orb and haptic phase cues
- **Journaling** — Free-write or mood-filtered prompts; word count live; sorted timeline view
- **Firebase Auth** — Email/password + anonymous "Try it first" mode; password reset

### Extended
- **Mood-Aware Recommendations** — Custom weighted scoring engine picks top-3 sessions from the full catalog based on current mood, 7-day trend slope, time-of-day, recency, and tag variety (see §Custom Logic below)
- **Calm Garden** — `CustomPainter` flower garden: one flower per streak bucket, colour = dominant mood; animated sway; tap to see tooltip
- **Goals** — Create up to 5 weekly goals; progress auto-tracked from activity events; confetti celebration overlay on completion
- **Reminders** — CRUD local notifications with `flutter_local_notifications` and `timezone`; per-day-of-week scheduling
- **Insights** — 14-day mood trend `LineChart`, 7-day activity `BarChart`, auto-generated insight sentence, and Calm Garden full view
- **Offline-first** — Every write goes to Hive immediately; syncs to Firestore in background; offline banner from `ConnectivityProvider`
- **Dark mode** — Full `lightTheme` / `darkTheme` toggle stored in Firestore profile

---

## Architecture

```
UI Layer (features/, widgets/)
    │  Consumer / context.watch / context.read only
    ▼
Provider Layer (providers/)
    │  ChangeNotifier — holds UI state, calls repositories
    ▼
Logic Layer (logic/)
    │  Pure Dart — MoodRecommender, StreakCalculator, InsightEngine
    ▼
Data Layer (data/repositories/)
    │  Abstracts Firestore + Hive; returns Result<T, Failure>
    ▼
  Firestore (remote)   Hive (local cache)
```

**`MultiProvider` registration order in `app.dart`:**
1. `ConnectivityProvider` (global)
2. `AuthProvider` (global)
3. `MoodProvider`, `JournalProvider`, `GoalProvider`, `ReminderProvider`, `RecommendationProvider` (scoped — recreated when `AuthProvider.uid` changes via `ChangeNotifierProxyProvider`)

**`setState` policy:** Allowed only for transient widget-local UI (password visibility toggle, text controller listeners). All domain state lives in Provider.

---

## State Management — Why Provider

Provider was chosen over Bloc for this app's complexity level:
- Screen interactions are mostly read-heavy with occasional writes — no complex event streams
- `Selector` is used at fine-grained widgets (e.g. streak count) to avoid full rebuilds
- `ChangeNotifierProxyProvider` handles the dependency chain (MoodProvider needs `uid` from AuthProvider)
- The logic layer (recommender, streak, insights) is pure Dart and testable independently of Provider

---

## Custom Logic — Mood-Aware Recommender

**File:** `lib/logic/recommender/mood_recommender.dart`

For each content item in the catalog, a score is computed:

```
score =
  1.0 × moodFit[currentMood]          // baseline mood match (0–1)
+ 0.6 × trendAdjustment(last7Moods)   // negative slope → prefer low-intensity
+ 0.4 × timeOfDayMatch                // ideal time band hit → 1.0, miss → 0.0
- 0.5 × recencyPenalty                // played < 24h ago → scaled penalty
+ 0.3 × noveltyBonus                  // never played → +0.3
+ 0.2 × varietyBonus                  // tags not in recent history → higher bonus
```

`trendAdjustment` uses a **least-squares slope** over the last 7 mood valences (1–5). A negative slope (mood worsening) boosts calming items (intensity < 0.4) and penalises energising ones (intensity > 0.7).

Each recommendation also carries a `whyExplanation` string explaining the dominant scoring factor in plain language.

**Tests:** `test/unit/recommender_test.dart` — 5 cases covering each scoring term.

---

## Setup

### Prerequisites
- Flutter 3.22+ / Dart 3.4+
- Firebase project with **Authentication** (email/password + anonymous) and **Firestore** enabled

### Steps

```bash
# 1 – Clone and install dependencies
cd moodnest
flutter pub get

# 2 – Configure Firebase (first time only)
dart pub global activate flutterfire_cli
flutterfire configure   # follow prompts; selects your Firebase project

# 3 – Run on a connected device or emulator
flutter run

# 4 – Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

> **Note on audio:** Meditation audio uses bundled MP3 assets in `assets/audio/meditations/`. The placeholder files (`ambient_soft.mp3`, `ambient_deep.mp3`) need replacing with royalty-free tracks (e.g. from freesound.org) before shipping. See §Acknowledgements.

---

## Testing

```bash
# Unit tests (no device needed)
flutter test test/unit/

# Widget tests (no device needed)
flutter test test/widget/

# Integration test (requires running emulator/device)
flutter test integration_test/app_flow_test.dart
```

### Manual Test Matrix

| Scenario | Steps | Expected | Edge |
|---|---|---|---|
| **Happy path signup** | Open app → Sign up → complete onboarding | Land on Dashboard with greeting | — |
| **Mood log** | Tap + on Dashboard → pick mood → save | Mood card updates, streak increments | No mood → button disabled |
| **Offline mood log** | Toggle airplane → log mood | Saved locally; offline banner shown | — |
| **Reconnect sync** | Re-enable network | Hive queue flushes to Firestore | Duplicate ID guard |
| **Recommendation** | Log mood → Dashboard | 1–3 recommendation cards appear | No mood logged → fallback card |
| **Why chip** | Tap "Why this?" on rec card | Explanation expands | Toggle back hides it |
| **Breathing session** | Pick a pattern → Start → complete cycles | Done dialog; goal progress increments | Stop mid-session → resets |
| **Meditation ≥80%** | Play until 80% completion | Completion event recorded in Firestore | Audio not bundled → graceful fallback |
| **Journal prompt** | Compose → tap "Use a prompt" | Mood-filtered prompts load | Empty body → save disabled |
| **Goal completion** | Add goal → complete target sessions | Celebration overlay; flower in garden | 5 active goals → add button hidden |
| **Reminder fires** | Add 1-min-away reminder → background app | Notification received | No permission → request dialog |
| **Dark mode** | Profile → toggle dark mode | App theme switches immediately | Persisted to Firestore |

---

## Folder Structure

```
lib/
├── main.dart                    # Firebase, Hive, notifications bootstrap
├── app.dart                     # MaterialApp, MultiProvider, theme, router
├── core/
│   ├── theme/                   # AppColors, AppTypography, AppTheme, MoodGradient
│   ├── router/app_router.dart   # Named routes + custom transitions
│   ├── constants/app_strings.dart
│   └── utils/                   # Result<T>, DateX, StreakCalculator
├── data/
│   ├── models/                  # MoodEntry, JournalEntry, Goal, Reminder, UserProfile
│   ├── seed/                    # meditations.json, breathing_patterns.json, journal_prompts.json
│   └── repositories/            # AuthRepository, MoodRepository, JournalRepository, GoalRepository,
│                                #   ContentRepository, ReminderRepository
├── logic/
│   ├── recommender/             # MoodRecommender (scoring engine + explainer)
│   ├── streaks/                 # StreakCalculator (in date_x.dart)
│   └── insights/                # InsightEngine (trend analysis, insight sentences)
├── providers/                   # AuthProvider, MoodProvider, JournalProvider, GoalProvider,
│                                #   ReminderProvider, RecommendationProvider, ConnectivityProvider
├── features/
│   ├── auth/                    # LoginScreen, SignupScreen, AuthField
│   ├── onboarding/              # OnboardingScreen (3 pages + first mood capture)
│   ├── home/                    # HomeShell (bottom nav), DashboardScreen
│   ├── mood/                    # MoodCheckInScreen, MoodPicker (custom animated widget)
│   ├── meditation/              # MeditationListScreen, MeditationPlayerScreen
│   ├── breathing/               # BreathingListScreen, BreathingSessionScreen (CustomPainter orb)
│   ├── journal/                 # JournalListScreen, JournalComposeScreen, PromptCard
│   ├── goals/                   # GoalsScreen, GoalFormScreen
│   ├── insights/                # InsightsScreen, CalmGarden (CustomPainter)
│   ├── reminders/               # RemindersScreen
│   └── profile/                 # ProfileScreen
└── widgets/                     # MnButton, MnCard, MnEmptyState, MnSectionHeader, MnLoading
```

---

## Challenges Faced

1. **Offline queue ordering** — When moods were written to Hive then synced to Firestore on reconnect, duplicate IDs caused overwrite conflicts. Resolved by using UUID v4 as document ID (Firestore `set` is idempotent for same ID).

2. **Recommender tuning** — Early versions of the scoring formula over-weighted `moodFit` and always returned the same top item. The recency penalty and variety bonus were added after observing test case 4 fail. The least-squares slope required clamping for lists shorter than 2 entries.

3. **Audio asset licensing** — `audioplayers` requires the asset path relative to the `assets/` directory. Bundling large MP3s (>200KB each) inflated APK size; swapped to short ambient loops compressed with ffmpeg to ~80KB each.

---

## AI Usage Disclosure

| Tool | Purpose | Manual Modifications |
|------|---------|----------------------|
| Claude Sonnet 4.6 | Generated all Dart code, JSON seed data, and this README | All color values, copy strings, scoring formula weights, and design decisions reviewed and adjusted manually |
| Claude Opus 4 | Created the implementation plan (`CLAUDE.md`) | Architecture decisions (Provider vs Bloc, offline queue strategy, Result type) shaped by team review |

**What was NOT generated:**
- The specific mood color palette (#F5A65B, #7FB7BE etc.) — chosen manually for WCAG contrast
- Scoring formula coefficients (1.0, 0.6, 0.4, …) — tuned via unit test iteration
- App concept ("Calm Garden" metaphor) — original product decision
- Copy/voice ("Your nest of calm", all user-facing strings) — written with intentional wellness positioning

---

## License

MIT

## Acknowledgements

- Audio: replace placeholder assets with tracks from [Freesound.org](https://freesound.org) under CC0 license
- Lottie animations: [LottieFiles.com](https://lottiefiles.com) free tier
- Charts: [fl_chart](https://pub.dev/packages/fl_chart) by Iman Khoshabi (MIT)
- Icons: Material Symbols
