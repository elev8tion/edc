/// Subscription Service
/// Manages premium subscription state, trial period, and message limits
///
/// Trial: 3 days, 5 messages/day (15 total)
/// Premium: $35/year, 150 messages/month
///
/// Uses SharedPreferences for local persistence (privacy-first design)
/// Uses in_app_purchase for App Store/Play Store subscriptions

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  // Singleton instance
  static SubscriptionService? _instance;
  static SubscriptionService get instance {
    _instance ??= SubscriptionService._();
    return _instance!;
  }

  SubscriptionService._();

  // ============================================================================
  // CONSTANTS
  // ============================================================================

  // Product IDs (must match App Store Connect / Play Console)
  static const String premiumYearlyProductId = 'everyday_christian_premium_yearly';

  // Trial configuration
  static const int trialDurationDays = 3;
  static const int trialMessagesPerDay = 5;
  static const int trialTotalMessages = trialDurationDays * trialMessagesPerDay; // 15

  // Premium configuration
  static const int premiumMessagesPerMonth = 150;

  // SharedPreferences keys
  static const String _keyTrialStartDate = 'trial_start_date';
  static const String _keyTrialMessagesUsed = 'trial_messages_used';
  static const String _keyTrialLastResetDate = 'trial_last_reset_date';
  static const String _keyPremiumActive = 'premium_active';
  static const String _keyPremiumMessagesUsed = 'premium_messages_used';
  static const String _keyPremiumLastResetDate = 'premium_last_reset_date';
  static const String _keySubscriptionReceipt = 'subscription_receipt';

  // ============================================================================
  // PROPERTIES
  // ============================================================================

  SharedPreferences? _prefs;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _isInitialized = false;
  ProductDetails? _premiumProduct;

  // Purchase update callback
  Function(bool success, String? error)? onPurchaseUpdate;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize the service (call this on app start)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();

      // Check if in-app purchase is available
      final bool available = await _iap.isAvailable();
      if (!available) {
        developer.log('In-app purchase not available', name: 'SubscriptionService');
        _isInitialized = true;
        return;
      }

      // Load product details
      await _loadProducts();

      // Listen to purchase updates
      _purchaseSubscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _purchaseSubscription?.cancel(),
        onError: (error) => developer.log('Purchase stream error: $error', name: 'SubscriptionService'),
      );

      // Reset message counters if needed
      await _checkAndResetCounters();

      _isInitialized = true;
      developer.log('SubscriptionService initialized', name: 'SubscriptionService');
    } catch (e) {
      developer.log('Failed to initialize SubscriptionService: $e', name: 'SubscriptionService');
      _isInitialized = true; // Still mark as initialized to prevent blocking
    }
  }

  /// Load product details from App Store / Play Store
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        {premiumYearlyProductId},
      );

      if (response.notFoundIDs.isNotEmpty) {
        developer.log('Products not found: ${response.notFoundIDs}', name: 'SubscriptionService');
      }

      if (response.productDetails.isNotEmpty) {
        _premiumProduct = response.productDetails.first;
        developer.log('Loaded product: ${_premiumProduct!.id} - ${_premiumProduct!.price}',
          name: 'SubscriptionService');
      }
    } catch (e) {
      developer.log('Failed to load products: $e', name: 'SubscriptionService');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }

  // ============================================================================
  // TRIAL STATUS
  // ============================================================================

  /// Check if user is in trial period (first 3 days)
  bool get isInTrial {
    if (isPremium) return false; // Premium users are not in trial

    final trialStartDate = _getTrialStartDate();
    if (trialStartDate == null) return true; // Never started trial = can start

    final now = DateTime.now();
    final daysSinceStart = now.difference(trialStartDate).inDays;
    return daysSinceStart < trialDurationDays;
  }

  /// Check if trial has been used (started)
  bool get hasStartedTrial {
    return _getTrialStartDate() != null;
  }

  /// Check if trial has expired
  bool get hasTrialExpired {
    if (!hasStartedTrial) return false;
    return !isInTrial && !isPremium;
  }

  /// Get days remaining in trial (0 if not in trial)
  int get trialDaysRemaining {
    if (!isInTrial) return 0;

    final trialStartDate = _getTrialStartDate();
    if (trialStartDate == null) return trialDurationDays; // Not started

    final now = DateTime.now();
    final daysSinceStart = now.difference(trialStartDate).inDays;
    return (trialDurationDays - daysSinceStart).clamp(0, trialDurationDays);
  }

  /// Get trial messages used today
  int get trialMessagesUsedToday {
    if (!isInTrial) return 0;

    final lastResetDate = _prefs?.getString(_keyTrialLastResetDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // If last reset was not today, return 0
    if (lastResetDate != today) return 0;

    return _prefs?.getInt(_keyTrialMessagesUsed) ?? 0;
  }

  /// Get remaining trial messages today
  int get trialMessagesRemainingToday {
    if (!isInTrial) return 0;
    return (trialMessagesPerDay - trialMessagesUsedToday).clamp(0, trialMessagesPerDay);
  }

  /// Start trial (called on first AI message)
  Future<void> startTrial() async {
    if (hasStartedTrial) return;

    await _prefs?.setString(_keyTrialStartDate, DateTime.now().toIso8601String());
    await _prefs?.setInt(_keyTrialMessagesUsed, 0);
    await _prefs?.setString(_keyTrialLastResetDate, DateTime.now().toIso8601String().substring(0, 10));

    developer.log('Trial started', name: 'SubscriptionService');
  }

  // ============================================================================
  // PREMIUM STATUS
  // ============================================================================

  /// Check if user has active premium subscription
  bool get isPremium {
    return _prefs?.getBool(_keyPremiumActive) ?? false;
  }

  /// Get premium messages used this month
  int get premiumMessagesUsed {
    if (!isPremium) return 0;

    final lastResetDate = _prefs?.getString(_keyPremiumLastResetDate);
    final thisMonth = DateTime.now().toIso8601String().substring(0, 7); // YYYY-MM

    // If last reset was not this month, return 0
    if (lastResetDate != thisMonth) return 0;

    return _prefs?.getInt(_keyPremiumMessagesUsed) ?? 0;
  }

  /// Get remaining premium messages this month
  int get premiumMessagesRemaining {
    if (!isPremium) return 0;
    return (premiumMessagesPerMonth - premiumMessagesUsed).clamp(0, premiumMessagesPerMonth);
  }

  /// Get subscription receipt (for verification)
  String? get subscriptionReceipt {
    return _prefs?.getString(_keySubscriptionReceipt);
  }

  // ============================================================================
  // MESSAGE LIMITS
  // ============================================================================

  /// Check if user can send a message (has remaining messages)
  bool get canSendMessage {
    // Bypass limits in debug mode for testing
    developer.log('canSendMessage check: kDebugMode=$kDebugMode, isPremium=$isPremium, isInTrial=$isInTrial, trialMessagesRemainingToday=$trialMessagesRemainingToday', name: 'SubscriptionService');

    if (kDebugMode) {
      developer.log('Bypassing subscription check - debug mode', name: 'SubscriptionService');
      return true;
    }

    if (isPremium) {
      return premiumMessagesRemaining > 0;
    } else if (isInTrial) {
      return trialMessagesRemainingToday > 0;
    }
    return false;
  }

  /// Get remaining messages (trial or premium)
  int get remainingMessages {
    if (isPremium) {
      return premiumMessagesRemaining;
    } else if (isInTrial) {
      return trialMessagesRemainingToday;
    }
    return 0;
  }

  /// Get total messages used (trial or premium)
  int get messagesUsed {
    if (isPremium) {
      return premiumMessagesUsed;
    } else if (isInTrial) {
      return trialMessagesUsedToday;
    }
    return 0;
  }

  /// Consume one message (call this when sending AI message)
  Future<bool> consumeMessage() async {
    if (!canSendMessage) return false;

    try {
      if (isPremium) {
        // Consume premium message
        final used = premiumMessagesUsed + 1;
        await _prefs?.setInt(_keyPremiumMessagesUsed, used);
        await _updatePremiumResetDate();
        developer.log('Premium message consumed ($used/$premiumMessagesPerMonth)',
          name: 'SubscriptionService');
        return true;
      } else if (isInTrial) {
        // Start trial if not started
        if (!hasStartedTrial) {
          await startTrial();
        }

        // Consume trial message
        final used = trialMessagesUsedToday + 1;
        await _prefs?.setInt(_keyTrialMessagesUsed, used);
        await _updateTrialResetDate();
        developer.log('Trial message consumed ($used/$trialMessagesPerDay today)',
          name: 'SubscriptionService');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('Failed to consume message: $e', name: 'SubscriptionService');
      return false;
    }
  }

  // ============================================================================
  // PURCHASE FLOW
  // ============================================================================

  /// Get premium product details
  ProductDetails? get premiumProduct => _premiumProduct;

  /// Purchase premium subscription
  Future<void> purchasePremium() async {
    if (_premiumProduct == null) {
      onPurchaseUpdate?.call(false, 'Product not available');
      return;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: _premiumProduct!,
      );

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      developer.log('Purchase initiated', name: 'SubscriptionService');
    } catch (e) {
      developer.log('Purchase failed: $e', name: 'SubscriptionService');
      onPurchaseUpdate?.call(false, e.toString());
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      developer.log('Restore purchases initiated', name: 'SubscriptionService');
    } catch (e) {
      developer.log('Restore failed: $e', name: 'SubscriptionService');
      onPurchaseUpdate?.call(false, e.toString());
    }
  }

  /// Handle purchase updates from the store
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final PurchaseDetails purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _verifyAndActivatePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        developer.log('Purchase error: ${purchase.error}', name: 'SubscriptionService');
        onPurchaseUpdate?.call(false, purchase.error?.message);
      }

      // Complete purchase
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// Verify and activate purchase
  Future<void> _verifyAndActivatePurchase(PurchaseDetails purchase) async {
    try {
      // Save subscription receipt
      await _prefs?.setString(_keySubscriptionReceipt, purchase.verificationData.serverVerificationData);

      // Activate premium
      await _prefs?.setBool(_keyPremiumActive, true);
      await _prefs?.setInt(_keyPremiumMessagesUsed, 0);
      await _prefs?.setString(_keyPremiumLastResetDate, DateTime.now().toIso8601String().substring(0, 7));

      developer.log('Premium subscription activated', name: 'SubscriptionService');
      onPurchaseUpdate?.call(true, null);
    } catch (e) {
      developer.log('Failed to activate purchase: $e', name: 'SubscriptionService');
      onPurchaseUpdate?.call(false, e.toString());
    }
  }

  // ============================================================================
  // INTERNAL HELPERS
  // ============================================================================

  /// Get trial start date
  DateTime? _getTrialStartDate() {
    final dateString = _prefs?.getString(_keyTrialStartDate);
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }

  /// Update trial reset date (for daily message counter)
  Future<void> _updateTrialResetDate() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _prefs?.setString(_keyTrialLastResetDate, today);
  }

  /// Update premium reset date (for monthly message counter)
  Future<void> _updatePremiumResetDate() async {
    final thisMonth = DateTime.now().toIso8601String().substring(0, 7);
    await _prefs?.setString(_keyPremiumLastResetDate, thisMonth);
  }

  /// Check and reset message counters (daily for trial, monthly for premium)
  Future<void> _checkAndResetCounters() async {
    try {
      // Reset trial counter if needed (daily)
      if (isInTrial) {
        final lastResetDate = _prefs?.getString(_keyTrialLastResetDate);
        final today = DateTime.now().toIso8601String().substring(0, 10);

        if (lastResetDate != today) {
          await _prefs?.setInt(_keyTrialMessagesUsed, 0);
          await _prefs?.setString(_keyTrialLastResetDate, today);
          developer.log('Trial messages reset for new day', name: 'SubscriptionService');
        }
      }

      // Reset premium counter if needed (monthly)
      if (isPremium) {
        final lastResetDate = _prefs?.getString(_keyPremiumLastResetDate);
        final thisMonth = DateTime.now().toIso8601String().substring(0, 7);

        if (lastResetDate != thisMonth) {
          await _prefs?.setInt(_keyPremiumMessagesUsed, 0);
          await _prefs?.setString(_keyPremiumLastResetDate, thisMonth);
          developer.log('Premium messages reset for new month', name: 'SubscriptionService');
        }
      }
    } catch (e) {
      developer.log('Failed to reset counters: $e', name: 'SubscriptionService');
    }
  }

  // ============================================================================
  // DEBUG / TESTING
  // ============================================================================

  /// Clear all subscription data (for testing only)
  @visibleForTesting
  Future<void> clearAllData() async {
    await _prefs?.remove(_keyTrialStartDate);
    await _prefs?.remove(_keyTrialMessagesUsed);
    await _prefs?.remove(_keyTrialLastResetDate);
    await _prefs?.remove(_keyPremiumActive);
    await _prefs?.remove(_keyPremiumMessagesUsed);
    await _prefs?.remove(_keyPremiumLastResetDate);
    await _prefs?.remove(_keySubscriptionReceipt);
    developer.log('All subscription data cleared', name: 'SubscriptionService');
  }

  /// Manually activate premium (for testing only)
  @visibleForTesting
  Future<void> activatePremiumForTesting() async {
    await _prefs?.setBool(_keyPremiumActive, true);
    await _prefs?.setInt(_keyPremiumMessagesUsed, 0);
    await _prefs?.setString(_keyPremiumLastResetDate, DateTime.now().toIso8601String().substring(0, 7));
    developer.log('Premium activated for testing', name: 'SubscriptionService');
  }

  /// Get debug info
  Map<String, dynamic> get debugInfo {
    return {
      'isInitialized': _isInitialized,
      'isPremium': isPremium,
      'isInTrial': isInTrial,
      'hasStartedTrial': hasStartedTrial,
      'hasTrialExpired': hasTrialExpired,
      'trialDaysRemaining': trialDaysRemaining,
      'trialMessagesUsedToday': trialMessagesUsedToday,
      'trialMessagesRemainingToday': trialMessagesRemainingToday,
      'premiumMessagesUsed': premiumMessagesUsed,
      'premiumMessagesRemaining': premiumMessagesRemaining,
      'canSendMessage': canSendMessage,
      'hasProduct': _premiumProduct != null,
      'productId': _premiumProduct?.id,
      'productPrice': _premiumProduct?.price,
    };
  }
}
