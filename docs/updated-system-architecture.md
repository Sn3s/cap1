# Shelby Updated System Architecture

## Purpose and scope

This architecture replaces a proposal-level system diagram with a source-based view of the Shelby prototype as implemented in this repository. It describes the current Flutter client, its managed Firebase services, the optional FakeMaya provider connection, the AI routes, cooperative features, and device-level services. "Shelby" is used in this document as the product name; several repository identifiers and the application label use the spelling `Shellby`.

The application is **not** a microservice system. Its feature logic, state management, calculations, integrations, and presentation are delivered in one Flutter mobile application. Firebase Authentication and Cloud Firestore provide its managed identity and persistence services. Gemini uses the configured direct client route; the deployed system has no Cloud Functions.

## 1. System context and deployment architecture

```mermaid
flowchart LR
  user[User]

  subgraph device[User device: Android or iOS]
    app[Shelby Flutter application]
    os[Operating-system services\nnotification permission, timezone and scheduled local notifications]
    qwen[Optional local Qwen runtime\nllamadart isolate and app-support model copy]
  end

  subgraph firebase[Firebase project: shelby-1b1d8]
    auth[Firebase Authentication\nemail/password and Google Sign-In]
    firestore[Cloud Firestore\nprivate profiles and consented cooperative collections]
  end

  subgraph external[External systems]
    fakemaya[FakeMaya Supabase service\nauthentication, wallet state, transactions and goal buckets]
    gemini[Google Gemini GenerateContent API]
    coingecko[CoinGecko API\nBTC and NVDA PHP market prices]
  end

  user --> app
  app <--> os
  app <--> auth
  app <--> firestore
  app -. configured Gemini route .-> gemini
  app -. optional account link, refresh and allocation .-> fakemaya
  app -. on-demand investment price refresh .-> coingecko
  app -. configured or fallback AI inference .-> qwen
```

### Reading the diagram

- Solid arrows identify the normal product path. A signed-in user authenticates with Firebase, and Shelby reads and writes that user's profile document in Cloud Firestore.
- Gemini uses the explicitly configured direct route from the client. The deployed system has no Firebase Cloud Functions or Secret Manager dependency, so the paper must not describe either as part of the implementation.
- Dotted arrows identify optional or conditional paths. A user can use Shelby with manually entered transactions and never link FakeMaya. CoinGecko is consulted only when investment prices are refreshed. The Qwen route is a local fallback/alternative, not a remote service.
- Device notifications are scheduled locally on the phone. There is no notification server, background job queue, or server-side push-notification component in this repository.

## 2. Flutter application design

```mermaid
flowchart TB
  subgraph flutter[Single Flutter application library]
    boot[main.dart bootstrap\nload runtime config, initialize Firebase and notifications]
    authgate[AuthGate\nrestore completed signed-in profile or show authentication/onboarding]
    ui[Presentation layer\nOnboarding, Home, Wallet, Goals, Insights, Community, transaction sheets and AI chat]
    scope[AppScope\nInheritedNotifier]
    state[AppState\ncentral domain state and mutation coordinator]
    profile[FirebaseProfileService\nidentity and profile persistence]
    maya[FakeMayaService\nprovider authentication, account refresh, transfers and market prices]
    integration[IntegrationService\ncomputed day/week records, scores and reflection metrics]
    coach[ShellbyAiCoach\nbounded prompts, structured suggestions and chat]
    community[CommunityController and CooperativeService\nfriends, private sharing, decisions and anonymous benchmarks]
    reminders[ShellbyNotificationService\npermission and up to eight daily reminders]
  end

  boot --> authgate
  authgate --> ui
  ui <--> scope
  scope <--> state
  state <--> profile
  state <--> maya
  state --> integration
  ui --> coach
  coach --> state
  ui <--> community
  community <--> firestore
  ui --> reminders
```

This is a logical component diagram, not a claim that each box is separately deployed. The repository uses Dart `part` files declared from `lib/main.dart`; `AppState` is the main in-memory source of truth and not a separate backend service. `AppScope` publishes its changes to the widgets through `InheritedNotifier`.

### Presentation layer

After onboarding, `MainShell` exposes four primary destinations: **Home**, **Wallet**, **Goals**, and **Insights**. It also provides a global manual-transaction entry point, access to Shelby chat, and a Community surface. Authentication and the preparation/onboarding screens sit before this shell.

