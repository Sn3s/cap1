# CAP2 post-defense application revisions

| Panel revision | Application change | Evidence |
| --- | --- | --- |
| Create a badge that recognizes financial habits | Habit Builder appears in the Financial Habits section of Profile. It recognizes four consecutive weeks of deliberate transaction tracking. | `achievements.dart`, `app_state.dart`, `habit_builder_test.dart` |
| Rename Financial Health Score | Shelby Score appears on Home, in its breakdown and score sharing, and in related onboarding, privacy, and AI copy. | `health_score.dart`, `home_screens.dart`, `community_service.dart`, `health_score_test.dart`, `ai_chat_snapshot_test.dart` |

## Habit Builder

Habit Builder appears under **Financial Habits** with the description “Build better money habits, one action at a time.” The unlock text reads “For four weeks in a row, log a transaction or label an unlabelled FakeMaya transaction.”

Shelby tracks the week in which the user saves the manual entry or explicitly saves the FakeMaya label. Explicitly confirming a previous label suggestion also qualifies on an unlabelled transaction. The financial entry must have a nonzero amount and meet Shelby’s existing financial Insights inclusion rule. One transaction can contribute to one week. Multiple qualifying actions in the same week still count as one week.

Weeks run Monday through Sunday in the device’s local calendar, using Shelby’s app clock. The week is saved at the time of the action and retained if the device changes time zones. An open week gives the user time to act. A closed week with no qualifying action breaks an unfinished run. The fourth qualifying week can unlock while it is open because a saved action is already observable. An intact four-week run can be recovered if the app restarts before the celebration was saved.

This badge measures **financial self-monitoring**, an observable collection behavior that supports later reflection. It does not measure adherence to a goal, an increase in savings, or the Action stage of the Personal Informatics framework by itself. Shelby’s existing motivation streak mixes action types and schedules, and historical settings do not establish which targets applied when. The badge therefore starts prospectively and uses records the app can verify. Other optional badges and historical backfills were omitted.

The rule applies equally to regular, variable, and irregular income. Users can record an expense or label an existing transaction without receiving new income. There is no minimum contribution, required purchase, or use of expected income. Login, screen views, automatic sync, internal transfers, exclusions, and edits of already-labelled records do not earn another week.

### Persistence and privacy

- The private profile has an optional `financialHabitEvents` map. Each event links the stable transaction ID, scoped to manual records or the linked FakeMaya account, to an action timestamp and calendar week. Profiles without this field start at zero. Events are cleared from memory at account reset or sign-out and replaced on profile restore.
- Progress is derived from the current qualifying records. Deleting or excluding a record removes its contribution before the badge is earned. Recategorizing it preserves its original week if it still qualifies. Re-including the same record restores the original week. The same linked transaction ID survives repeated refreshes without giving extra credit.
- Awarding stores `habit_builder` in the existing `seenBadgeIds` field and clears the temporary event map. The existing celebration presents the new badge once. Corrections after earning leave the badge intact. Earlier badges retain their IDs and thresholds.
- Community posting uses the existing explicit Share it flow and sharing permissions. The payload contains the badge name, icon, achievement status, and a generic description. Transaction IDs, timestamps, income, balances, and goal details stay out of the payload.
- A linked record must still be present under a verifiable ID to support an unearned badge. A missing or re-keyed provider record may remove an unearned week. The profile uses the existing profile save path and inherits its concurrent-device write behavior.

## Shelby Score

| Copy | Text |
| --- | --- |
| Previous name | Financial Health Score |
| Subtitle | A financial health indicator based on your activity in Shelby |
| Definition | The Shelby Score is a proposed financial health indicator based on your recorded financial activities, goal progress, financial habits, and engagement within Shelby. |
| Disclaimer | The Shelby Score is not a credit score or a standardized financial health assessment. |

The Home card displays the computed score, ring, band, and a link to the breakdown. The breakdown retains the itemized financial actions, engagement, and deductions and adds the definition and disclaimer. Profile, onboarding, transaction labels, community privacy text, and new achievement cards use the branded name. Historical score cards, scorecards, and the two existing score badges map recognized old wording at display time. Their stored fields remain unchanged.

The AI chat snapshot supplies the app-calculated value and band, or reports that a score is unavailable. The prompt distinguishes it from goal scores, feasibility, and official credit or financial assessments. The configured primary model remains Google Gemini 3.1 Flash-Lite (`gemini-3.1-flash-lite`). Qwen assets remain disabled. The numeric calculation, internal identifiers, fields, weights, deductions, bands, and rounding were preserved. Habit Builder itself does not feed the calculation.

## Changed files

