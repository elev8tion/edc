# Current State

_Last updated: 2025-10-22 (UTC)_

## Build Targets
- Flutter 3.0+ application shipping to iOS, Android, and macOS; version `1.0.0+1` in `pubspec.yaml`.
- Preferred tooling: Xcode 14+ for iOS, Android Studio for Android; see `ENV_SETUP_GUIDE.md` for platform prerequisites.
- Track the most recent `flutter analyze`, `flutter test --coverage`, and manual smoke runs in `status/BUILD_STATUS.md` to keep this snapshot actionable.

## Active Feature Set
- **AI Pastoral Chat:** Gemini 2.0 Flash backed experience with daily/seasonal verse recommendations and safety filters (suicide/self-harm, abuse, hate speech).
- **Daily Verse & Devotionals:** Offline-first SQLite content; verse schedule now aligned with the 366-day database.
- **Prayer Journal & Reading Plans:** Progress tracking with streaks, theming, and Riverpod-driven state.
- **Security:** Biometric auth, local data persistence, and chat lockouts triggered when message quotas are exceeded.

## Feature Flags & Configuration
- `.env` provides `GEMINI_API_KEY`; never commit secrets. Use `.env.example` as the onboarding template.
- Debug scaffolding lives behind `kDebugMode` checks; message quota bypass remains debug-only.
- Subscription messaging counts and trial lengths are defined in `SubscriptionService` constants—coordinate changes with product before editing.

## Known Gaps / Open Work
- Subscription receipts remain unvalidated; trial cancellation states and chat history lockouts need implementation (`CURRENT_STATE_ANALYSIS.md`).
- Static analysis now clean (`flutter analyze --no-pub`): continue to monitor for new lint regressions as features land.
- Testing hygiene: broader suites (`flutter test --coverage`) not rerun yet; only `test/screens/home_screen_test.dart` verified post animation overrides.
- UI polish: ensure ListView padding fixes and paywall copy updates are verified on all breakpoints.

## Immediate Next Steps
- Validate in-flight subscription fixes, then update `docs/RECENT_DECISIONS.md` with outcomes.
- Refresh analytics of critical flows via `scripts/sync_context.sh` and attach the report to active tickets.
- Keep this document current after each release branch cut or major architectural change.