The presentation layer does not independently calculate or persist financial data. It asks `AppState` to perform the relevant operation, reacts to state notifications, and displays the resulting balance, action progress, transaction labels, goal status, or reflection result.

### Central domain state: `AppState`

`AppState` contains the user's preparation profile, consent choices, selected motivation, goal and action configuration, onboarding baselines, balances, funds/jars, bills, manual account balances, transactions, transaction-label rules, linked FakeMaya account state, action-field values, and reminder settings. It also contains the operations that update those values.

For example, when a user records a manual transaction or labels a linked transaction, `AppState` updates the transaction and its label rule, saves the profile when the user is signed in, and calls `notifyListeners()`. When the user allocates money to a supported linked goal bucket, `AppState` asks `FakeMayaService` to transfer the amount; when no linked provider bucket applies, it updates the local goal-bucket override instead. The UI therefore remains a requester and renderer, while financial state transitions stay in one place.

### Derived reflection and insights

`IntegrationService.fromState(AppState)` derives day and week records from the current transaction and jar-ledger data. It calculates reflection measures such as jar integrity, buffer resilience, refill consistency, cash flow, category spending, and goal/action progress. These records are computed in the client at the time an insight is viewed; they are not stored as a separate analytics database or sent to an analytics service by the code in this repository.

Only appropriately labelled and non-excluded transactions contribute to the applicable insight calculations. This makes transaction labelling a functional part of the reflection process, rather than a cosmetic tag.

## 3. End-to-end data flows

### A. Account creation, sign-in, and profile restoration

1. The application bootstrap initializes Firebase and the local notification plugin before `ShellbyApp` is run.
2. `AuthGate` asks `AppState.restoreSignedInUser()` whether Firebase has a current user.
3. If a user exists, `FirebaseProfileService` loads `profiles/{uid}` from Cloud Firestore. Shelby accepts the account into the main application only when the profile indicates that onboarding is complete.
4. `AppState._applyProfileMap()` rebuilds the in-memory state from the document. If a FakeMaya link is stored, Shelby attempts to refresh it and refreshes the account-derived display state.
5. Subsequent state changes call `FirebaseProfileService.saveProfile()`, which writes the profile map back to the same Firestore document. Firestore security rules limit reads and writes to an authenticated user whose UID matches the document ID.

### B. Financial-data collection, labelling, and allocation

**Manual path.** The user creates a cash or manual-account transaction from the application. `AppState.addManualCashTransaction()` validates the available balance for an outflow, records a timestamped transaction together with category and source, updates the appropriate local balance, persists the profile, and refreshes the UI.

**Optional FakeMaya path.** The user signs in to the FakeMaya demonstration provider and selects which eligible accounts to sync. `FakeMayaService` authenticates against the provider's Supabase endpoint, retrieves wallet/account summaries and transactions, and stores the link/session summary through the user profile. On a later refresh, the service refreshes the provider session and account summary. Linked account use is optional; Cash on Hand remains a manual source.

**Labelling and goals.** The user assigns a category, source, optional subcategory, tag, and note to a transaction. Shelby retains a pattern rule for future matching and may exclude a transaction from Insights on the user's instruction. The labelled data feeds goal action progress and the reflection calculations. Where a linked provider account and an approved goal bucket are available, a user-triggered allocation or withdrawal is executed through FakeMaya; otherwise the appropriate local balance/goal bucket is changed. Shelby does not automatically move funds merely because it generated a recommendation.

### C. Insight and action cycle

1. Collected transactions, labels, fund/jar events, selected actions, and onboarding baseline values are held in `AppState` and persisted in the user's Firestore profile.
2. `IntegrationService` transforms the current state into meaningful financial records and progress indicators.
3. The Insights and Goals interfaces explain current results, including spending, balances, fund use, and configured action status.
4. When the user requests guidance, `ShellbyAiCoach` builds a bounded, feature-specific prompt from the relevant state. Its action-stage prompts constrain the model to the app's supported actions and return structured suggestions.
5. The user may accept, edit, or ignore a suggestion. A resulting plan or money movement occurs only through a normal explicit Shelby action.

### D. AI request routing

The application loads runtime configuration from Dart defines and the bundled `.env` asset. When AI consent is enabled and a Gemini key is configured, `ShellbyAiCoach` sends a bounded request directly to Gemini from the client. The coach receives an app-calculated canonical snapshot and does not decide balances, alter records, or move money. It reports unavailable or partial data rather than presenting unsupported certainty.

