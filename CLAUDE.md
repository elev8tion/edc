<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

---

# Everyday Christian - Implementation Decisions & Roadmap

**Date Created:** 2025-10-19
**Status:** In Progress
**Version:** 1.0

---

## Table of Contents
1. [Onboarding & Authentication Flow](#onboarding--authentication-flow)
2. [Subscription & Trial Business Logic](#subscription--trial-business-logic)
3. [Paywall & Message Limits](#paywall--message-limits)
4. [Data Persistence & Deletion](#data-persistence--deletion)
5. [Implementation Tasks](#implementation-tasks)

---

## Onboarding & Authentication Flow

### Current State (As of 2025-10-19)

**Files Examined:**
- `lib/screens/splash_screen.dart` - Entry point navigation logic
- `lib/screens/onboarding_screen.dart` - Name collection, feature preview
- `lib/core/services/preferences_service.dart` - Local data persistence
- `lib/main.dart` - App initialization

**Current Flow:**
```
App Launch → Splash Screen (3s)
  ↓
Check: hasAcceptedLegalAgreements?
  ├─ NO → Legal Agreements Screen
  └─ YES → Check: hasCompletedOnboarding?
            ├─ NO → Onboarding Screen
            └─ YES → Home Screen
```

**Onboarding Features:**
- Optional first name input (stored locally in SharedPreferences)
- Glass-morphic design matching chat input
- Responsive layout (3 breakpoints: <650px, <750px, ≥750px)
- Removed "Continue as Guest" button (all users are anonymous)
- Saves `onboarding_completed` flag

**Name Handling:**
- `saveFirstName(String)` - Stores user's first name
- `loadFirstName()` - Retrieves stored name
- `getFirstNameOrDefault()` - Returns name or "friend" as fallback
- Integrated with "Delete All Data" feature

### Decisions Made

✅ **DECISION 1:** Privacy-first onboarding
- No authentication required
- Optional name collection for personalization
- Direct navigation to home after onboarding
- All data stored locally only

✅ **DECISION 2:** Onboarding persistence
- Added `hasCompletedOnboarding()` check
- Prevents showing onboarding on every app launch
- Splash screen routes to Home if onboarding already completed

---

## Subscription & Trial Business Logic

### Current State

**Files Examined:**
- `lib/core/services/subscription_service.dart` - Trial and subscription management
- `lib/screens/paywall_screen.dart` - Upgrade prompts
- `lib/screens/chat_screen.dart` - Message sending flow
- `lib/core/providers/app_providers.dart` - Subscription providers

**Current Implementation:**
```dart
// Trial Configuration
- Trial Duration: 3 days (const int trialDurationDays = 3)
- Trial Messages: 5 per day (const int trialMessagesPerDay = 5)
- Total Trial Messages: 15 (3 days × 5 messages)

// Premium Configuration
- Price: ~$35/year (varies by region)
- Messages: 150 per month (const int premiumMessagesPerMonth = 150)

// Trial Tracking (SharedPreferences)
- _keyTrialStartDate: When trial started
- _keyTrialMessagesUsed: Messages consumed today
- _keyTrialLastResetDate: Last daily reset date

// Premium Tracking (SharedPreferences)
- _keyPremiumActive: Boolean flag
- _keySubscriptionReceipt: Base64 encoded receipt
- _keyPremiumMessagesUsed: Messages consumed this month
- _keyPremiumLastResetDate: Last monthly reset date
```

**Current Trial Logic:**
```dart
bool get isInTrial {
  if (isPremium) return false;

  final trialStartDate = _getTrialStartDate();
  if (trialStartDate == null) return true; // Never started

  final daysSinceStart = DateTime.now().difference(trialStartDate).inDays;
  return daysSinceStart < 3; // trialDurationDays
}

bool get canSendMessage {
  if (kDebugMode) return true; // Bypass in debug

  if (isPremium) {
    return premiumMessagesRemaining > 0;
  } else if (isInTrial) {
    return trialMessagesRemainingToday > 0;
  } else {
    return false; // Trial expired, not premium
  }
}
```

### Critical Issues Identified

❌ **ISSUE 1:** Trial reset abuse
- User can delete data → Get new trial
- No Apple/Google receipt validation
- Infinite free trials possible

❌ **ISSUE 2:** Subscription not restored after data deletion
- `SubscriptionService.initialize()` not called on app start
- `restorePurchases()` only called manually from paywall
- User with active $35/year subscription loses premium status after "Delete All Data"

❌ **ISSUE 3:** No expiry date tracking
- Only stores `premium_active = true` boolean
- Doesn't extract `expires_date` from receipt
- No auto-renewal status tracking
- Can't detect when subscription expires/cancels

### Business Logic Requirements (User Specified)

**Trial Behavior:**
1. **Duration:** 3 days from when user chooses to start free trial
2. **Cancellation Rules:**
   - If user cancels **anytime before end of 3rd day** → 5 messages/day **immediately revoked**, no access to AI chat
   - If user **does not cancel within 3 days** → **Automatic subscription purchase** ($35/year)
3. **Message Limits:**
   - Days 1-2: User hits 5-message limit → Show "Subscribe Now?" dialog
   - Days 1-2: User declines subscription → Can still view message history until day 3
   - Day 3: User hits 5-message limit → Show "Subscribe Now?" dialog
   - Day 3: User declines AND doesn't cancel → Automatic subscription at end of day 3
   - Day 3: User declines AND cancels → **Locked behind paywall immediately**
4. **Offline Handling:**
   - Trial expiry is based on **date started**, not online status
   - If trial expires while user offline and they didn't cancel → Automatic purchase when they come online
   - If trial expires while offline and they cancelled → Locked behind paywall on next launch

**Message Access After Trial/Cancellation:**
- ❌ **NO access** to view past chat history after trial expires
- ❌ **NO access** to send messages
- ✅ **YES access** to Bible reading, prayer journal, verse library (unlimited, locally stored)

**Automatic Subscription Trigger:**
- Only if user **does not cancel** within 3 days
- If on day 3, user runs out of 5 messages, doesn't purchase immediately, but also doesn't cancel → Automatic subscription applies

**Other Features:**
- Prayer journal: Unlimited (locally stored)
- Bible reading: Unlimited (locally stored)
- Verse library: Unlimited (locally stored)

### Decisions Made

✅ **DECISION 3:** Implement Apple/Google receipt validation
- Query App Store/Play Store for subscription status
- Extract `original_purchase_date`, `is_trial_period`, `expires_date`
- Prevent trial reset abuse by checking if Apple ID already had trial
- Respects privacy (no personal data collection by us)
- Standard practice for App Store apps

✅ **DECISION 4:** Auto-restore subscriptions on app launch
- Call `SubscriptionService.initialize()` in main.dart before app starts
- Automatically call `restorePurchases()` during initialization
- Restores premium status even after "Delete All Data"
- Queries platform (App Store/Play Store) for active subscriptions

✅ **DECISION 5:** Track subscription expiry dates
- Extract `expires_date_ms` from receipt
- Store expiry date locally for offline checking
- Store `auto_renew_status` to show appropriate messaging
- Check expiry on each app launch → Call restorePurchases() if expired

✅ **DECISION 6:** Lock chat history behind paywall after trial/cancellation
- Use same `FrostedGlassCard` design from settings screen
- Show paywall overlay on chat screen
- Block both viewing history and sending messages
- Other features (Bible, prayer journal, verses) remain unlimited

✅ **DECISION 7:** Trial expiration behavior
- Day 1-2: Hit limit → Dialog → Decline → Still view history
- Day 3: Hit limit → Dialog → Decline + Cancel → Immediate paywall lockout
- Day 3: Hit limit → Dialog → Decline + No cancel → Auto-subscribe at end of day
- Offline during trial expiry + no cancellation → Auto-subscribe on reconnection

---

## Paywall & Message Limits

### Current State

**Paywall Triggers:**
1. `chat_screen.dart:153` - When `canSendMessage` returns false
2. Shows `PaywallScreen` with `showTrialInfo` parameter
3. Returns boolean: true if user upgraded, false otherwise

**Current Messaging:**
- Trial active: "No messages remaining today"
- Trial expired: "Subscribe to continue using AI chat"

**Current Limitations:**
- Paywall only shows when **sending** message
- Can still **view** chat history after trial expires ❌
- No dialog when hitting 5-message limit ❌
- No automatic subscription logic ❌

### Decisions Made

✅ **DECISION 8:** Add message limit dialog (before paywall)
When user hits their daily/monthly limit:
```dart
Show Dialog:
  Title: "Daily Limit Reached" (trial) or "Monthly Limit Reached" (premium)
  Message: "You've used all 5 messages today. Subscribe now for 150 messages/month?"
  Actions:
    - "Subscribe Now" → Navigate to PaywallScreen
    - "Maybe Later" → Close dialog
      - Days 1-2: User can still view chat history
      - Day 3 + cancelled: Lock chat screen with paywall overlay
      - Day 3 + no cancel: Auto-subscribe logic runs
```

✅ **DECISION 9:** Chat screen lockout overlay
When trial expired or subscription cancelled:
```dart
// Overlay on chat screen
FrostedGlassCard with:
  - Lock icon
  - "AI Chat Requires Subscription"
  - "Subscribe to view your chat history and continue conversations"
  - "Subscribe Now" button → PaywallScreen
  - Semi-transparent blur effect
  - Same design as settings screen locked features
```

✅ **DECISION 10:** Update "Delete All Data" warning
Add to deletion confirmation dialog:
```
⚠️ This will delete all local data including:
• Prayer journal entries
• Chat history
• Saved verses
• Settings and preferences

Your subscription will remain active and will be
automatically restored on next app launch.
```

---

## Data Persistence & Deletion

### Current State

**Delete All Data Implementation:**
`lib/screens/settings_screen.dart:1376-1431`

```dart
Future<void> _deleteAllData() async {
  1. dbService.resetDatabase() // Clears prayer, chat, favorites
  2. prefs.clear() // ❌ Deletes EVERYTHING including subscription
  3. profileService.removeProfilePicture()
  4. Clear image cache and temp directories
}
```

**Problem:** `prefs.clear()` deletes subscription status locally, but App Store still has active subscription.

### Decisions Made

✅ **DECISION 11:** Preserve subscription across data deletion
- Don't change `prefs.clear()` behavior (user expects everything deleted)
- Instead, rely on automatic restoration via `restorePurchases()`
- Add warning to deletion dialog explaining subscription will be restored
- Source of truth is App Store/Play Store, not local storage

✅ **DECISION 12:** Trial abuse prevention
- Use Apple/Google receipt to check `original_purchase_date`
- If `is_trial_period == true` found in receipt → Mark trial as used
- Store `trial_ever_used` flag after receipt validation
- Even if user deletes data, restorePurchases() will find trial history

---

## Implementation Tasks

_Implementation tasks will be tracked here as they are executed. Each phase will be documented with file changes, code snippets, and completion status._

### Phase 1: Critical Subscription Fixes (Priority: P0)

**Status:** Not Started
**Target:** TBD

**Tasks:**
- [ ] Task 1.1: Initialize SubscriptionService on app startup
- [ ] Task 1.2: Implement receipt validation and expiry tracking
- [ ] Task 1.3: Update `_verifyAndActivatePurchase()` to extract dates

### Phase 2: Enhanced Trial & Paywall Logic (Priority: P0)

**Status:** Not Started
**Target:** TBD

**Tasks:**
- [ ] Task 2.1: Create SubscriptionStatus enum
- [ ] Task 2.2: Add message limit dialog
- [ ] Task 2.3: Update sendMessage() flow
- [ ] Task 2.4: Create chat screen paywall overlay widget

### Phase 3: Automatic Subscription Logic (Priority: P1)

**Status:** Not Started
**Target:** TBD

**Tasks:**
- [ ] Task 3.1: Add auto-subscribe check on day 3
- [ ] Task 3.2: Handle trial cancellation detection

### Phase 4: UI Polish & Error Handling (Priority: P2)

**Status:** Not Started
**Target:** TBD

**Tasks:**
- [ ] Task 4.1: Update "Delete All Data" dialog warning
- [ ] Task 4.2: Add splash screen loading state for subscription
- [ ] Task 4.3: Comprehensive error handling

---

## Notes & Considerations

### Apple/Google Platform Differences
- iOS uses StoreKit receipts (base64 JSON)
- Android uses Play Billing receipts (JWT)
- Receipt validation methods differ per platform
- Consider using `in_app_purchase` platform-specific decoders

### Privacy Compliance
- ✅ No personal data collected by us
- ✅ Apple ID/Google account tied to subscription (platform-handled)
- ✅ Receipt validation happens locally or through platform APIs
- ✅ No user tracking or analytics on our servers

### Business Considerations
- Trial-to-paid conversion rate
- Cancellation recovery messaging
- Subscription pricing optimization
- Regional pricing variations

---

**Last Updated:** 2025-10-19
**Status:** Documentation complete, ready for implementation
**Next Review:** After Phase 1 completion