# Community and Cooperative Verification Evidence

**Verification date:** 2026-11-08  
**Firebase project:** `shelby-1b1d8`  
**Scope:** deployed Cloud Firestore rules and the Shelby community/cooperative client flows.

## What was verified

Three temporary, isolated Firebase email/password QA accounts were created for each production-boundary check and removed afterwards. Their temporary profile, directory, social, decision, snapshot, and benchmark records were also removed. The checks used the deployed Firestore project, not the in-memory community backend.

| Area | Result | Evidence |
| --- | --- | --- |
| Deployed Firestore rules | Passed | `firebase deploy --only firestore:rules --project shelby-1b1d8` compiled and released the active ruleset. |
| Friend invitation and acceptance | Passed | A request from one QA account to another was accepted atomically into a friendship; the two members could read it and an unrelated third account received `PERMISSION_DENIED`. |
| Community posts and replies | Passed | A permitted friend could read a friends-only post, react, and add a reply. The author could read the reply; the unrelated account was denied access to both the post and reply. |
| Trusted-circle privacy | Passed | A friend could read an opted-in owner's coarse standing snapshot. A non-friend was denied. Switching the owner's trusted-circle consent off immediately denied the prior friend. |
| Decision feedback | Passed | An invited friend submitted an option and a permitted comment. The decision author could read it; the unrelated account was denied the decision. |
| Community consent revocation | Passed | After the author switched Community off, a former permitted friend was immediately denied the existing post at the Firestore rules boundary. |
| Anonymous benchmark threshold | Passed | Three separately opted-in QA accounts wrote only categorical bands into one temporary cohort. An opted-in member could query all three contributions; a non-opted-in account was denied. |
| Client regression suite | Passed | `flutter test --no-pub test/community_test.dart test/cooperative_settings_test.dart` completed with 37 passing tests. |

## Privacy assertions demonstrated

- Community, trusted-circle, and anonymous-benchmark participation are separate opt-ins.
- Social records are audience/friend limited; unrelated authenticated users cannot read them.
- Revoking Community consent blocks social access even if a modified client attempts a direct Firestore read.
- Revoking trusted-circle sharing removes a friend's access to the owner's snapshot.
- Benchmark records hold a random pseudonymous document ID and coarse categorical bands only. They do not store balances, income, transaction history, account identifiers, or a Firebase UID.
- The cohort threshold is three; the interface should describe results as unavailable until that threshold has been reached.

## Accurate scope statement for the paper

The decision-feedback feature is implemented as privacy-preserving cooperative support: friends may vote and add a short comment, and Shelby produces an **on-device deterministic reflection** from the vote totals and only comments whose author allowed review. It deliberately does not transmit private financial records or community comments to Gemini. The user makes the final decision and any resulting financial action.

## Presentation/UAT note

These results verify the deployed authorization boundary with real Firebase accounts. For a panel demonstration, repeat the same path visibly with three participant accounts on separate devices or browser sessions and capture screenshots of the consent switches, denied access after revocation, the three-member benchmark threshold, and the final user-owned action. That is presentation evidence, not an unimplemented code dependency.