If Gemini is unavailable or not configured, the code can initialize a local Qwen GGUF model with `llamadart` in a Dart isolate. It copies the bundled model asset into the app-support directory before inference. However, the current `pubspec.yaml` comments out `assets/models/`; therefore the local path becomes usable only after that asset directory is declared and the model is included in the build.

### E. Reminders and device services

The user grants notification permission through the application. `ShellbyNotificationService` obtains the device timezone (falling back to `Asia/Manila`), schedules up to eight daily local reminders, and cancels/replaces the existing reminders when settings change. Android declares notification and boot-complete support so scheduled reminders can be restored by the plugin. This functionality occurs on the device; it is neither Firebase Cloud Messaging nor a server-scheduled notification system.

### F. Cooperative and community flow

1. A signed-in member explicitly enables Community before they can be discovered, send or read friend requests, interact with posts, or view social notifications. Disabling Community removes their exact-match email-directory entry and Firestore rules immediately deny further social reads and writes.
2. Friends are established through an email-exact invitation and an accepted mutual friendship document. A post is created with a fixed audience containing only the author and the friends selected at creation; a non-friend cannot read it or its replies.
3. Trusted-circle sharing is a separate opt-in. It shares only coarse standing bands such as `under_one`, `some`, or `balanced`—not balances, income, transaction history, account identifiers, or target amounts. Either party's trusted-circle opt-out removes access.
4. A decision request is sent only to current trusted-circle friends. Invited friends may select an option and add a short comment. Shelby's resulting reflection is deterministic and on-device: it summarizes vote totals and only comments whose author allowed review. It does not send private financial records or community comments to Gemini, and the user retains the final decision.
5. Anonymous peer benchmarks are a third, separate opt-in. Each contribution has a random pseudonymous identifier and categorical bands only. A benchmark becomes eligible only when at least three opted-in contributions exist in the same cohort and month.

## 4. Data stores, ownership, and trust boundaries

| Boundary or store | Current implementation | Data and responsibility |
| --- | --- | --- |
| On-device runtime memory | `AppState` | Active user profile, balances, transactions, labels, goals, derived display values, and UI state while the application is running. |
| Cloud Firestore | Private `profiles/{uid}` plus consented cooperative collections | The profile document holds the persisted Shelby profile map, including onboarding/consent data, ledgers, manual transactions, label rules, goal configuration, linked-account metadata, and the serialized FakeMaya link. Separate social collections hold only explicitly shared display snapshots, fixed audiences, friend relationships, decision responses, and anonymous categorical benchmark bands. |
| Firebase Authentication | Firebase Auth plus Google Sign-In | Email/password account identity and Google identity federation. It supplies the UID used by the Firestore profile. |
| FakeMaya Supabase service | External demonstration provider | Provider authentication/session refresh, wallet state, transaction summaries, linked savings/time-deposit/personal-goal buckets, and linked-account transfers. It is not part of Firebase or Cloud Firestore. |
| CoinGecko | External public market-data API | PHP-denominated BTC and NVDA price/price-change lookups used when the app refreshes investment prices. |
| Device file storage | Application-support directory | A copied local GGUF model only when the Qwen fallback is bundled and invoked. It is not used as a general local profile database. |

## 5. Architecture claims to revise in the paper

The following wording keeps the paper aligned with the repository:

- Describe Shelby as a **Flutter client with managed Firebase services and optional third-party integrations**, not as a collection of independently deployed backend modules.
- Describe Firestore as a **single user-owned profile document** that serializes the current prototype state, rather than as separate normalized transaction, budget, goal, and analytics collections.
- Identify **FakeMaya** as the optional demonstration e-wallet/provider integration. Do not describe a live commercial e-wallet, bank connection, or universal financial-data aggregator.
- Include **manual transaction recording** as a complete first-class collection route. Linking FakeMaya is not a precondition for using the application.
- Include **transaction labelling** between data collection and insight generation, because the insight logic relies on labelled, non-excluded transactions.
- Identify the configured **direct Gemini route** as the implemented AI connection. Do not claim a Firebase HTTPS proxy, Secret Manager, Cloud Function, or paid server-side AI component.
- Identify **local Qwen** as implemented fallback code that requires the model asset to be enabled in `pubspec.yaml` to operate in a shipped build.
- Include **CoinGecko** when describing investment price refreshes.
- Describe reminders as **local device notifications**. Do not claim server-side push notifications, a messaging service, or an event queue.
- Include the implemented cooperative features: exact-match friend invitations, audience-limited posts and replies, explicit trusted-circle standing bands, decision requests with invited responses, and anonymous three-member cohort benchmarks. State that they are protected by independent Community, trusted-circle, and benchmark consent controls in both the client and Firestore rules.
- Describe "Shelby's reflection" on a community decision as an **on-device deterministic summary of votes and explicitly permitted comments**. Do not claim that Gemini receives community content or private financial context for this feature.

