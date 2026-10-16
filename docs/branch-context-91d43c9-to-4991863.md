# CAP1 branch context: `91d43c9` through `4991863`

## Purpose and scope

This document is a paste-ready technical context brief for another ChatGPT or
engineering reviewer. It describes the historical change set beginning at
`91d43c9` (`fix: keep merchant suggestions visible in category picker`) and
ending at `4991863` (`Fix emergency fund allocation eligibility`). It is based
on the commit graph, commit diffs, source inspection, and a partial local test
run on 14 October 2026 (Asia/Manila).

This is an analysis of the `cap1` Flutter application, not the sibling
`fakemaya` repository.

## Current repository/branch snapshot

| Item | State |
| --- | --- |
| Local repository | `/Users/yco/Codes/cap1` |
| Checked-out branch | `newercap` |
| Current `HEAD` | `49918630f899f8ef5190e1fb7d36cd49c2d77019` |
| `HEAD` subject/date | `Fix emergency fund allocation eligibility` — 13 Oct 2026, 01:02 +08:00 |
| `origin/mattyBranch` | Points to the same target commit as `HEAD` |
| `origin/newercap` | `0cb31ab` (`Fix A19 months covered and floor calculations`) |
| Local-vs-`origin/newercap` divergence | Local `newercap` is 28 commits ahead; remote has no commits absent locally |
| Commits in the audited inclusive graph | 36, including one merge commit; 35 are after the starting commit |
| Net diff from `91d43c9` to `4991863` | 49 files changed; 16,636 insertions and 4,805 deletions |
| Commits after `4991863` | None; this is the latest commit in the checked-out worktree |

The worktree contained two untracked, user-owned files during this review:
`cap1.code-workspace` and `docs/updated-system-architecture.md`. They are not
part of this commit range and were not evaluated as part of it.

## High-level result

This range transforms `newercap` from a goals/budgeting implementation with
some transaction-labeling work into a broader financial-coach application. It
adds or substantially completes:

- reliable transaction categorization, category-ledger behavior, and recent
  activity filtering;
- FakeMaya-backed emergency, essential, investment, crypto, and lifestyle fund
  flows;
- M3 investment/crypto actions and M4 lifestyle actions;
- health scoring, reset-account behavior, logging/goal streaks, reflection,
  and insight explainers;
- community/cooperative features, achievements, Firestore rules/indexes, and
  Firebase profile/auth integration; and
- onboarding and usability improvements for income, bills, professions, and
  action configuration.

The range is feature-rich, but it is not fully release-verified: the current
full test suite has known failures, and no end-to-end Firebase/Firestore or
native iOS verification is demonstrated by this history.

## Application architecture affected by this range

The app is Flutter/Dart. `AppState` is the central mutable state and business
logic layer. It owns onboarding data, actions/goals, local ledgers,
transactions, FakeMaya linkage, profile persistence, health/streak state, and
many synchronization methods. `home_screens.dart` contains much of the Goals,
Insights, wallet/action, and recent-activity UI. Consequently, both files saw
very large edits and are the highest regression-risk areas.

Major additions/expansions in this range:

- `lib/core/app_state.dart`: allocation rules, fund/ledger synchronization,
  investment and lifestyle calculations, streaks, health, profile persistence,
  and demo/mock data.
- `lib/features/home/home_screens.dart`: category picker, action panels,
  insight and reflection UIs, filters, goal screens, and many action flows.
- `lib/features/home/health_score.dart`: new financial-health score UI and
  logic.
- `lib/core/community_state.dart`, `lib/services/community_service.dart`, and
  `lib/features/community/*`: community/cooperative state, Firebase/Firestore
  backend, screens, badges, and achievements.
- `lib/services/fakemaya_service.dart`: FakeMaya bucket, withdrawal, transfer,
  reset, and investment synchronization support.
- `firestore.rules` and `firestore.indexes.json`: community data access and
  index configuration.

## Commit-by-commit ledger

The list below includes the starting commit and all commits reachable through
the target. A merge is listed because it introduced concurrent work into the
branch even though it has no standalone product behavior of its own.

