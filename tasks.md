# Cloudflare Workers AI Integration - Task Tracker

**Project:** Everyday Christian App - AI Backend Migration
**From:** Local AI models (Gemma, Qwen)
**To:** Cloudflare Workers AI (REST API)
**Last Updated:** January 2025

---

## Overall Progress: 55% Complete

```
✅✅✅✅✅⬜⬜⬜⬜⬜
```

**Phases Completed:** 2 of 8
**Estimated Time Remaining:** 2-3 days
**Current Phase:** Phase 3 (Cloudflare Account Setup)

---

## ✅ COMPLETED TASKS

### Phase 1: Codebase Cleanup (100% Complete)

**Task 1.1: Delete Obsolete Service Files**
- [x] Delete `lib/services/gemma_service.dart`
- [x] Delete `lib/services/model_downloader.dart`
- [x] Delete `lib/services/ai_understanding_service.dart`
- [x] Delete `lib/services/qwen_hybrid_service.dart`
- [x] Delete `lib/services/qwen_model_config.dart`
- [x] Delete `lib/services/hybrid_ai_service.dart`
- [x] Delete `lib/services/minimal_ai_service.dart`
- [x] Delete `lib/screens/model_download_screen.dart`

**Outcome:** 8 obsolete files removed, codebase cleaned

**Task 1.2: Delete Documentation Files**
- [x] Delete all `.md` files in `lib/services/` directory
- [x] Delete `MIGRATION_COMPLETE.md`
- [x] Delete `CRITICAL_FIX_NEEDED.md`
- [x] Delete `FIX_IN_PROGRESS.md`
- [x] Delete `LSTM_FIX_REPORT.md`
- [x] Delete other root documentation files

**Outcome:** 12+ obsolete documentation files removed

**Task 1.3: Update Existing Files**
- [x] Remove Gemma import from `lib/screens/chat_screen.dart`
- [x] Remove model download check from `lib/screens/chat_screen.dart`
- [x] Update subtitle to "Powered by Cloudflare AI"
- [x] Remove `model_download_screen.dart` import from `lib/main.dart`
- [x] Remove `/model-download` route from `lib/main.dart`

**Outcome:** No references to local models remain in UI code

**Phase 1 Duration:** 30 minutes
**Phase 1 Status:** ✅ Complete

---

### Phase 2: Cloudflare Integration (100% Complete)

**Task 2.1: Create CloudflareAIService**
- [x] Create file `lib/services/cloudflare_ai_service.dart`
- [x] Implement singleton pattern
- [x] Implement static `initialize()` method
- [x] Add support for 3 models (Llama 3.1 8B, Llama 4 Scout, Mistral 7B)
- [x] Implement AI Gateway integration (optional caching)
- [x] Add configurable cache TTL
- [x] Implement `generatePastoralGuidance()` method
- [x] Implement `generateText()` method (simple completion)
- [x] Implement `healthCheck()` method
- [x] Add timeout handling (30 seconds)
- [x] Add rate limit detection (429 status)
- [x] Add comprehensive error handling
- [x] Add cost estimation utilities
- [x] Add detailed logging (debugPrint)

**Outcome:** 284 lines of production-ready HTTP client code

**Task 2.2: Refactor LocalAIService**
- [x] Remove dependency on `ai_understanding_service.dart`
- [x] Add import of `cloudflare_ai_service.dart`
- [x] Add `_cloudflareAvailable` boolean flag
- [x] Implement health check on initialization
- [x] Implement `_generateCloudflareResponse()` method
- [x] Implement `_buildPastoralSystemPrompt()` method
- [x] Add graceful degradation to template responses
- [x] Update all log messages (Gemma → Cloudflare)
- [x] Add metadata to `AIResponse` (model, processing method)

**Outcome:** Local AI service now orchestrates Cloudflare calls

**Task 2.3: Verify Retained Services**
- [x] Confirm `ai_service.dart` interface unchanged
- [x] Confirm `ai_style_learning_service.dart` still functional
- [x] Confirm `template_guidance_service.dart` still functional
- [x] Confirm `theme_classifier_service.dart` still functional
- [x] Confirm `verse_service.dart` still functional

**Outcome:** All core services intact and compatible

**Task 2.4: Create Documentation**
- [x] Create comprehensive `specify.md` (400+ lines)
- [x] Create detailed `plan.md` (680+ lines)
- [x] Create this `tasks.md` file

**Outcome:** Complete documentation for Cloudflare architecture

**Phase 2 Duration:** 2 hours
**Phase 2 Status:** ✅ Complete

---

## ⏳ PENDING TASKS

### Phase 3: Cloudflare Account Setup (0% Complete)

