# Shellby Web QA

## Launch

Run the browser QA mode from the repository root:

```bash
./scripts/run_web_qa.sh
```

It is equivalent to:

```bash
flutter run -d chrome --web-hostname 127.0.0.1 \
  --dart-define=SHELLBY_WEB_QA=true
```

QA mode is available only in a debug Flutter Web build with the explicit
`SHELLBY_WEB_QA=true` flag. It does not initialize Firebase, authenticate a
user, write a Firebase profile, or call FakeMaya.

To test the original Welcome, Login, and Create account flows instead, omit
the QA flag:

```bash
flutter run -d chrome --web-hostname 127.0.0.1
```

This normal Web mode initializes the existing Firebase configuration and uses
the existing Firebase email/password and Google login widgets. Live FakeMaya
uses browser HTTP and therefore requires the FakeMaya/Supabase environment to
allow the local origin through CORS. Do not use production credentials for QA.

## Demo profiles

The opening **Shellby Web QA** screen uses the existing `AppState` seed
methods. Select one of Cash Flow, Emergency Fund, Investments, Lifestyle, or
Combined Goals. Select **Fresh Onboarding** to use the existing onboarding
forms. Reload the browser to reset the isolated, in-memory session.

All financial balances, allocations, goals, and M1–M4 action scores are
calculated by the existing application logic. The QA launcher does not hardcode
scores or displayed balances.

## Supported QA scope

- Existing Dashboard, Financial Pyramid, Goals, Insights, Wallet, Recent
  Activity, transaction details/categorization, and onboarding widgets.
- Existing demo transactions, score dialogs, and simulated fund/ledger actions.
- In-memory profile changes for the current browser session.

## Intentionally unavailable in Web QA

- Firebase authentication and Firestore profile persistence.
- Live FakeMaya authentication and account synchronization in QA mode.
- Local Llama AI, notifications, native filesystem persistence, and OS
  permissions.
- Direct Gemini calls: `.env` is deliberately not bundled into Web assets.

The simulated profile uses the normal local `AppState` balances and ledgers;
therefore transfer validation and insufficient-balance rules still apply.

## Browser automation

Use a Chromium-compatible runner against the local Flutter dev server. Flutter
renders many controls through Canvas, so enable Flutter Semantics and target
the accessible labels, including **Open Cash Flow demo profile**. Verify each
automation workflow against the running app before relying on it.