| Commit | Date | Change and practical effect |
| --- | --- | --- |
| `91d43c9` | Oct 8 | Keeps learned/deterministic merchant category suggestions visible while a user is in the category picker. Adds category-picker tests. This is the starting point. |
| `8fa5a16` | Oct 8 | Makes the A3 category budget ledger easier to read. |
| `353bdf4` | Oct 8 | Merges concurrent `newercap` work, including merchant-category rules, learned category suggestions, and related tests. |
| `3bc81e3` | Oct 8 | Prevents the A3 flow from crashing when the user cancels. |
| `8ea256e` | Oct 8 | Aligns transaction categories with the budget ledger and adds category presets. |
| `7706f35` | Oct 8 | Corrects A3 categories/transactions: permits cash without disrupting the Essential Expenses Fund, allows categories outside the onboarding motivation, and clarifies category layers. |
| `47c9639` | Oct 8 | Fixes crashes from A20 target editing and similar goal-action controls. |
| `0cb31ab` | Oct 8 | Changes A19 months-covered/floor calculations to use monthly essential expenses rather than every monthly expense. This is the current `origin/newercap` tip. |
| `8978295` | Oct 10 | Updates local iOS/Flutter dependency and Xcode project artifacts. It is infrastructure/dependency work, not a clearly described product feature. |
| `32f148e` | Oct 10 | Repairs M3 A12/A23 investment-fund behavior and crypto synchronization; adds investment synchronization tests. |
| `767d73c` | Oct 10 | Implements M3 A30 crypto performance/insights, including annual-return calculations and buy/sell treatment. |
| `35123cb` | Oct 10 | Completes M4 lifestyle actions and synchronizes lifestyle/hobby sub-buckets with FakeMaya. |
| `915d799` | Oct 10 | Adds logging streaks and goal-streak foundations; restructures parts of onboarding/action flow. |
| `822dcbd` | Oct 10 | Adds financial-health score math/UI. Its own commit message explicitly says it still needs bug fixes. |
| `c363a96` | Oct 10 | Follow-up repairs to health-score behavior and account reset; adds action-order coverage. |
| `22a1b30` | Oct 9 | Adds Emergency Fund withdrawal synchronization and error handling. Commit date is earlier than nearby commits, but it is integrated at this point in the graph. |
| `22c3e6e` | Oct 11 | Further fixes Emergency Fund balance not refreshing after withdrawal; adds a focused mock-data test. |
| `e7bfcae` | Oct 11 | Fixes action label display/behavior problems. |
| `2303d49` | Oct 11 | Implements M3 A10: move money from the wallet into the Investment Fund through the Shellby action path. |
| `ee69756` | Oct 11 | Closes identified paths that allowed spending/allocating more money than exists; adds wallet-funded-action tests. |
| `5c884c9` | Oct 11 | Large community integration: cooperative features, badges, achievements, streak integration, Firestore rules/indexes, backend and screens. The message says Firebase authentication was still needed at this point. |
| `f9f0949` | Oct 11 | Improves onboarding: free-text occupation/industry, scrollable suggestions, and clearer income/bill schedule toggles. |
| `7cefc69` | Oct 11 | Makes typed onboarding text black and resets toggles when adding another income source. |
| `ee7c1b1` | Oct 11 | Reverts the typed-text color choice to grey and refines category-layer selection. This supersedes part of `7cefc69`. |
| `12fe33d` | Oct 11 | Follow-up cooperative/Firebase integration. Firebase startup, profile/auth wiring, community behavior, and tests are expanded; the commit claims it was tested with Firebase. |
| `1b6bc0e` | Oct 11 | Fixes Investment Fund synchronization with CoinGecko live holdings values. |
| `32c8aed` | Oct 11 | Removes fund-source selection from cash transactions, preventing cash entries from incorrectly affecting FakeMaya bucket actions. |
| `002ed31` | Oct 11 | Adds an Unlabeled filter to recent activity and fixes a crash in the savings filter. |
| `2621987` | Oct 11 | Renders internal transfers in neutral colors so users do not mistake transfers for losses. |
| `3840143` | Oct 11 | Preserves a transaction's label when it is reopened. |
| `2bd2bff` | Oct 11 | Seeds the A2 budget ledger from non-scheduled expense selections in onboarding, instead of presenting an empty A2 action after a suggested monthly cap. |
| `dcf5cb0` | Oct 12 | Replaces a static monthly recent-activity selector with a working timeframe dropdown. |
| `7bbf33c` | Oct 12 | Limits Reflection to the current month; future scheduled bills no longer make next month appear prematurely. |
| `3e3d17d` | Oct 12 | Makes Bill Readiness and Goal Resiliency tappable, exposing explanations of their calculations. |
| `777f759` | Oct 12 | Corrects Bill Readiness to count the Essential Expenses Fund in addition to wallet and cash-on-hand money. |
| `4991863` | Oct 13 | Latest commit. Limits Emergency Fund payday allocation to a qualifying, same-day Wallet income transaction labeled `Salary`; uses `labeledAt` if `createdAt` is absent; blocks stale, unlabeled, excluded, non-salary, and older income. Adds focused eligibility tests. |