## 6. Paper-ready architecture description

Shelby is implemented as a Flutter mobile application for Android and iOS. The application presents onboarding, transaction collection, wallet, goals, insights, and conversational guidance through a single client application. Its central `AppState` object coordinates user financial information, selected goal actions, manual and linked transactions, labels, funds, and balances, and publishes updates to the interface through `AppScope`. The reflection layer derives insight and progress measures in the client from the current labelled transaction and fund data.

Firebase provides the managed identity and persistence layer. Users authenticate through Firebase Authentication using email/password or Google Sign-In, and Shelby stores each user's private persisted prototype state in Firestore at `profiles/{uid}`, protected by UID-based security rules. The same Firestore project contains a separate, consent-gated cooperative data boundary for friend invitations, audience-limited posts and replies, trusted-circle standing bands, decision requests, and anonymous benchmark contributions. It never exposes private balances, income, transactions, or account identifiers through those cooperative records.

Cooperative participation is optional and independently controlled. Community opt-out removes email discoverability and blocks social access at the rules boundary; trusted-circle sharing permits only coarse categorical standing bands; and anonymous benchmarks require a separate opt-in and become meaningful at three or more participants in the same cohort. Decision feedback lets trusted friends vote and comment, after which Shelby gives an on-device deterministic reflection of the vote totals and only comments that were permitted for review. The user, rather than Shelby or the community, makes the final financial action.

Gemini guidance uses a bounded, configured direct route in the current deployment. No Firebase HTTPS Function, Secret Manager integration, or other paid server-side AI component is part of the implemented system.

Financial data can be collected manually or, with explicit user consent, from the optional FakeMaya demonstration provider. Shelby refreshes selected provider accounts and transactions, lets users label and classify the records, and uses the resulting data to update goal progress and insights. User-triggered allocations can update a linked FakeMaya goal bucket when available; otherwise Shelby maintains the corresponding local goal balance. Local reminders are scheduled directly on the device, and investment-price refreshes call CoinGecko. The code also contains a local Qwen inference fallback, which requires the GGUF asset to be included in the application build.

## 7. Repository evidence used for this architecture

| Evidence | What it establishes |
| --- | --- |
| `lib/main.dart` | Bootstrap order, runtime configuration, single-library `part` structure, Firebase initialization, direct Gemini configuration, and Qwen asset path. |
| `lib/core/app_state.dart` and `lib/core/app_scope.dart` | Central state ownership, profile restoration/persistence, manual transactions, transaction labels, FakeMaya linking/refresh, allocation logic, and UI notification mechanism. |
| `lib/features/auth/auth_screens.dart`, `lib/features/preparation/`, and `lib/features/home/` | Authentication/onboarding entry flow and the implemented UI areas. |
| `lib/services/firebase_profile_service.dart` and `firestore.rules` | Firebase Auth/Firestore profile access, consent enforcement, social audience restrictions, trusted-circle privacy, and anonymous-benchmark authorization. |
| `lib/core/community_state.dart`, `lib/services/community_service.dart`, `lib/services/cooperative_service.dart`, and `lib/features/community/` | Friend invitations, social feed and replies, notifications, explicit sharing, decision feedback, deterministic reflection, and benchmark aggregation. |
| `lib/services/fakemaya_service.dart` | Supabase-based FakeMaya connection, account operations, and CoinGecko price requests. |
| `lib/services/integration_service.dart` | Client-side records, metrics, and the dependence of insights on labelled data. |
| `lib/services/shellby_ai_coach.dart` | Bounded Gemini orchestration, direct client configuration, canonical calculation context, consent gating, and error handling. |
| `lib/services/notification_service.dart` and `android/app/src/main/AndroidManifest.xml` | On-device reminder scheduling, permissions, timezone handling, and Android receivers. |
| `pubspec.yaml` | Declared packages/assets and the currently disabled `assets/models/` declaration. |
