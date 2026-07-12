# Shellby Codebase Guide

Last updated: 2026-07-09

This document is the working map for coding agents and developers editing this
repository. Read it before changing the app. The project is a fast-moving
Flutter prototype whose architecture is deliberately centralized; assumptions
that are normal in a larger Flutter app, such as each file being an independent
library, are not true here.

## 1. Product Summary

Shellby is a personal finance companion for iOS and Android. It combines:

- Guided financial onboarding and goal selection.
- Manual accounts and manually logged transactions.
- Optional per-account synchronization from the FakeMaya test provider.
- Goal-specific plans for cash flow, emergency savings, irregular income, and
  longer-term wealth.
- Reflection-oriented Insights views with overview charts and transaction-level
  detail.
- A local Shelby chatbot powered by a bundled Qwen GGUF model through
  `llamadart`, with Gemini as an optional alternative.
- Local daily notification reminders for logging or syncing transactions.
- Firebase Authentication and Firestore profile persistence.

The UI name is **Shelby**. Some source identifiers use `Shellby` with two `l`s.
Preserve existing identifiers unless a deliberate repo-wide rename is planned.

## 2. Read This First

### The Dart source is one library

`lib/main.dart` imports all packages and declares nearly every other Dart file
using `part`. Files under `lib/core`, `lib/features`, `lib/services`, and
`lib/shared` begin with `part of`.

Consequences:

- Private names such as `_brand`, `_push`, and `_GoalSheetFrame` are shared
  across all part files.
- Do not add package imports directly to a part file. Add imports to
  `lib/main.dart`.
- A new Dart source file must be added as a `part` in `main.dart` and must have
  the matching `part of` declaration.
- Moving one file into a standalone library is an architectural migration, not
  a routine cleanup.

### `AppState` is the source of truth

`lib/core/app_state.dart` contains the central `ChangeNotifier`, derived
financial values, authentication actions, Firestore serialization, account
sync state, transaction labeling, goal state, demo data, and notification
settings.

Widgets access it with:

```dart
final state = AppScope.of(context);
```

Mutations that should redraw the UI must call `notifyListeners()`. Mutations
that must survive relaunch must also pass through `saveProfile()` when a user is
signed in.

### Preserve profile compatibility

Firestore stores one profile document per Firebase user. When adding persisted
state, update both:

1. `_profileMap(...)` to serialize it.
2. `_applyProfileMap(...)` to restore it.

Deserialization must tolerate missing and old fields. Use the existing
`_doubleFrom`, `_mapFrom`, and fallback patterns. Never assume every profile was
created by the current app version.

### Manual mode is a first-class mode

The app must remain usable without FakeMaya. Do not gate account totals,
transactions, Insights, Goals, or Activity behind `hasFakeMayaLink`.

Each provider-capable account can be manual or synced independently. Always use
`accountBalance(account)` and `isAccountSynced(account)` rather than reading the
FakeMaya summary directly in UI code.

## 3. Repository Map

```text
lib/
  main.dart                         App bootstrap, shared imports, theme, parts
  firebase_options.dart             Generated Firebase platform configuration
  core/
    app_scope.dart                  InheritedNotifier access to AppState
    app_state.dart                  Central state, persistence, domain mutations
  features/
    auth/auth_screens.dart          Auth gate, welcome, login
    preparation/
      preparation_screens.dart      Current onboarding flow and goal setup
      legacy_onboarding_screens.dart Older screens still retained/referenced
    home/home_screens.dart          Main tabs, settings, chat, transaction UI
  services/
    firebase_profile_service.dart   Firebase Auth and Firestore profile API
    fakemaya_service.dart           Supabase-backed FakeMaya adapter and models
    integration_service.dart        Day/week records and reflection metrics
    notification_service.dart       Native local notification scheduling
    shellby_ai_coach.dart           Local llama/Gemini AI orchestration
  shared/widgets/shared_widgets.dart Shared design-system widgets and charts

test/                                Unit, widget, flow, and screenshot tests
docs/onboarding-goal-action-tables.md Domain reference for onboarding goals
assets/images/                       Shelby artwork
assets/models/                       Local GGUF models; GGUF files are ignored
firestore.rules                      User-owned profile document rules
firebase.json                        Firebase project configuration
ios/, android/                       Native Flutter runner configuration
```

The three largest and most coupled files are:

- `lib/features/home/home_screens.dart`
- `lib/features/preparation/preparation_screens.dart`
- `lib/core/app_state.dart`

Search for the relevant class or method before editing; line numbers move often.

## 4. Runtime Bootstrap

`main()` performs this sequence:

1. Initializes Flutter bindings.
2. Initializes Firebase with `DefaultFirebaseOptions.currentPlatform`.
3. Initializes timezone data and local notifications.
4. Runs `ShellbyApp`.

`ShellbyApp` owns one `AppState`, exposes it through `AppScope`, creates the
Material 3 theme, and starts at `AuthGate`.

`AuthGate` calls `AppState.restoreSignedInUser()` once:

- Signed-in users are sent to `MainShell`.
- Signed-out users are sent to `WelcomeScreen`.

The app uses direct `MaterialPageRoute` navigation helpers (`_push` and
`_pushReplacement`), not named routes or a router package.

## 5. Main Navigation

`MainShell` keeps the active tab as local widget state and constructs six pages:

1. `DashboardPage` - total balance, spendable/saved summaries, Shelby entry.
2. `InsightsPage` - reflection questions, overview charts, selected detail.
3. `AccountsPage` - net worth and account/goal allocations.
4. `GoalsPage` - selected goal plans and goal-specific actions.
5. `ActivityPage` - transaction history, calendar, labels, manual logging.
6. `ProfilePage` - user details and Settings.

The Shelby avatar in the home header opens `ShellbyChatPage`.

Settings currently includes:

- User selections.
- Notifications.
- Accounts.
- Placeholder rows for privacy/security and appearance.

## 6. Onboarding Flow

The current early flow is:

1. `PreparationContextScreen` - name.
2. `PreparationCredentialsScreen` - Firebase email/Google account creation.
3. `LifeContextScreen` - life stage, occupation, industry.
4. `LifeRhythmScreen` - employment, income rhythm, bills, responsibilities.
5. `MonthlyIncomeScreen` - itemized monthly income ledger.
6. `InitialBaselineScreen` - itemized monthly expense ledger.
7. `PreparationOrientScreen` - orientation.
8. `FinancialConcernScreen` - primary concern.
9. Motivation and goal-questionnaire conversation.
10. Recommended plan and optional FakeMaya onboarding.
11. Permissions and data consent.
12. Baseline/tracking/feasibility screens where applicable.
13. Pyramid preview, social/privacy choices, commitment, collection handoff.

There are 15 displayed onboarding phases, but more than 15 widget screens.
Several screens intentionally share a phase number. When reordering screens:

- Update every `onPressed` destination.
- Update `_pushFinancialConcernWithFullHistory`.
- Update phase values and `_onboardingPhaseTotal` if the phase model changes.
- Update `test/onboarding_order_test.dart`.
- Update the catalog in `test/capture_all_screens_test.dart`.

Monthly income writes:

- `onboardingIncomeLedger`
- `income`
- `monthlySalary`
- `irregularIncomeFloor`
- income entries in `onboardingBaselines`

Monthly expenses writes:

- `onboardingExpenseLedger`
- aggregate expense values
- expense entries in `onboardingBaselines`

These values feed goal feasibility, pyramid calculations, and Insights. Avoid
adding a second independent baseline field when an existing derived getter can
be used.

## 7. State and Persistence

### State groups

`AppState` roughly contains:

- Firebase identity and onboarding completion.
- Life context and behavioral self-assessments.
- Guided-chat summaries and selected goal/action configuration.
- Monthly income and expense ledgers.
- Assets, liabilities, account balances, and transactions.
- Cash-flow and emergency-fund buckets.
- Two-jar irregular-income state and `jarLedger`.
- Goal overrides and plan-adjustment records.
- Notification consent and reminder times.
- FakeMaya link/session snapshot and per-account sync selection.

### Firestore

Profiles are stored at:

```text
profiles/{firebaseUserId}
```

`firestore.rules` permits only the authenticated owner to read or write that
document.

`FirebaseProfileService` owns authentication and raw profile load/save calls.
`AppState` owns mapping between Firestore data and runtime fields.

`saveProfile(markOnboardingComplete: true)` is the normal final onboarding
commit. Many incremental actions save immediately only when `isSignedIn`.

### Demo data

The reflection demo is seeded in `_applyReflectionDemoProfile`. It intentionally
contains aligned onboarding baselines, labeled transactions, jars, and goal
state. When changing financial semantics, update the demo and
`test/reflection_demo_baseline_test.dart` together.

`seedReflectionDemoDataForTesting()` exists for deterministic tests without a
Firebase `User`.

## 8. Canonical Financial Semantics

### Accounts

The canonical account display names are:

- `Cash on Hand`
- `Wallet`
- `Savings`
- `Time Deposit`
- `Goal Savings`

Do not expose names such as `FakeMaya Wallet` in user-facing account labels.
FakeMaya is a data provider, not an account type.