## Detailed behavior that is now present

### 1. Categorization, A3 budgeting, and activity management

Merchant categorization has a priority system: an explicitly saved category
wins, then learned merchant corrections, older exact-pattern rules, and
deterministic built-in mappings. Transfers and cash movements are excluded from
suggestion/learning. The picker continues showing merchant suggestions instead
of losing them during interaction.

A3 now has a clearer budget ledger, cancel safety, category-to-ledger matching,
and broader category selection. Cash can be used without being treated as an
Essential Expenses Fund operation. The recent-activity UI can filter unlabeled
items, retains labels when items are reopened, has repaired savings filtering,
and supports real timeframes. Internal transfers use visually neutral styling.

### 2. Goals, funds, FakeMaya, and money-safety rules

The application now uses FakeMaya as the backing account/bucket model for
several goals. It synchronizes deposits/withdrawals and keeps local action
ledgers aligned with the remote/mock FakeMaya summary. The significant behavior
changes are:

- A19 measures coverage/floor from essential monthly expenses.
- A20 edit-target controls no longer crash.
- Essential, Emergency, Investment, and Lifestyle/hobby fund flows have
  explicit transfers and synchronization paths.
- Emergency withdrawals update the balance and handle service errors.
- Multiple allocation paths were hardened against creating unlimited money or
  spending beyond funded balances.
- Cash transactions cannot select FakeMaya fund sources, avoiding false action
  progress caused by cash-only entries.
- A2 budget categories are initialized from onboarding expense choices.

The latest Emergency Fund eligibility logic is intentionally strict. A user
must label a qualifying Wallet income as `Salary` today before the “set aside”
action can use it. The code selects the most recent same-day candidate and
rejects unlabeled income, incomplete/non-salary labels, excluded transactions,
old income, and transactions without a usable creation/label date. This is a
business rule, not merely a UI disablement: the deposit method verifies that
the passed transaction is the currently eligible one.

### 3. Investments and crypto (M3)

M3 now has linked investment behavior rather than purely presentational cards:

- A12 and A23 update the Investment Fund and its target without double
  counting.
- A10 can transfer wallet money into that fund through the action flow.
- A30 calculates annualized returns from weekly valuations.
- Buys are not counted as gains, sales affect holdings/fund state correctly,
  and total-invested/unrealized calculations are separated.
- CoinGecko holdings/live-value synchronization is covered with focused tests.

### 4. Lifestyle goals (M4), streaks, health, and reflection

M4 lifestyle actions and hobby sub-buckets are connected to FakeMaya. The app
also adds logging streaks and a goal-streak foundation, financial health scoring
and its screen, and a reset-account operation that zeroes account data while
preserving onboarding configuration/goals and synchronizing the linked
FakeMaya account where possible.

Reflection now avoids future-month data. Insight metrics include explanatory
tap targets, and Bill Readiness includes money in the Essential Expenses Fund.

### 5. Community/cooperative features and Firebase

The range adds a full community surface area: community state, Firestore-backed
service layer, community screens, achievement/badge UI, indexes, and rules.
Firebase profile/auth support is wired into application startup and profile
persistence, including email and Google sign-in service methods. The later
community commit addresses the earlier note that Firebase authentication was
still missing.

This should not be read as proof of deployed Firebase correctness. The source
contains the integration, but this commit range has no recorded emulator,
production-rule, multi-user, or end-to-end deployment verification.

### 6. Onboarding and UX

Users can enter a profession/industry directly rather than only choosing an
`Other` option; suggestions scroll; income/bill stability controls are clearer;
and new income rows reset their toggles. A later commit intentionally changes
typed text back to grey, so the final desired visual state is grey rather than
the temporary black-text change. Onboarding also seeds A2 budgets from selected
expenses.

## Test coverage added or materially expanded