| Files | Responsibility |
| --- | --- |
| `lib/core/app_state.dart` | Records explicit activity and persists progress and earnings in the existing profile. |
| `lib/features/community/achievements.dart`, `lib/features/community/community_screens.dart`, `lib/services/community_service.dart` | Computes and presents Habit Builder, shares a generic award, and displays legacy score text under the new branding. |
| `lib/features/home/health_score.dart`, `lib/features/home/home_screens.dart` | Presents the score on Home, in the breakdown and Profile, and triggers the existing celebration. |
| `lib/services/shellby_ai_coach.dart` | Grounds AI explanations in the canonical Shelby Score. |
| `test/habit_builder_test.dart`, `test/health_score_test.dart`, `test/ai_chat_snapshot_test.dart` | Exercises badge eligibility, privacy and profile persistence, score regressions, layouts, and AI context. |
| `docs/CAP2_POST_DEFENSE_APPLICATION_REVISIONS.md` | Records implementation, validation, and paper guidance. |

## Validation

| Check | Cases | Result |
| --- | --- | --- |
| Habit Builder | Progress from zero to four, duplicate submissions, edit and deletion, closed week gaps, variable income without payday, passive activity, FakeMaya sync, account isolation and profile round trips, sharing privacy, and one celebration | 10 passed |
| Shelby Score | Existing action and engagement weights, deductions and balance penalties, demo bounds, unchanged 95/100 after earning, legacy card display, disclaimer, and dashboard navigation | 12 passed |
| Targeted VM regression | Habit Builder, Shelby Score, streaks, AI snapshot, community, and manual transactions | 76 passed |
| Headless Chrome | Habit Builder and Shelby Score, including the 320 and 1,280 logical pixel dashboard layouts | 22 passed |
| Full VM regression | All repository test files, run serially | 327 passed, 38 skipped, 1 pre-existing failure |
| Analyzer | Source and tests compared with the pre-change diagnostics, ignoring line-number shifts | 0 errors, 39 warnings and 231 infos, identical to baseline |

Commands used

```sh
flutter test --reporter expanded test/habit_builder_test.dart test/health_score_test.dart test/streaks_test.dart test/ai_chat_snapshot_test.dart test/community_test.dart test/manual_transaction_test.dart
flutter test --no-pub --platform chrome --reporter expanded test/health_score_test.dart test/habit_builder_test.dart
flutter test --no-pub --concurrency=1 --reporter expanded
flutter test --no-pub --reporter expanded test/weekly_challenges_test.dart
flutter analyze --no-pub
git diff --check
```

Profile persistence was verified through the production profile serializer and restore path with synthetic profiles. Layout and celebration were verified in widget tests and headless Chrome. This run did not exercise live Firestore or Gemini, or a physical mobile device.

The remaining full-suite failure is `accepted challenge persists its lifecycle fields and can be skipped` in `test/weekly_challenges_test.dart`. It expects a fixed November 3–10, 2026 challenge to be active after its end date. Running that file in a detached checkout of `d6e682a` reproduced the same failure. The Home weekly challenge interaction passed in the final suite.

## Screenshot reproduction

Use a disposable demonstration profile and synthetic records. For score evidence, choose a fixture with a computed score. On Home, scroll below the weekly challenge to the Shelby Score ring and band. Open **View Shelby Score breakdown** and scroll to **What is the Shelby Score?** for the definition and disclaimer. Capture a score-share preview from the breakdown.

For badge evidence, open **Profile → Badges → Financial Habits** on a fresh fixture and open Habit Builder. Save a distinct synthetic expense or label a distinct unlabelled FakeMaya row in each of four consecutive weeks. On a dedicated test device, **Profile → Settings → Time travel** can advance the app clock one week at a time. The fixed dates and receipts in `test/habit_builder_test.dart` provide an alternative for widget fixtures. Capture the locked state before the first action, progress after the third, and the unlock dialog after the fourth. Open the earned badge and select **Share it!** to capture the generic preview. Use **Only Me** in a test profile if capturing a posted card. Reset the development clock after the walkthrough. Repeat at a narrow mobile viewport and at desktop browser width. No screenshots are attached.

## Capstone paper guidance

- **1.4.2 and 5.1.1:** Document Habit Builder as a financial self-monitoring achievement, distinct from login streaks and financial milestones.
- **6.3:** Document the optional private event field and existing earned-ID persistence.
- **6.4.1 and 8.4.7:** Rename the overall score to Shelby Score and carry forward the original formulas, thresholds, and financial assessment limitations.
- **6.5 and Appendix E:** Update the Home, score breakdown, Financial Habits, and share-preview screen specifications.
- **8.1, 8.4.6, and Appendix G:** Record the post-defense badge and branding tests with their actual results.
- **Appendix B:** Connect deliberate logging and labelling to Collection and its support for Reflection. Do not describe the badge as proof of recurring goal completion.

The original UAT preceded these changes. Report this validation as post-defense testing and do not attribute feedback about the new badge or wording to the original participants.