`Cash on Hand` is manual-only. The other four accounts can independently use:

- Manual balance from `manualAccountBalances`.
- Synced balance from `fakeMayaLink.summary` when their name is present in
  `fakeMayaSyncedAccounts`.

Use:

```dart
state.accountBalance('Wallet')
state.isAccountSynced('Wallet')
```

`allTransactions` always includes manual transactions. FakeMaya transactions
are included only when `Wallet` is synced because the provider transaction feed
belongs to its wallet.

### Transaction labels

The meaning of labels is strict:

- **Category**: what type of transaction occurred, such as Groceries,
  Transport, Salary, or Health.
- **Source**: which fund financed the transaction.

Canonical source options are:

- `Basic Needs Fund`
- `Emergency Fund`
- `Investment`
- `Time Deposit`

Emergency transactions and payments must use `Emergency Fund`. Routine bills
and normal expenses use `Basic Needs Fund`. Do not place fund names in the
category list.

Transactions are represented by `FakeMayaTransaction` even when they were
entered manually. Important fields and getters include:

- `amountText` and parsed signed `amount`
- `category`, `source`, and `account`
- optional `subcategory`, `tag`, and `note`
- `excludedFromInsights`
- `transactionId`, `isLabeled`, and `patternKey`

Manual logging is initiated by the add button on `ActivityPage` and handled by
`_ManualTransactionSheet` plus `AppState.addManualCashTransaction`.

### Totals

Use `AppState` getters for totals and targets. In particular:

- `totalAssets`, `totalLiabilities`, `netWorth`
- `monthlyExpenseLedgerTotal`
- `monthlyEssentialExpenseTotal`
- `monthlyNonEssentialExpenseTotal`
- `monthlySurplus`
- `emergencyFundTarget`, `emergencyMonthsCovered`
- `requiredMonthlyContribution`, `feasibilityScore`

Do not sum FakeMaya summary values independently in widgets. That can double
count synced balances or ignore manual accounts.

## 9. FakeMaya Integration

`FakeMayaService` is a direct HTTP adapter for a Supabase test backend. It:

- Authenticates FakeMaya credentials.
- Loads and refreshes wallet snapshots.
- Writes provider-side allocations and withdrawals.
- Converts provider JSON into `FakeMayaSession`, `FakeMayaLink`,
  `FakeMayaAccountSummary`, and `FakeMayaTransaction`.

The Supabase URL and publishable client key currently live in the source. Treat
the key as a public client credential governed by backend row-level security;
never add privileged service-role credentials to the app.

App-level link behavior lives in `AppState`:

- `linkFakeMayaAccount(..., syncedAccounts: ...)`
- `refreshFakeMayaAccount()`
- `unlinkFakeMayaAccount()`
- `setAccountFakeMayaSync(account, synced)`
- `_syncFakeMayaMoneyItems()`

Settings -> Accounts is the user-facing control. Linking FakeMaya does not mean
all accounts must be synced. Keep per-account selection intact.

When refreshing a session, existing transaction labels are merged back into the
new provider transaction list by transaction ID. Preserve this behavior or a
sync will erase user labeling work.

## 10. Insights and Reflection

`IntegrationService.fromState(state)` converts raw jar events and transactions
into:

- `DayRecord`
- `WeekRecord`
- jar integrity series
- buffer resilience series
- refill consistency series

Only labeled, non-excluded transactions should drive categorized reflection.
Basic-needs spending calculations explicitly require source
`Basic Needs Fund`; emergency spending must not inflate routine cash-flow data.

The intended Insights interaction pattern is:

1. An overview chart that reveals weekly/monthly patterns.
2. A detail list for the selected period.
3. Tapping overview data immediately filters the detail.
4. Labels and legends explain units, period, categories, and data quality.

`InsightsPage` and its explorer widgets are in `home_screens.dart`. Goal-specific
AI analysis opens `ShellbyChatPage` with screen context so Shelby can summarize
the relevant goal data and answer follow-up questions.

When adding a chart, also add the granular context that explains why the chart
moved. Do not present unlabeled visual encodings.

## 11. Shelby AI

`ShellbyAiCoach` supports two providers selected at compile time. Gemini is the
default provider.

### Local provider (default)

The default model asset is:

```text
assets/models/qwen3-1.7b-instruct-q4_k_m.gguf
```

The GGUF file is about 1 GB locally and is intentionally ignored by Git. The
`assets/models/` directory is included by `pubspec.yaml`, so a developer must
place the model there before building the default AI configuration.

On first use, `_LocalLlamaRuntime`:

1. Copies the bundled asset to the application support directory.
2. Spawns a Dart isolate.
3. Initializes `llamadart`.
4. Uses Metal with GPU layers on iOS/macOS.
5. Sends generation commands through isolate ports.

Compile-time controls:

```text
AI_PROVIDER=gemini|local
LOCAL_MODEL_ASSET=<asset path>
LOCAL_MODEL_CONTEXT_SIZE=<integer>
GEMINI_API_KEY=<key override>
GEMINI_MODEL=<model name>
GEMINI_REQUEST_TIMEOUT_SECONDS=<integer>
GEMINI_MAX_RETRIES=<integer>
```

### Gemini provider

Gemini is called directly with `HttpClient` when `AI_PROVIDER=gemini`.
`GEMINI_API_KEY` can be passed with `--dart-define` to override the default
developer key. Gemini is preferred on normal internet-connected runs; network,
timeout, rate-limit, and server-availability failures fall back to the bundled
Qwen local model.
For local development, `config/gemini.local.json` can also be passed with
`--dart-define-from-file`; that file is ignored by Git.

### AI context

The coach has separate workflows for:

- Motivation coaching.
- Goal recommendation.
- General/profile-aware chat.
- Goal-screen analysis through `screenContext`.

Financial answers are generated from a serialized snapshot of `AppState`.
When adding an important user-data field, decide whether it must also be added
to the AI context builders. Do not send secrets, access tokens, or passwords.

## 12. Notifications

`ShellbyNotificationService` wraps `flutter_local_notifications` and `timezone`.
It schedules up to eight daily reminders.

- iOS minimum version is 15.
- Android declares `POST_NOTIFICATIONS` and scheduled-notification receivers.
- The timezone comes from the device, with `Asia/Manila` as fallback.
- Notification permission is requested only through an explicit user action.
- Settings -> Notifications controls enablement, times, and a test banner.

State methods normalize and persist reminder times, then reschedule native
notifications. UI state alone is not sufficient; changes must reach the native
service.

The header time icon leads to notification settings. It does not simulate a
separate in-app clock.

## 13. UI and Design System

Global theme colors and AI compile-time constants are in `main.dart`.

Key palette:

- `_brand`: mint primary actions.
- `_purple`: shell accent/secondary actions.
- `_bg`: warm page background.
- `_surface`: white surfaces.
- `_title`: dark plum text.
- `_body`: secondary text.
- `_green`, `_red`, `_amber`: financial status colors.

Typography uses Nunito for body text and Fredoka for prominent headings through
`google_fonts`.

Prefer shared widgets from `shared_widgets.dart`:

- `OnboardingScaffold`, `PhaseHeader`, `StepProgress`
- `PrimaryButton`, `SecondaryButton`
- `AppTopBar`, `PageHeader`
- `AppCard`, `MetricCard`, `GoalCard`
- `LabeledField`, `MoneyInput`, `CompactChoice`, `ToggleRow`
- `FinancialPyramid`, `LineChart`

The current code has some older 14-22 px radii, while newer operational screens
use tighter 8 px cards. Match the surrounding screen instead of conducting a
global visual refactor during a feature change.

Use existing Shelby bitmap assets. Note that both `shelby_*` and `shellby_*`
filenames exist; verify the exact asset path before changing one.

## 14. Testing

Run focused tests while editing and the full suite before handing off:

```bash
flutter test test/account_sources_test.dart
flutter test test/manual_transaction_test.dart
flutter test
flutter analyze
git diff --check
```

Important test ownership:

- `account_sources_test.dart`: manual/synced account behavior and names.
- `manual_transaction_test.dart`: account balances and Activity logging sheet.
- `transaction_pattern_test.dart`: learned labels and profile migration.
- `integration_service_test.dart`: reflection metric directionality.
- `insights_labeled_data_test.dart`: Insights overview/detail and source rules.
- `reflection_demo_baseline_test.dart`: demo baseline/goal alignment.
- `goals_account_mapping_test.dart`: goal-to-account presentation.
- `onboarding_order_test.dart`: onboarding sequence and phase numbering.
- `notification_settings_test.dart`: reminder normalization and navigation.
- `widget_test.dart`: welcome/auth smoke coverage.
- `capture_all_screens_test.dart`: screenshot catalog and rendering harness.

Widget tests normally construct:

```dart
AppScope(
  state: AppState(),
  child: const MaterialApp(home: SomeScreen()),
)
```

Disable Google Fonts runtime fetching in tests that render themed text:

```dart
GoogleFonts.config.allowRuntimeFetching = false;
```

The screenshot harness writes to `/tmp/cap1-captures/all`. It can target one
screen with the `CAPTURE_SCREEN` environment variable.

