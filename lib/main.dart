import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'theme/app_theme.dart';
import 'core/navigation/navigation_service.dart';
import 'core/navigation/app_routes.dart';
import 'core/providers/app_providers.dart';
import 'core/error/error_handler.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/prayer_journal_screen.dart';
import 'screens/verse_library_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/devotional_screen.dart';
import 'screens/reading_plan_screen.dart';
import 'services/local_ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Initialize AI services in background
  AIServiceFactory.initialize().catchError((e) {
    debugPrint('AI Service initialization failed: $e');
  });

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    final error = ErrorHandler.handle(details.exception);
    ErrorHandler.logError(error, stackTrace: details.stack);
  };

  runApp(const ProviderScope(child: EverydayChristianApp()));
}

// Development mode flag - set to true to bypass auth
// 🎯 DEVELOPMENT MODE FEATURES:
// - Direct Home Access: App starts at home screen when true
// - Visual Indicator: Orange "DEV" badge appears in top-right corner
// - Authentication Bypass: Skips splash, onboarding, and auth screens
// 🚀 READY FOR iOS SIMULATOR TESTING - Navigate freely through all screens:
//   • Home Screen - Main dashboard with navigation
//   • Chat Screen - AI-powered biblical guidance
//   • Prayer Journal - Personal prayer tracking
//   • Verse Library - Searchable Bible verse collection
//   • Settings - App configuration
//   • Profile - User profile management
// To disable: Change to false for normal authentication flow
const bool kDevelopmentMode = true;

class EverydayChristianApp extends StatelessWidget {
  const EverydayChristianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Everyday Christian',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: kDevelopmentMode ? AppRoutes.home : AppRoutes.splash,
      onGenerateRoute: _generateRoute,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: kDevelopmentMode
            ? Stack(
                children: [
                  child!,
                  Positioned(
                    top: 50,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'DEV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : child!,
        );
      },
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    // Add fade transition for all routes
    Widget page;

    switch (settings.name) {
      case AppRoutes.splash:
        page = const SplashScreen();
        break;
      case AppRoutes.onboarding:
        page = const OnboardingScreen();
        break;
      case AppRoutes.auth:
        page = const AuthScreen();
        break;
      case AppRoutes.home:
        page = const HomeScreen();
        break;
      case AppRoutes.chat:
        page = const ChatScreen();
        break;
      case AppRoutes.settings:
        page = const SettingsScreen();
        break;
      case AppRoutes.prayerJournal:
        page = const PrayerJournalScreen();
        break;
      case AppRoutes.verseLibrary:
        page = const VerseLibraryScreen();
        break;
      case AppRoutes.profile:
        page = const ProfileScreen();
        break;
      case AppRoutes.devotional:
        page = const DevotionalScreen();
        break;
      case AppRoutes.readingPlan:
        page = const ReadingPlanScreen();
        break;
      default:
        page = const SplashScreen();
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, _) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}