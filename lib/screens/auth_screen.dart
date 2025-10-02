import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/services/auth_service.dart';
import '../features/auth/widgets/auth_form.dart';
import '../theme/app_theme.dart';
import '../components/glass_card.dart';
import '../components/gradient_background.dart';
import '../components/animations/blur_fade.dart';
import '../components/glass/static_liquid_glass_lens.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_routes.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  bool _showContent = false;
  final GlobalKey _backgroundKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Show content with slight delay for smooth appearance
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authServiceProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (user) {
          // Navigate to home on successful authentication
          NavigationService.pushAndRemoveUntil(AppRoutes.home);
        },
        unauthenticated: () {},
        error: (message) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

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
                  const SizedBox(height: 20),

                  // Liquid glass logo section
                  BlurFade(
                    delay: const Duration(milliseconds: 100),
                    isVisible: _showContent,
                    child: Column(
                      children: [
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
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue your spiritual journey',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Auth form
                  BlurFade(
                    delay: const Duration(milliseconds: 300),
                    isVisible: _showContent,
                    child: const AuthForm(),
                  ),

                  const SizedBox(height: 20),

                  // Privacy note
                  Text(
                    'Your spiritual conversations remain completely private on your device',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}