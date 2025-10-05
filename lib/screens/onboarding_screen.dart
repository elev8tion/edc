import 'package:flutter/material.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_routes.dart';
import '../components/gradient_background.dart';
import '../components/animations/blur_fade.dart';
import '../components/glass_button.dart';
import '../components/glass/static_liquid_glass_lens.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _showFeatures = false;
  final GlobalKey _backgroundKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Smoothly show features after screen loads
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showFeatures = true;
        });
      }
    });
  }

  void _triggerFeatureAnimations() {
    setState(() {
      _showFeatures = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: _backgroundKey,
            child: const GradientBackground(),
          ),
          SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Logo section - just liquid glass and logo
                    StaticLiquidGlassLens(
                      backgroundKey: _backgroundKey,
                      width: 200,
                      height: 200,
                      effectSize: 3.0,
                      dispersionStrength: 0.3,
                      blurIntensity: 0.05,
                      child: Image.asset(
                        'assets/images/logo_transparent.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    Text(
                      'Your faith-guided companion for life\'s moments',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.secondaryText,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Features preview
                    BlurFade(
                      delay: const Duration(milliseconds: 100),
                      isVisible: _showFeatures,
                      child: _buildFeatureItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'AI Biblical Guidance',
                        description: 'Get personalized Bible verses and wisdom for any situation',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    BlurFade(
                      delay: const Duration(milliseconds: 300),
                      isVisible: _showFeatures,
                      child: _buildFeatureItem(
                        icon: Icons.auto_stories,
                        title: 'Daily Verses',
                        description: 'Receive encouraging Scripture at 9:30 AM or your preferred time',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    BlurFade(
                      delay: const Duration(milliseconds: 500),
                      isVisible: _showFeatures,
                      child: _buildFeatureItem(
                        icon: Icons.lock_outline,
                        title: 'Complete Privacy',
                        description: 'All your spiritual conversations stay on your device',
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Get started button
                    GlassButton(
                      text: 'Begin Your Journey',
                      onPressed: () {
                        _triggerFeatureAnimations();
                        // Navigate after a short delay to let animations play
                        Future.delayed(const Duration(milliseconds: 1200), () {
                          NavigationService.pushNamed(AppRoutes.auth);
                        });
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Skip option
                    TextButton(
                      onPressed: () => NavigationService.pushNamed(AppRoutes.home),
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryText,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}