The range adds/extends tests for the following areas:

- merchant/category suggestions and category picker behavior;
- investment fund sync, wallet source, A30 return math, holdings values, and
  buy/sell accounting;
- FakeMaya-funded actions and lifestyle fund synchronization;
- emergency withdrawal/mock data and same-day salary eligibility;
- manual cash transactions and FakeMaya bucket behavior;
- goal action flow/order and hidden backlog behavior;
- health scoring, streaks, community behavior, onboarding income sources,
  occupation/industry, scheduled-bill chips, and A2/onboarding handoff.

The final focused eligibility tests pass in the observed run, as do the
investment-fund synchronization tests that executed before the suite reached
known failures.

## Known gaps, failures, and caution areas

### Test suite is not green

The local `flutter test` run reported at least these failures before the tool
time window ended:

1. `reflection_demo_baseline_test`: expected 16 selected goal actions but got
   14. The fixture/assertion and current configured action set have diverged.
2. `reflection_demo_baseline_test`: expected Investment Earnings This Month of
   900, but received 0. The reflection demo fixture or the investment earnings
   logic no longer matches that baseline.
3. `reflection_demo_baseline_test`: rendering every configured goal can reach
   `FirebaseAuth.instance` after FakeMaya session recovery without a Firebase
   default app initialized in the test harness. Production `main()` initializes
   Firebase, but the state/service path is not isolated enough for this test.
4. `main_mock_data_test`: expected a balance of 23,270 but got 24,590. Mock
   financial data/assertions are stale or a balance calculation changed.

The installed local toolchain reported Flutter 3.31.0 pre-release / Dart 3.8,
while the committed lockfile requires Dart `>=3.10.0-0`. The test outcome is
still useful evidence of real test/fixture gaps, but a clean full result should
be established with the repository's intended Flutter/Dart version before
using it as a release gate.

### Firebase/community still needs end-to-end confidence

Firebase initialization exists in `main.dart`, and profile persistence guards
against an absent signed-in user. However, the failing unit-test path confirms
that some service access occurs without a Firebase-app guard. The following are
not demonstrated by this range and should be tested before release:

- first-run, signed-out, signed-in, and session-expired FakeMaya recovery;
- Firestore rules against a Firebase emulator or staging project;
- multi-user cooperative membership/achievement behavior; and
- authentication error, account-link, and sign-out flows.

### Native/dependency changes need platform validation

`8978295` makes a large iOS lockfile/project resolution change. No iOS build,
simulator test, or dependency-resolution result is attached to the commit
history. Validate `pod install`, iOS build, and affected plugin behavior with
the intended Xcode/Flutter toolchain.

### Change concentration raises regression risk

`app_state.dart` and `home_screens.dart` have thousands of changed lines and
mix core calculations, persistence, synchronization, and UI. The branch needs
scenario-based regression testing across all fund types, not only isolated
unit tests. Priority scenarios are: onboarding → fund creation; deposits and
withdrawals; transaction labeling/relabeling; investment buy/sell; connection
loss/session expiry; account reset; and signed-out/signed-in community use.

## Suggested interpretation for future decisions

When reviewing new proposals against this branch, assume:

1. `4991863` is the local latest baseline, not `origin/newercap`; the latter
   stops at `0cb31ab` and lacks 28 local commits.
2. Fund-related behavior is intended to be balance-safe and synchronized with
   FakeMaya. New flows must not create money, double count transfers, or treat
   cash as a FakeMaya bucket transfer.
3. Emergency Fund salary allocation is deliberately same-day and label-gated.
   Relaxing it is a product-rule change that requires changing both UI and
   `AppState` eligibility validation.
4. Community features depend on Firebase. Treat their production readiness as
   unverified until real Firebase integration testing passes.
5. The project has meaningful test investment, but tests and mock fixtures are
   currently out of sync with recent behavior. Do not assume a passing CI
   baseline until the four reported failures and toolchain mismatch are
   resolved.

## Bottom line

`newercap` at `4991863` contains a broad, largely implemented financial-goal
and community feature set with many targeted fixes and tests. Its latest
business-rule change correctly protects Emergency Fund allocation by requiring
a current-day Salary-labeled income. The branch is functionally much further
along than `origin/newercap`, but it is not yet fully validated: it has known
test/fixture failures, incomplete demonstrated Firebase end-to-end coverage,
and unverified native dependency changes.
