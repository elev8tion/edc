/// Paywall Screen
/// Shown when trial expires or when user needs to upgrade to premium
///
/// Displays:
/// - Trial status or expired message
/// - Premium features list
/// - Pricing ($35/year, 150 messages/month)
/// - Purchase and restore buttons

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/glass_button.dart';
import '../components/glass_section_header.dart';
import '../components/category_badge.dart';
import '../theme/app_theme.dart';
import '../core/providers/app_providers.dart';
import '../core/services/subscription_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  /// Optional: show trial info (true) or expired message (false)
  final bool showTrialInfo;

  const PaywallScreen({
    Key? key,
    this.showTrialInfo = true,
  }) : super(key: key);

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final subscriptionService = ref.watch(subscriptionServiceProvider);
    final isInTrial = ref.watch(isInTrialProvider);
    final trialDaysRemaining = ref.watch(trialDaysRemainingProvider);
    final premiumProduct = subscriptionService.premiumProduct;

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.primaryText,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  pinned: false,
                ),

                // Content
                SliverPadding(
                  padding: AppSpacing.screenPadding,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Header Icon
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.goldColor.withValues(alpha: 0.6),
                              width: 3,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.workspace_premium,
                            size: 50,
                            color: AppTheme.goldColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Title
                      Text(
                        'Everyday Christian\nPremium',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Subtitle - Trial or Expired
                      if (widget.showTrialInfo && isInTrial)
                        Center(
                          child: CategoryBadge(
                            text: '$trialDaysRemaining days left in trial',
                            icon: Icons.schedule,
                            badgeColor: Colors.blue,
                            isSelected: true,
                          ),
                        )
                      else
                        Text(
                          'Your trial has ended.\nUpgrade to continue using AI chat.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondaryText,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Pricing Card
                      FrostedGlassCard(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        intensity: GlassIntensity.strong,
                        borderColor: AppTheme.goldColor.withValues(alpha: 0.8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.goldColor,
                                    height: 1.5,
                                  ),
                                ),
                                Text(
                                  premiumProduct?.price ?? '35',
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.goldColor,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'per year',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.goldColor.withValues(alpha: 0.2),
                                borderRadius: AppRadius.cardRadius,
                                border: Border.all(
                                  color: AppTheme.goldColor.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '150 AI messages per month',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Less than \$3 per month',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Features Section
                      const GlassSectionHeader(
                        title: 'What\'s Included',
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Feature List
                      _buildFeatureItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'AI Pastoral Guidance',
                        subtitle: 'Access Gemini 2.0 Flash with 19,750 pastoral training examples',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        icon: Icons.all_inclusive,
                        title: '150 Messages Monthly',
                        subtitle: 'More than enough for daily guidance and support',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        icon: Icons.psychology,
                        title: 'Context-Aware Responses',
                        subtitle: 'Biblical guidance tailored to your specific needs',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        icon: Icons.shield_outlined,
                        title: 'Crisis Detection',
                        subtitle: 'Built-in safeguards and professional referrals',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureItem(
                        icon: Icons.book_outlined,
                        title: 'Full Bible Access',
                        subtitle: 'All free features remain available',
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Purchase Button
                      GlassButton(
                        text: _isProcessing
                            ? 'Processing...'
                            : 'Start Premium - ${premiumProduct?.price ?? "\$35"}/year',
                        onPressed: _isProcessing ? null : _handlePurchase,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Restore Button
                      GestureDetector(
                        onTap: _isProcessing ? null : _handleRestore,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Center(
                            child: Text(
                              'Restore Previous Purchase',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.goldColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Terms
                      FrostedGlassCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        intensity: GlassIntensity.light,
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.secondaryText,
                              size: 20,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Payment will be charged to your App Store account. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period. Cancel anytime in your App Store account settings.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a feature list item
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      intensity: GlassIntensity.medium,
      borderColor: AppTheme.goldColor.withValues(alpha: 0.4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.goldColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: AppTheme.goldColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppTheme.goldColor,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle purchase button
  Future<void> _handlePurchase() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final subscriptionService = ref.read(subscriptionServiceProvider);

    // Set up purchase callback
    subscriptionService.onPurchaseUpdate = (success, error) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Premium activated! Enjoy unlimited AI guidance.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Close paywall
        Navigator.of(context).pop();
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Purchase failed. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    };

    // Initiate purchase
    await subscriptionService.purchasePremium();
  }

  /// Handle restore button
  Future<void> _handleRestore() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final subscriptionService = ref.read(subscriptionServiceProvider);

    // Set up restore callback
    subscriptionService.onPurchaseUpdate = (success, error) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Purchase restored successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No previous purchase found.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    };

    // Initiate restore
    await subscriptionService.restorePurchases();
  }

  @override
  void dispose() {
    // Clear callback
    final subscriptionService = ref.read(subscriptionServiceProvider);
    subscriptionService.onPurchaseUpdate = null;
    super.dispose();
  }
}
