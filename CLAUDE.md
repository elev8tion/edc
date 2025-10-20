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

**Date Created:** 2025-01-19
**Last Updated:** 2025-01-19
**Status:** In Progress - Comprehensive Analysis Complete
**Version:** 2.0

---

## Table of Contents
1. [Onboarding & Authentication Flow](#onboarding--authentication-flow)
2. [Subscription & Trial Business Logic](#subscription--trial-business-logic)
3. [Paywall & Message Limits](#paywall--message-limits)
4. [Data Persistence & Deletion](#data-persistence--deletion)
5. [Implementation Roadmap](#implementation-roadmap)

---

## Onboarding & Authentication Flow

### Current State (As of 2025-01-19)

**Files Examined:**
- `lib/screens/splash_screen.dart` (288 lines) - Entry point navigation logic
- `lib/screens/onboarding_screen.dart` (289 lines) - Name collection, feature preview
- `lib/core/services/preferences_service.dart` - Local data persistence
- `lib/main.dart` (250 lines) - App initialization
- `lib/core/providers/app_providers.dart` (866+ lines) - Provider setup

**Current Flow:**
```
App Launch → Splash Screen (3s)
  ↓
AppInitializer checks app_providers.dart:177-197
  ├─ Database initialization
  ├─ Notification service setup
  ├─ ✅ Subscription service initialization (line 186)
  └─ Bible data loading
  ↓
splash_screen.dart:51-84
Check: hasAcceptedLegalAgreements?
  ├─ NO → Legal Agreements Screen
  └─ YES → Check: hasCompletedOnboarding?
            ├─ NO → Onboarding Screen (line 74)
            └─ YES → Home Screen (line 81)
```

**Onboarding Features:**
- Optional first name input (stored locally in SharedPreferences)
- Glass-morphic design matching chat input (onboarding_screen.dart:148-187)
- Responsive layout (3 breakpoints: <650px, <750px, ≥750px)
- Removed "Continue as Guest" button (all users are anonymous)
- Saves `onboarding_completed` flag via `PreferencesService.setOnboardingCompleted()` (line 208)

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
- Added `hasCompletedOnboarding()` check in splash_screen.dart:68
- Prevents showing onboarding on every app launch
- Splash screen routes to Home if onboarding already completed

---

## Subscription & Trial Business Logic

### Current State

**Files Examined:**
- `lib/core/services/subscription_service.dart` (485 lines) - Trial and subscription management
- `lib/screens/paywall_screen.dart` (460 lines) - Upgrade prompts
- `lib/screens/chat_screen.dart` (1792 lines) - Message sending flow
- `lib/core/providers/app_providers.dart` (866+ lines) - Subscription providers
- `lib/main.dart` (250 lines) - App initialization

**Current Implementation:**
```dart
// Trial Configuration (subscription_service.dart:34-36)
- Trial Duration: 3 days (const int trialDurationDays = 3)
- Trial Messages: 5 per day (const int trialMessagesPerDay = 5)
- Total Trial Messages: 15 (3 days × 5 messages)

// Premium Configuration (subscription_service.dart:39)
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

**Initialization Status:**
✅ **CONFIRMED:** `SubscriptionService.initialize()` IS called on app startup
- Location: `lib/core/providers/app_providers.dart:180-186`
- Called via `appInitializationProvider` which runs before app renders
- Order: Database → Notifications → **Subscription** → Bible loading
- However: `restorePurchases()` is NOT automatically called during initialization

**Current Trial Logic:**
```dart
// subscription_service.dart:136-145
bool get isInTrial {
  if (isPremium) return false;

  final trialStartDate = _getTrialStartDate();
  if (trialStartDate == null) return true; // Never started

  final daysSinceStart = DateTime.now().difference(trialStartDate).inDays;
  return daysSinceStart < 3; // trialDurationDays
}

// subscription_service.dart:238-253
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

**Current Chat Flow:**
```dart
// chat_screen.dart:143-193
Future<void> sendMessage(String text) async {
  // 1. Check subscription (line 147-150)
  final canSend = subscriptionService.canSendMessage;

  if (!canSend && !kDebugMode) {
    // 2. Show paywall (chat_screen.dart:156-178)
    final result = await Navigator.push(PaywallScreen(...));
    if (result != true) {
      // User didn't upgrade - show snackbar and return
      return;
    }
  }

  // 3. Consume message (chat_screen.dart:181-192)
  final consumed = await subscriptionService.consumeMessage();

  // 4. Send message to AI
  // ...
}
```

### Critical Issues Identified

❌ **ISSUE 1:** Trial reset abuse
- User can delete data → Get new trial
- No Apple/Google receipt validation
- Infinite free trials possible
- `_verifyAndActivatePurchase()` doesn't check `is_trial_period` or `original_purchase_date`

❌ **ISSUE 2:** No automatic purchase restoration
- `restorePurchases()` NOT called during `initialize()` (subscription_service.dart:69-102)
- Only called manually when user clicks "Restore Purchases" in paywall (paywall_screen.dart:415-449)
- User with active $35/year subscription loses premium status after "Delete All Data"

❌ **ISSUE 3:** No expiry date tracking
- Only stores `premium_active = true` boolean (subscription_service.dart:373)
- Doesn't extract `expires_date` from receipt
- No auto-renewal status tracking
- Can't detect when subscription expires/cancels

❌ **ISSUE 4:** No chat history lockout after trial expires
- chat_screen.dart:143-178 only blocks SENDING messages
- User can still VIEW all past chat history after trial expires
- No paywall overlay on chat screen

❌ **ISSUE 5:** No message limit dialog
- When user hits 5-message limit, immediately shows full paywall
- No friendly "Daily Limit Reached" dialog with "Subscribe Now?" / "Maybe Later" options
- Business requirement: Days 1-2 should allow viewing history after decline

❌ **ISSUE 6:** No automatic subscription logic
- No check for "end of day 3 + no cancellation"
- No automatic purchase trigger implementation
- No cancellation detection

### Business Logic Requirements (User Specified)

**Trial Behavior:**
1. **Duration:** 3 days from when user chooses to start free trial (currently: first message)
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

✅ **DECISION 4:** Subscription IS already initialized on app launch ✅
- `SubscriptionService.initialize()` IS called in app_providers.dart:186
- However, `restorePurchases()` is NOT called automatically during initialization
- Need to add `await restorePurchases()` to `initialize()` method
- This will restore premium status even after "Delete All Data"

✅ **DECISION 5:** Track subscription expiry dates
- Extract `expires_date_ms` from receipt
- Store expiry date locally for offline checking
- Store `auto_renew_status` to show appropriate messaging
- Check expiry on each app launch → Call restorePurchases() if expired

✅ **DECISION 6:** Lock chat history behind paywall after trial/cancellation
- Use same `FrostedGlassCard` design from settings screen locked features
- Show paywall overlay on chat screen when trial expired or cancelled
- Block both viewing history and sending messages
- Other features (Bible, prayer journal, verses) remain unlimited

✅ **DECISION 7:** Add message limit dialog before paywall
- When user hits daily/monthly limit, show dialog first
- Dialog: "Daily Limit Reached" / "Monthly Limit Reached"
- Actions: "Subscribe Now" or "Maybe Later"
- Days 1-2: Decline allows viewing history
- Day 3 + cancelled: Immediate lockout
- Day 3 + no cancel: Auto-subscribe logic runs

✅ **DECISION 8:** Trial expiration behavior
- Day 1-2: Hit limit → Dialog → Decline → Still view history
- Day 3: Hit limit → Dialog → Decline + Cancel → Immediate paywall lockout
- Day 3: Hit limit → Dialog → Decline + No cancel → Auto-subscribe at end of day
- Offline during trial expiry + no cancellation → Auto-subscribe on reconnection

---

## Paywall & Message Limits

### Current State

**Paywall Triggers:**
1. chat_screen.dart:153-178 - When `canSendMessage` returns false
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

✅ **DECISION 9:** Add message limit dialog (before paywall)
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

✅ **DECISION 10:** Chat screen lockout overlay
When trial expired or subscription cancelled:
```dart
// Overlay on chat screen (similar to settings_screen.dart:1352-1373)
FrostedGlassCard with:
  - Lock icon
  - "AI Chat Requires Subscription"
  - "Subscribe to view your chat history and continue conversations"
  - "Subscribe Now" button → PaywallScreen
  - Semi-transparent blur effect
  - Same design as settings screen locked features
```

✅ **DECISION 11:** Update "Delete All Data" warning
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

**Problem:**
- `prefs.clear()` (line 1382) deletes subscription status locally
- App Store still has active subscription
- User loses premium status until they manually call "Restore Purchases"

### Decisions Made

✅ **DECISION 12:** Preserve subscription across data deletion
- Don't change `prefs.clear()` behavior (user expects everything deleted)
- Instead, rely on automatic restoration via `restorePurchases()` in `initialize()`
- Add warning to deletion dialog explaining subscription will be restored
- Source of truth is App Store/Play Store, not local storage

✅ **DECISION 13:** Trial abuse prevention
- Use Apple/Google receipt to check `original_purchase_date`
- If `is_trial_period == true` found in receipt → Mark trial as used
- Store `trial_ever_used` flag after receipt validation
- Even if user deletes data, `restorePurchases()` will find trial history

---

## Implementation Roadmap

### Phase 1: Critical Subscription Fixes (Priority: P0)

**Status:** Not Started

**Objective:** Fix subscription restoration and prevent data loss

**Tasks:**

**Task 1.1: Auto-restore purchases on app launch**
- File: `lib/core/services/subscription_service.dart`
- Modify: `initialize()` method (line 69-102)
- Add: `await restorePurchases()` after `_loadProducts()` (around line 90)
- This ensures premium status is restored even after "Delete All Data"

**Task 1.2: Extract and store expiry dates from receipts**
- File: `lib/core/services/subscription_service.dart`
- Modify: `_verifyAndActivatePurchase()` (line 367-383)
- Add: Receipt decoding logic to extract:
  - `expires_date_ms` → Store as `_keyPremiumExpiryDate`
  - `original_purchase_date` → Store as `_keyPremiumOriginalPurchaseDate`
  - `is_trial_period` → Store as `_keyTrialEverUsed`
  - `auto_renew_status` → Store as `_keyAutoRenewStatus`
- Add new SharedPreferences keys after line 48:
```dart
static const String _keyPremiumExpiryDate = 'premium_expiry_date';
static const String _keyPremiumOriginalPurchaseDate = 'premium_original_purchase_date';
static const String _keyTrialEverUsed = 'trial_ever_used';
static const String _keyAutoRenewStatus = 'auto_renew_status';
```

**Task 1.3: Check expiry on app launch**
- File: `lib/core/services/subscription_service.dart`
- Modify: `initialize()` to check stored expiry date
- If expired → Call `restorePurchases()` to check for renewal
- Update `isPremium` getter (line 205) to check expiry date

**Expected Outcome:**
- User deletes all data → Subscription auto-restores on next launch ✅
- User's Apple ID trial history is tracked → Prevents infinite trials ✅
- Subscription expiry is tracked → App knows when to re-check store ✅

---

### Phase 2: Enhanced Trial & Paywall Logic (Priority: P0)

**Status:** Not Started

**Objective:** Implement business-critical trial expiration, message limits, and paywall lockouts

**Tasks:**

**Task 2.1: Create SubscriptionStatus enum**
- File: `lib/core/services/subscription_service.dart`
- Add after constants (line 48):
```dart
enum SubscriptionStatus {
  neverStarted,      // Brand new user, no trial started
  inTrial,           // Days 1-3 of trial
  trialExpired,      // Trial used, not subscribed
  premiumActive,     // Paid subscriber with active subscription
  premiumCancelled,  // Cancelled but still has time remaining
  premiumExpired     // Subscription fully expired
}
```

**Task 2.2: Add `getSubscriptionStatus()` method**
- File: `lib/core/services/subscription_service.dart`
- Add new method after `isPremium` getter:
```dart
SubscriptionStatus getSubscriptionStatus() {
  // Check if premium first
  if (isPremium) {
    final expiryDate = _getExpiryDate();
    final autoRenew = _prefs?.getBool(_keyAutoRenewStatus) ?? true;

    if (expiryDate != null && DateTime.now().isAfter(expiryDate)) {
      return SubscriptionStatus.premiumExpired;
    } else if (!autoRenew) {
      return SubscriptionStatus.premiumCancelled;
    } else {
      return SubscriptionStatus.premiumActive;
    }
  }

  // Check trial status
  if (!hasStartedTrial) {
    return SubscriptionStatus.neverStarted;
  }

  if (isInTrial) {
    return SubscriptionStatus.inTrial;
  } else {
    return SubscriptionStatus.trialExpired;
  }
}
```

**Task 2.3: Add message limit dialog**
- File: Create new `lib/components/message_limit_dialog.dart`
- Design: Match existing glass theme (use `FrostedGlassCard`, `GlassButton`)
- Parameters: `isPremium`, `remainingMessages`, `onSubscribePressed`, `onMaybeLaterPressed`
- Dialog content:
  - Title: "Daily Limit Reached" (trial) or "Monthly Limit Reached" (premium)
  - Message: "You've used all 5 messages today. Subscribe now for 150 messages/month?"
  - Actions: "Subscribe Now" / "Maybe Later"

**Task 2.4: Update `sendMessage()` flow in chat screen**
- File: `lib/screens/chat_screen.dart`
- Modify: `sendMessage()` method (line 143-193)
- New flow:
```dart
Future<void> sendMessage(String text) async {
  final subscriptionService = ref.read(subscriptionServiceProvider);
  final status = subscriptionService.getSubscriptionStatus();

  // 1. Check if user is locked out (trial expired or premium expired)
  if (status == SubscriptionStatus.trialExpired ||
      status == SubscriptionStatus.premiumExpired) {
    // Show paywall - NO messaging allowed
    _showPaywall();
    return;
  }

  // 2. Check if user has messages remaining
  if (!subscriptionService.canSendMessage()) {
    // Show dialog first (before paywall)
    final shouldShowPaywall = await _showMessageLimitDialog();

    if (shouldShowPaywall) {
      // User clicked "Subscribe Now"
      final upgraded = await _showPaywall();
      if (!upgraded) return; // Didn't upgrade, don't send
    } else {
      // User clicked "Maybe Later"
      // Days 1-2: Can still view history (just return)
      // Day 3 + cancelled: Will be handled by chat screen lockout check
      return;
    }
  }

  // 3. Consume message credit
  final consumed = await subscriptionService.consumeMessage();
  if (!consumed) return;

  // 4. Send message to AI
  // ...
}
```

**Task 2.5: Create chat screen paywall overlay widget**
- File: Create new `lib/components/chat_screen_lockout_overlay.dart`
- Design: Use same frosted glass design from settings screen (settings_screen.dart:1352-1373)
- Content:
  - Lock icon
  - Title: "AI Chat Requires Subscription"
  - Message: "Subscribe to view your chat history and continue conversations"
  - Button: "Subscribe Now" → Navigate to PaywallScreen
- Usage: Wrap chat screen ListView with Stack + conditional overlay

**Task 2.6: Add lockout check to chat screen**
- File: `lib/screens/chat_screen.dart`
- Modify: `build()` method (line 41)
- Add at top of widget tree (in Stack):
```dart
// Check subscription status for chat lockout
final subscriptionService = ref.watch(subscriptionServiceProvider);
final status = subscriptionService.getSubscriptionStatus();

if (status == SubscriptionStatus.trialExpired ||
    status == SubscriptionStatus.premiumExpired) {
  return ChatScreenLockoutOverlay(
    onSubscribePressed: () {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PaywallScreen(showTrialInfo: false),
      ));
    },
  );
}
```

**Expected Outcome:**
- User hits message limit → Sees friendly dialog first ✅
- Days 1-2: Decline dialog → Can still view history ✅
- Day 3 + trial expired → Chat screen is locked with overlay ✅
- Premium expired → Chat screen is locked with overlay ✅

---

### Phase 3: Automatic Subscription Logic (Priority: P1)

**Status:** Not Started

**Objective:** Implement automatic subscription purchase on day 3 if user doesn't cancel

**Tasks:**

**Task 3.1: Add auto-subscribe check on day 3**
- File: `lib/core/services/subscription_service.dart`
- Add new method:
```dart
Future<bool> shouldAutoSubscribe() async {
  // Only applies to trial users on day 3
  if (!isInTrial || trialDaysRemaining != 0) return false;

  // Check if user has cancelled
  // This requires querying App Store/Play Store for cancellation status
  // Implementation TBD based on platform-specific APIs

  return true; // Auto-subscribe if not cancelled
}
```

**Task 3.2: Handle trial cancellation detection**
- Research: How to detect if user cancelled trial via App Store/Play Store
- Implementation: Platform-specific cancellation checking
- Note: This may require server-side receipt validation for real-time detection

**Expected Outcome:**
- Day 3 + no cancellation → Automatic subscription triggered ✅
- Day 3 + cancellation → Immediate lockout ✅

**Note:** This phase may require additional research into Apple/Google APIs for cancellation detection

---

### Phase 4: UI Polish & Error Handling (Priority: P2)

**Status:** Not Started

**Objective:** Improve user experience and handle edge cases

**Tasks:**

**Task 4.1: Update "Delete All Data" dialog warning**
- File: `lib/screens/settings_screen.dart`
- Modify: `_showDeleteConfirmation()` method (around line 1300)
- Add to dialog content:
```
⚠️ This will delete all local data including:
• Prayer journal entries
• Chat history
• Saved verses
• Settings and preferences

Your subscription will remain active and will be
automatically restored on next app launch.
```

**Task 4.2: Add loading state to splash screen for subscription check**
- File: `lib/screens/splash_screen.dart`
- Show "Restoring subscription..." message during initialization
- Handle errors gracefully (network issues, etc.)

**Task 4.3: Comprehensive error handling**
- Add try-catch blocks around all subscription service methods
- User-friendly error messages
- Fallback behaviors when network unavailable

**Expected Outcome:**
- Users understand subscription is preserved after data deletion ✅
- Graceful handling of network errors and edge cases ✅
- Professional error messaging throughout app ✅

---

## Testing Checklist

### Trial & Subscription Flow
- [ ] New user starts trial → 3 days, 5 messages/day
- [ ] User deletes data during trial → Trial persists on relaunch
- [ ] User deletes data after subscribing → Subscription auto-restores
- [ ] User hits message limit Day 1 → Dialog appears → "Maybe Later" → Can view history
- [ ] User hits message limit Day 2 → Dialog appears → "Maybe Later" → Can view history
- [ ] User hits message limit Day 3 → Dialog appears → "Maybe Later" → Still can send (until end of day)
- [ ] Trial expires → Chat screen shows lockout overlay
- [ ] Trial expires → Bible, prayer, verses still accessible

### Paywall & Lockout
- [ ] Trial expired user opens chat → Sees lockout overlay
- [ ] Lockout overlay "Subscribe Now" → Opens PaywallScreen
- [ ] PaywallScreen purchase success → Lockout removed
- [ ] PaywallScreen "Restore Purchases" → Works correctly

### Receipt Validation
- [ ] Purchase receipt decoded correctly
- [ ] Expiry date extracted and stored
- [ ] Trial history tracked per Apple ID
- [ ] User can't get infinite trials by deleting data

### Edge Cases
- [ ] App offline during trial expiry → Handled on next launch
- [ ] App offline during subscription expiry → Handled on next launch
- [ ] User switches devices → Subscription restores via receipt
- [ ] Receipt validation fails → Graceful error handling

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
- Trial-to-paid conversion rate optimization
- Cancellation recovery messaging
- Subscription pricing optimization
- Regional pricing variations
- FTC compliance for subscription disclosures

---

**Last Updated:** 2025-01-19
**Status:** Documentation complete, ready for implementation
**Next Review:** After Phase 1 completion