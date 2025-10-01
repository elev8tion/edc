class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String settings = '/settings';
  static const String prayerJournal = '/prayer-journal';
  static const String verseLibrary = '/verse-library';
  static const String profile = '/profile';
  static const String devotional = '/devotional';
  static const String readingPlan = '/reading-plan';

  static const List<String> authRequiredRoutes = [
    home,
    chat,
    settings,
    prayerJournal,
    verseLibrary,
    profile,
    devotional,
    readingPlan,
  ];

  static const List<String> publicRoutes = [
    splash,
    onboarding,
    auth,
  ];

  static bool isAuthRequired(String route) {
    return authRequiredRoutes.contains(route);
  }

  static bool isPublicRoute(String route) {
    return publicRoutes.contains(route);
  }
}