/// Disclaimer Screen
/// Shown on first launch to inform users of app limitations
///
/// Must be acknowledged before using the app

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_utils.dart';
import '../theme/app_theme.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/glass_button.dart';

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({Key? key}) : super(key: key);

  static const String _disclaimerAgreedKey = 'disclaimer_agreed';

  /// Check if user has already agreed to disclaimer
  static Future<bool> hasAgreedToDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_disclaimerAgreedKey) ?? false;
  }

  /// Show disclaimer if not yet agreed
  static Future<void> showIfNeeded(BuildContext context) async {
    final hasAgreed = await hasAgreedToDisclaimer();
    if (!hasAgreed && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const DisclaimerScreen(),
        ),
      );
    }
  }

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100), // Bottom padding for FAB
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.goldColor.withValues(alpha: 0.6),
                          width: 2,
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
                        Icons.info_outline,
                        size: ResponsiveUtils.iconSize(context, 40),
                        color: AppTheme.goldColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Important Information',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 28, minSize: 24, maxSize: 32),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Please read carefully before continuing',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Disclaimer content
                  _buildDisclaimerSection(
                    icon: Icons.psychology_outlined,
                    title: 'Not Professional Counseling',
                    content:
                        'This app provides pastoral guidance and biblical encouragement. It is NOT a substitute for professional mental health counseling, medical advice, or emergency services.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDisclaimerSection(
                    icon: Icons.emergency,
                    title: 'Crisis Resources',
                    content:
                        'If you are experiencing a mental health crisis:\n\n'
                        '• Call 988 (Suicide & Crisis Lifeline)\n'
                        '• Text HOME to 741741 (Crisis Text Line)\n'
                        '• Call 911 for immediate danger\n'
                        '• Go to your nearest emergency room',
                    isUrgent: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDisclaimerSection(
                    icon: Icons.medical_services_outlined,
                    title: 'Medical & Legal Advice',
                    content:
                        'This app does NOT provide medical diagnoses or legal advice. For medical concerns, see a licensed doctor. For legal issues, consult an attorney.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDisclaimerSection(
                    icon: Icons.smart_toy_outlined,
                    title: 'AI Limitations',
                    content:
                        'This app uses artificial intelligence, which can make mistakes. Responses may not always be accurate or appropriate. Use discernment and seek human guidance when needed.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDisclaimerSection(
                    icon: Icons.people_outline,
                    title: 'Recommended Use',
                    content:
                        'We encourage you to:\n\n'
                        '• Engage with a local church community\n'
                        '• Speak with a pastor or spiritual advisor\n'
                        '• Seek professional therapy when appropriate\n'
                        '• Use this app as a supplement, not replacement',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Floating Agreement Card (FAB-style)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: FrostedGlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              intensity: GlassIntensity.strong,
              borderColor: _agreedToTerms
                  ? AppTheme.goldColor.withValues(alpha: 0.8)
                  : AppTheme.goldColor.withValues(alpha: 0.4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox with agreement text
                  InkWell(
                    onTap: () {
                      setState(() => _agreedToTerms = !_agreedToTerms);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _agreedToTerms
                                    ? AppTheme.goldColor
                                    : Colors.white.withValues(alpha: 0.5),
                                width: 2,
                              ),
                              color: _agreedToTerms
                                  ? AppTheme.goldColor.withValues(alpha: 0.3)
                                  : Colors.transparent,
                            ),
                            child: _agreedToTerms
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppTheme.goldColor,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'I understand this provides pastoral guidance only',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                                color: AppColors.primaryText,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: GlassButton(
                      text: 'Continue to App',
                      onPressed: _agreedToTerms ? _onContinue : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerSection({
    required IconData icon,
    required String title,
    required String content,
    bool isUrgent = false,
  }) {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      intensity: isUrgent ? GlassIntensity.strong : GlassIntensity.medium,
      borderColor: isUrgent
          ? Colors.red.withValues(alpha: 0.6)
          : AppTheme.goldColor.withValues(alpha: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? Colors.red.withValues(alpha: 0.2)
                      : AppTheme.goldColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isUrgent ? Colors.red.shade300 : AppTheme.goldColor,
                  size: ResponsiveUtils.iconSize(context, 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.bold,
                    color: isUrgent ? Colors.red.shade200 : AppTheme.goldColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              color: AppColors.primaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinue() async {
    // Save agreement to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DisclaimerScreen._disclaimerAgreedKey, true);

    if (mounted) {
      // Navigate to home screen
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