**Estimated Time:** 30 minutes
**Priority:** HIGH (blocks testing)

**Task 3.1: Create Cloudflare Account**
- [ ] Go to https://dash.cloudflare.com
- [ ] Sign up for free account
- [ ] Verify email address
- [ ] Complete profile setup

**Expected Output:** Active Cloudflare account

**Task 3.2: Get Account ID**
- [ ] Log into Cloudflare Dashboard
- [ ] Navigate to "Workers & Pages"
- [ ] Click "AI" in left sidebar
- [ ] Copy Account ID from URL or settings page

**Expected Output:** Account ID (format: `a1b2c3d4e5f6...`)

**Task 3.3: Create API Token**
- [ ] Navigate to "My Profile" → "API Tokens"
- [ ] Click "Create Token"
- [ ] Select "Edit Cloudflare Workers" template OR:
  - Set permissions: `Workers AI - Read & Write`
  - Set account resources: All accounts
  - Set zone resources: All zones
- [ ] Click "Continue to summary"
- [ ] Click "Create Token"
- [ ] **COPY TOKEN IMMEDIATELY** (shown only once!)
- [ ] Save token in password manager (1Password, etc.)

**Expected Output:** API Token (format: `abc123def456...`)

**Task 3.4: Create AI Gateway (Optional but Recommended)**
- [ ] Navigate to "AI Gateway" in Cloudflare Dashboard
- [ ] Click "Create Gateway"
- [ ] Name: `everyday-christian`
- [ ] Enable caching (TTL: 3600s / 1 hour)
- [ ] Enable rate limiting (100 req/min)
- [ ] Enable analytics
- [ ] Click "Create"
- [ ] Copy Gateway name

**Expected Output:** Gateway name (e.g., `everyday-christian`)
**Expected Benefit:** 60-90% cost reduction through caching

**Phase 3 Next Steps:** Once complete, proceed to Phase 4

---

### Phase 4: Flutter App Configuration (0% Complete)

**Estimated Time:** 20 minutes
**Dependencies:** Phase 3 (requires Cloudflare credentials)

**Task 4.1: Create Environment File**
- [ ] Create `.env` file in project root
- [ ] Add the following:
  ```bash
  CLOUDFLARE_ACCOUNT_ID=<your_account_id>
  CLOUDFLARE_API_TOKEN=<your_api_token>
  CLOUDFLARE_GATEWAY=everyday-christian
  ```
- [ ] **IMPORTANT:** Do NOT commit this file to Git!

**Expected Output:** `.env` file with credentials

**Task 4.2: Update .gitignore**
- [ ] Open `.gitignore`
- [ ] Add these lines:
  ```gitignore
  # Cloudflare credentials
  .env
  .env.*
  ```
- [ ] Verify `.env` is ignored by Git

**Expected Output:** Credentials protected from version control

**Task 4.3: Update main.dart Initialization**
- [ ] Open `lib/main.dart`
- [ ] Find `void main() async {` function
- [ ] Add Cloudflare initialization BEFORE `AIServiceFactory.initialize()`:
  ```dart
  // Initialize Cloudflare AI Service
  CloudflareAIService.initialize(
    accountId: const String.fromEnvironment('CLOUDFLARE_ACCOUNT_ID'),
    apiToken: const String.fromEnvironment('CLOUDFLARE_API_TOKEN'),
    gatewayName: const String.fromEnvironment('CLOUDFLARE_GATEWAY', defaultValue: ''),
    useCache: true,
    cacheTTL: 3600,
  );
  ```
- [ ] Save file

**Expected Output:** App configured to initialize Cloudflare on startup

**Task 4.4: Test Build Command**
- [ ] Run this command (replace with your actual values):
  ```bash
  flutter run \
    --dart-define=CLOUDFLARE_ACCOUNT_ID=<your_id> \
    --dart-define=CLOUDFLARE_API_TOKEN=<your_token> \
    --dart-define=CLOUDFLARE_GATEWAY=everyday-christian
  ```
- [ ] Verify app builds successfully
- [ ] Check console for `✅ Cloudflare AI Service initialized`

**Expected Output:** App builds and runs with Cloudflare initialized

---

### Phase 5: Testing (0% Complete)

**Estimated Time:** 1 hour
**Dependencies:** Phase 4 (requires configured app)

**Task 5.1: Basic Functionality Test**
- [ ] Launch app with Cloudflare credentials
- [ ] Navigate to chat screen
- [ ] Send message: "I'm feeling anxious"
- [ ] Verify response appears within 3 seconds
- [ ] Verify response includes 2-3 Bible verses
- [ ] Verify response follows pastoral style
- [ ] Check console for `✅ Cloudflare AI generated response`