The analyzer currently reports legacy warnings and informational lints in the
large screen files, including unused private widgets and deprecated
`withOpacity` calls. Do not bury new compile errors among those warnings. Keep
feature edits focused and avoid unrelated lint churn.

Some widget tests assert exact visible strings and can become stale after UI
reorganization. A failing visibility assertion should be checked against the
actual selected tab and scroll position before changing production behavior.

## 15. Running the App

Resolve packages:

```bash
flutter pub get
```

Run on an iPhone:

```bash
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
flutter run --release -d "Yco ’s iPhone" -v
```

`-v` enables verbose build/run status. For easier debugging, omit `--release`.

Run with Gemini:

```bash
flutter run -d <device>
```

Run with a local ignored Gemini config override:

```bash
scripts/run_gemini.sh <device>
```

Run locally with the bundled model:

```bash
flutter run -d <device> \
  --dart-define=AI_PROVIDER=local
```

Run with a different local model:

```bash
flutter run -d <device> \
  --dart-define=AI_PROVIDER=local \
  --dart-define=LOCAL_MODEL_ASSET=assets/models/model.gguf
```

The checked-in environment currently uses a Flutter prerelease/user branch with
Dart 3.8, while `pubspec.yaml` permits Dart `^3.4.0`. `llamadart` is pinned to
`^0.1.0` because newer releases require a newer Dart SDK. Do not upgrade it
without upgrading and validating the Flutter toolchain.

## 16. Safe Change Recipes

### Add persisted state

1. Add the field and a safe default to `AppState`.
2. Add it to `_profileMap`.
3. Restore it in `_applyProfileMap` with backward-compatible parsing.
4. Update mutation methods to save and notify.
5. Add a load/migration test if old profiles could behave differently.

### Add an account-aware feature

1. Use canonical account names.
2. Read balances through `accountBalance`.
3. Respect `isAccountSynced`.
4. Keep manual mode functional.
5. Avoid duplicating synced `MoneyItem` values in totals.
6. Test one manual account and one independently synced account.

### Add or change transaction labels

1. Keep category and fund source semantically separate.
2. Update manual sheet options and any provider-label UI.
3. Update profile migration/default-label logic.
4. Verify `IntegrationService` filtering.
5. Update demo data and Insights tests.

### Add an onboarding screen

1. Add the widget and navigation link.
2. Add its `part` only if it is in a new file.
3. Update phase numbering and full-history reconstruction.
4. Update screenshot catalog and onboarding-order tests.
5. Confirm its data is persisted and influences downstream calculations.

### Add AI-visible data

1. Add the state field and persistence.
2. Add a concise, non-secret representation to the appropriate AI context.
3. Keep prompt size within the local model's 2048-token default context.
4. Test fallback behavior when data is absent.

## 17. Common Failure Modes

- Adding an import to a `part` file instead of `main.dart`.
- Reading `fakeMayaLink.summary` directly and breaking manual mode.
- Treating FakeMaya as an account name instead of an optional provider.
- Adding a persisted field to serialization but not deserialization.
- Updating a transaction category without updating its fund source.
- Counting emergency spending as basic-needs cash flow.
- Reordering onboarding without updating phase tests and history rebuilding.
- Mutating `AppState` without `notifyListeners()`.
- Assuming GGUF assets are in Git.
- Committing API keys, Firebase secrets, or provider tokens.
- Refactoring one of the giant screen files while unrelated user changes are
  present in the same working tree.

## 18. Current Architectural Constraints

This is a prototype, not a layered production architecture. Known constraints:

- `AppState` has many responsibilities.
- The main home and onboarding files are very large.
- Services and UI share private symbols through the single-library `part`
  arrangement.
- Navigation is imperative and route state is not restorable.
- Firestore writes replace the profile document rather than merging fields.
- FakeMaya uses direct HTTP and stores its refreshable link snapshot in the user
  profile.
- Local model initialization is lazy and can be expensive on first use.
- Several legacy/refactored private Insights widgets remain unused.

Do not “fix” these constraints incidentally. A structural change should be
explicit, incremental, and covered by broad tests because the coupling is real.

## 19. Definition of Done

Before completing a code change:

- The requested flow works in manual mode unless the feature is inherently
  provider-specific.
- Existing profile data still loads.
- Financial labels follow the category/source rules.
- Derived totals use `AppState` getters and do not double count.
- The affected focused tests pass.
- `flutter analyze` introduces no new errors.
- `git diff --check` passes.
- Native changes are verified on the relevant simulator/device when the feature
  involves permissions, notifications, Firebase auth, or local AI.
- Unrelated dirty-worktree changes remain untouched.
