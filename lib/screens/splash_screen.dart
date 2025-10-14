import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_card.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_routes.dart';
import '../core/widgets/app_initializer.dart';
import '../hooks/animation_hooks.dart';
import '../utils/responsive_utils.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use custom hook for combined fade and scale animations
    final animations = useFadeAndScale(
      fadeDuration: const Duration(milliseconds: 1500),
      scaleDuration: const Duration(milliseconds: 2000),
    );

    // Create animations with curves
    final fadeAnimation = useAnimation(
      CurvedAnimation(
        parent: animations.fade,
        curve: Curves.easeInOut,
      ),
    );

    final scaleAnimation = useAnimation(
      CurvedAnimation(
        parent: animations.scale,
        curve: Curves.elasticOut,
      ),
    );

    // Navigate to next screen after delay and initialization
    useEffect(() {
      Future.delayed(const Duration(seconds: 3), () {
        NavigationService.pushReplacementNamed(AppRoutes.onboarding);
      });
      return null;
    }, []);

    // Wrap the splash screen UI with AppInitializer
    return AppInitializer(
      child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e), // Dark navy blue
              Color(0xFF16213e), // Darker navy
              Color(0xFF0f3460), // Deep blue
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Radial glow effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Center(
                child: FadeTransition(
                  opacity: AlwaysStoppedAnimation(fadeAnimation),
                  child: ScaleTransition(
                    scale: AlwaysStoppedAnimation(scaleAnimation),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container with glass effect
                        GlassCard(
                          borderRadius: 32,
                          blurSigma: 20,
                          borderColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              // Logo image
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: AppRadius.largeCardRadius,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: AppRadius.largeCardRadius,
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback if logo not found
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: AppRadius.largeCardRadius,
                                          color: AppTheme.goldColor,
                                        ),
                                        child: Icon(
                                          Icons.auto_stories,
                                          size: ResponsiveUtils.iconSize(context, 60),
                                          color: AppColors.primaryText,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xxl),

                              // App name
                              Text(
                                'EVERYDAY',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 4,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              Text(
                                'CHRISTIAN',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, 32, minSize: 28, maxSize: 36),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: AppColors.primaryText,
                                ),
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Tagline
                              Text(
                                'Faith-guided wisdom for life\'s moments',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Loading indicator
                        const SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                            strokeWidth: 3,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Loading text
                        Text(
                          'Preparing your spiritual journey...',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom branding
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: AlwaysStoppedAnimation(fadeAnimation),
                  child: Column(
                    children: [
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Built with ❤️ for faith',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