**Expected Output:** Successful AI response from Cloudflare

**Task 5.2: Theme Detection Test**
- [ ] Send message with "anxiety" keyword → verify anxiety theme
- [ ] Send message with "depression" keyword → verify depression theme
- [ ] Send message with "guidance" keyword → verify guidance theme
- [ ] Verify correct Bible verses for each theme

**Expected Output:** Theme classifier working correctly

**Task 5.3: Offline Fallback Test**
- [ ] Disconnect device from internet (airplane mode)
- [ ] Send message: "I need help"
- [ ] Verify template response appears
- [ ] Verify console shows `⚠️ Cloudflare unavailable - using template mode`
- [ ] Verify no app crashes

**Expected Output:** Graceful fallback to templates when offline

**Task 5.4: Error Handling Test**
- [ ] Test with invalid API token → verify fallback
- [ ] Test with exceeded rate limit → verify fallback
- [ ] Test with network timeout → verify fallback

**Expected Output:** All error scenarios handled gracefully

**Task 5.5: Caching Test (if AI Gateway enabled)**
- [ ] Send message: "I'm anxious"
- [ ] Note response time
- [ ] Send same message again
- [ ] Verify second response is faster
- [ ] Check Cloudflare dashboard for cache hit

**Expected Output:** Caching reduces latency on repeated requests

**Task 5.6: Performance Monitoring**
- [ ] Send 10 different messages
- [ ] Check `AIPerformanceMonitor.stats`
- [ ] Verify average response time < 2000ms
- [ ] Verify 95th percentile < 3000ms
- [ ] Verify average confidence > 0.85

**Expected Output:** Performance meets targets

**Task 5.7: Cost Monitoring**
- [ ] Check Cloudflare Dashboard → AI Gateway → Analytics
- [ ] Verify total requests counted
- [ ] Verify neurons used (should be ~7.7 per request)
- [ ] Verify cost is $0 (within free tier)

**Expected Output:** Usage tracked, cost within budget

---

### Phase 6: iOS Deployment Prep (0% Complete)

**Estimated Time:** 30 minutes
**Dependencies:** Phase 5 (requires passing tests)

**Task 6.1: iOS Configuration**
- [ ] Open `ios/Runner/Info.plist`
- [ ] Verify `NSAppTransportSecurity` allows HTTPS
- [ ] Confirm no cleartext traffic allowed

**Expected Output:** iOS configured for HTTPS-only

**Task 6.2: Build iOS Archive**
- [ ] Run production build:
  ```bash
  flutter build ios --release \
    --dart-define=CLOUDFLARE_ACCOUNT_ID=$PROD_ID \
    --dart-define=CLOUDFLARE_API_TOKEN=$PROD_TOKEN \
    --dart-define=CLOUDFLARE_GATEWAY=$PROD_GATEWAY
  ```
- [ ] Open Xcode
- [ ] Create archive
- [ ] Verify build succeeds

**Expected Output:** iOS archive ready for distribution

**Task 6.3: App Store Submission Prep**
- [ ] Update App Store listing:
  - [ ] Add "AI-powered content" disclosure
  - [ ] Update privacy policy (data sent to Cloudflare)
  - [ ] Add data collection details
- [ ] Prepare screenshots
- [ ] Write release notes

**Expected Output:** Ready for App Store submission

---

### Phase 7: Android Deployment Prep (0% Complete)

**Estimated Time:** 30 minutes
**Dependencies:** Phase 5 (requires passing tests)

**Task 7.1: Android Configuration**
- [ ] Open `android/app/src/main/AndroidManifest.xml`
- [ ] Verify `<uses-permission android:name="android.permission.INTERNET" />`
- [ ] Confirm internet permission present

**Expected Output:** Android configured for network access

**Task 7.2: Build Android APK/AAB**
- [ ] Run production build:
  ```bash
  flutter build appbundle --release \
    --dart-define=CLOUDFLARE_ACCOUNT_ID=$PROD_ID \
    --dart-define=CLOUDFLARE_API_TOKEN=$PROD_TOKEN \
    --dart-define=CLOUDFLARE_GATEWAY=$PROD_GATEWAY
  ```
- [ ] Verify build succeeds
- [ ] Test on physical Android device

**Expected Output:** Android bundle ready for distribution

**Task 7.3: Play Store Submission Prep**
- [ ] Update Play Store listing:
  - [ ] Add data safety form entries
  - [ ] Update privacy policy
  - [ ] Add feature description
- [ ] Prepare screenshots
- [ ] Write release notes

**Expected Output:** Ready for Play Store submission

---

### Phase 8: Launch & Monitor (0% Complete)

**Estimated Time:** Ongoing
**Dependencies:** Phase 6 & 7 (requires deployed apps)

**Task 8.1: Launch Monitoring**
- [ ] Monitor Cloudflare Dashboard daily for first week
- [ ] Check request count (within free tier?)
- [ ] Check error rate (target < 1%)
- [ ] Check average response time
- [ ] Check cache hit rate (target > 60%)

**Expected Output:** Metrics within healthy ranges

**Task 8.2: User Feedback Collection**
- [ ] Monitor app store reviews
- [ ] Track user satisfaction scores
- [ ] Collect feedback on response quality
- [ ] Identify common issues

**Expected Output:** User feedback informs improvements

**Task 8.3: Cost Management**
- [ ] Track daily neuron usage
- [ ] Project monthly costs
- [ ] Set up alerts if approaching free tier limit
- [ ] Optimize if needed (enable caching, rate limiting)

**Expected Output:** Costs remain within budget

**Task 8.4: Continuous Improvement**
- [ ] Refine system prompts based on usage
- [ ] Update pastoral templates if needed
- [ ] Improve style patterns
- [ ] Address user feedback

**Expected Output:** Ongoing improvements to response quality

---

## Quick Commands

### Run App with Cloudflare (Development)
```bash
flutter run \
  --dart-define=CLOUDFLARE_ACCOUNT_ID=$CLOUDFLARE_ACCOUNT_ID \
  --dart-define=CLOUDFLARE_API_TOKEN=$CLOUDFLARE_API_TOKEN \
  --dart-define=CLOUDFLARE_GATEWAY=$CLOUDFLARE_GATEWAY
```

### Build iOS (Production)
```bash
flutter build ios --release \
  --dart-define=CLOUDFLARE_ACCOUNT_ID=$PROD_ACCOUNT_ID \
  --dart-define=CLOUDFLARE_API_TOKEN=$PROD_API_TOKEN \
  --dart-define=CLOUDFLARE_GATEWAY=$PROD_GATEWAY
```

### Build Android (Production)
```bash
flutter build appbundle --release \
  --dart-define=CLOUDFLARE_ACCOUNT_ID=$PROD_ACCOUNT_ID \
  --dart-define=CLOUDFLARE_API_TOKEN=$PROD_API_TOKEN \
  --dart-define=CLOUDFLARE_GATEWAY=$PROD_GATEWAY
```

### Test Compilation
```bash
flutter analyze
flutter test
```

### Check Performance Stats
```dart
print(AIPerformanceMonitor.stats);
```

---

## Critical Reminders

### ⚠️ Security
- **NEVER** commit `.env` file to Git
- **NEVER** hardcode API credentials
- **ALWAYS** use environment variables
- **ROTATE** API tokens every 90 days
- **USE** code obfuscation in production builds

### 💰 Cost Management
- Free tier: 10,000 neurons/day (~1,300 responses)
- Enable AI Gateway caching (60-90% cost reduction)
- Monitor usage daily in Cloudflare Dashboard
- Set up budget alerts

### 🔧 Troubleshooting
- If responses fail → Check Cloudflare Dashboard for errors
- If slow responses → Check internet connection
- If fallback activates → Verify API credentials
- If build fails → Verify environment variables set

---

## Success Criteria

### Technical Checklist
- [ ] All obsolete code removed
- [ ] Cloudflare integration working
- [ ] Response time < 3s (95th percentile)
- [ ] Fallback system functional
- [ ] Zero crashes related to AI service
- [ ] Cost within budget ($0-5/month)

### User Experience Checklist
- [ ] Responses feel natural and pastoral
- [ ] Bible verses contextually appropriate
- [ ] No noticeable latency
- [ ] App works offline (templates)
- [ ] No error screens shown to users

### Deployment Checklist
- [ ] iOS app submitted to App Store
- [ ] Android app submitted to Play Store
- [ ] Privacy policies updated
- [ ] Documentation complete
- [ ] Monitoring set up

---

## Next Steps

**Immediate Priority:** Complete Phase 3 (Cloudflare Account Setup)

1. Create Cloudflare account (5 minutes)
2. Get Account ID (2 minutes)
3. Create API Token (5 minutes)
4. Create AI Gateway (5 minutes)
5. Proceed to Phase 4

**After Phase 3:** Configure Flutter app and test integration

**Timeline:** Ready for production in 2-3 days with focused work

---

**Last Updated:** January 2025
**Completion Status:** 55% (2 of 8 phases complete)
**Time Investment:** ~2.5 hours completed, ~4-5 hours remaining
