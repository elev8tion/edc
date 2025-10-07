import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../services/prayer_streak_service.dart';
import '../services/verse_service.dart';
import '../services/devotional_service.dart';
import '../services/devotional_progress_service.dart';
import '../services/reading_plan_service.dart';
import '../services/reading_plan_progress_service.dart';
import '../services/bible_loader_service.dart';
import '../services/devotional_content_loader.dart';
import '../services/preferences_service.dart';
import '../models/devotional.dart';
import '../models/reading_plan.dart';

// Core Services
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final preferencesServiceProvider = FutureProvider<PreferencesService>((ref) async {
  return await PreferencesService.getInstance();
});

// Feature Services
final prayerServiceProvider = Provider<PrayerService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return PrayerService(database);
});

final verseServiceProvider = Provider<VerseService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return VerseService(database);
});

final devotionalServiceProvider = Provider<DevotionalService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return DevotionalService(database);
});

final readingPlanServiceProvider = Provider<ReadingPlanService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return ReadingPlanService(database);
});

final bibleLoaderServiceProvider = Provider<BibleLoaderService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return BibleLoaderService(database);
});

final devotionalContentLoaderProvider = Provider<DevotionalContentLoader>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return DevotionalContentLoader(database);
});

final devotionalProgressServiceProvider = Provider<DevotionalProgressService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return DevotionalProgressService(database);
});

final readingPlanProgressServiceProvider = Provider<ReadingPlanProgressService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return ReadingPlanProgressService(database);
});

final prayerStreakServiceProvider = Provider<PrayerStreakService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return PrayerStreakService(database);
});

// State Providers
final connectivityStateProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

final appInitializationProvider = FutureProvider<void>((ref) async {
  final database = ref.read(databaseServiceProvider);
  final notifications = ref.read(notificationServiceProvider);
  final bibleLoader = ref.read(bibleLoaderServiceProvider);
  final devotionalLoader = ref.read(devotionalContentLoaderProvider);

  await database.initialize();
  await notifications.initialize();

  // Load Bible on first launch
  final isKJVLoaded = await bibleLoader.isBibleLoaded('KJV');
  if (!isKJVLoaded) {
    print('📖 Loading Bible for first time...');
    await bibleLoader.loadAllBibles();
    print('✅ Bible loaded successfully!');
  } else {
    print('✅ Bible already loaded');
  }

  // Load devotional content on first launch
  await devotionalLoader.loadDevotionals();
});

// Devotional Progress Providers

/// Provider for getting all devotionals
final allDevotionalsProvider = FutureProvider<List<Devotional>>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getAllDevotionals();
});

/// Provider for getting today's devotional
final todaysDevotionalProvider = FutureProvider<Devotional?>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getTodaysDevotional();
});

/// Provider for getting completion status of a specific devotional
final devotionalCompletionStatusProvider = FutureProvider.family<bool, String>((ref, devotionalId) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getCompletionStatus(devotionalId);
});

/// Provider for getting the current devotional streak
final devotionalStreakProvider = FutureProvider<int>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getStreakCount();
});

/// Provider for getting total number of completed devotionals
final totalDevotionalsCompletedProvider = FutureProvider<int>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getTotalCompleted();
});

/// Provider for getting completion percentage
final devotionalCompletionPercentageProvider = FutureProvider<double>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getCompletionPercentage();
});

/// Provider for getting all completed devotionals
final completedDevotionalsProvider = FutureProvider<List<Devotional>>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getCompletedDevotionals();
});

// Reading Plan Progress Providers

/// Provider for getting all reading plans
final allReadingPlansProvider = FutureProvider<List<ReadingPlan>>((ref) async {
  final planService = ref.watch(readingPlanServiceProvider);
  return await planService.getAllPlans();
});

/// Provider for getting active reading plans
final activeReadingPlansProvider = FutureProvider<List<ReadingPlan>>((ref) async {
  final planService = ref.watch(readingPlanServiceProvider);
  return await planService.getActivePlans();
});

/// Provider for getting the current active plan
final currentReadingPlanProvider = FutureProvider<ReadingPlan?>((ref) async {
  final planService = ref.watch(readingPlanServiceProvider);
  return await planService.getCurrentPlan();
});

/// Provider for getting progress percentage for a specific plan
final planProgressPercentageProvider = FutureProvider.family<double, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getProgressPercentage(planId);
});

/// Provider for getting current day number in a plan
final planCurrentDayProvider = FutureProvider.family<int, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getCurrentDay(planId);
});

/// Provider for getting today's readings for a plan
final todaysReadingsProvider = FutureProvider.family<List<DailyReading>, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getTodaysReadings(planId);
});

/// Provider for getting incomplete readings for a plan
final incompleteReadingsProvider = FutureProvider.family<List<DailyReading>, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getIncompleteReadings(planId);
});

/// Provider for getting completed readings for a plan
final completedReadingsProvider = FutureProvider.family<List<DailyReading>, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getCompletedReadings(planId);
});

/// Provider for getting reading streak for a plan
final planStreakProvider = FutureProvider.family<int, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getStreak(planId);
});

// Prayer Streak Providers

/// Provider for getting the current prayer streak
final currentPrayerStreakProvider = FutureProvider<int>((ref) async {
  final streakService = ref.watch(prayerStreakServiceProvider);
  return await streakService.getCurrentStreak();
});

/// Provider for getting the longest prayer streak ever achieved
final longestPrayerStreakProvider = FutureProvider<int>((ref) async {
  final streakService = ref.watch(prayerStreakServiceProvider);
  return await streakService.getLongestStreak();
});

/// Provider for checking if user has prayed today
final prayedTodayProvider = FutureProvider<bool>((ref) async {
  final streakService = ref.watch(prayerStreakServiceProvider);
  return await streakService.hasPrayedToday();
});

/// Provider for getting total days prayed (not consecutive)
final totalDaysPrayedProvider = FutureProvider<int>((ref) async {
  final streakService = ref.watch(prayerStreakServiceProvider);
  return await streakService.getTotalDaysPrayed();
});

/// Provider for getting all prayer activity dates
final prayerActivityDatesProvider = FutureProvider<List<DateTime>>((ref) async {
  final streakService = ref.watch(prayerStreakServiceProvider);
  return await streakService.getAllActivityDates();
});

// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return ThemeModeNotifier(preferencesAsync);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  PreferencesService? _preferences;

  ThemeModeNotifier(this._preferencesAsync) : super(ThemeMode.dark) {
    _initializeTheme();
  }

  /// Initialize theme from saved preferences
  Future<void> _initializeTheme() async {
    try {
      _preferencesAsync.when(
        data: (prefs) {
          _preferences = prefs;
          final savedTheme = prefs.loadThemeMode();
          state = savedTheme;
          print('✅ Theme initialized from preferences: $savedTheme');
        },
        loading: () {
          print('⏳ Loading preferences...');
        },
        error: (error, stack) {
          print('❌ Error loading preferences for theme: $error');
        },
      );
    } catch (e) {
      print('❌ Error initializing theme: $e');
    }
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _setThemeAndSave(newMode);
  }

  /// Set specific theme mode
  void setTheme(ThemeMode mode) {
    _setThemeAndSave(mode);
  }

  /// Internal method to set theme and save to preferences
  Future<void> _setThemeAndSave(ThemeMode mode) async {
    state = mode;

    if (_preferences != null) {
      try {
        final success = await _preferences!.saveThemeMode(mode);
        if (success) {
          print('✅ Theme saved successfully: $mode');
        } else {
          print('⚠️ Failed to save theme mode');
        }
      } catch (e) {
        print('❌ Error saving theme mode: $e');
      }
    } else {
      print('⚠️ Preferences service not initialized, theme not persisted');
    }
  }
}

// Language Provider
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return LanguageNotifier(preferencesAsync);
});

class LanguageNotifier extends StateNotifier<String> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  PreferencesService? _preferences;

  LanguageNotifier(this._preferencesAsync) : super('English') {
    _initializeLanguage();
  }

  /// Initialize language from saved preferences
  Future<void> _initializeLanguage() async {
    try {
      _preferencesAsync.when(
        data: (prefs) {
          _preferences = prefs;
          final savedLanguage = prefs.loadLanguage();
          state = savedLanguage;
          print('✅ Language initialized from preferences: $savedLanguage');
        },
        loading: () {
          print('⏳ Loading preferences for language...');
        },
        error: (error, stack) {
          print('❌ Error loading preferences for language: $error');
        },
      );
    } catch (e) {
      print('❌ Error initializing language: $e');
    }
  }

  /// Set language preference
  Future<void> setLanguage(String language) async {
    state = language;

    if (_preferences != null) {
      try {
        final success = await _preferences!.saveLanguage(language);
        if (success) {
          print('✅ Language saved successfully: $language');
        } else {
          print('⚠️ Failed to save language');
        }
      } catch (e) {
        print('❌ Error saving language: $e');
      }
    } else {
      print('⚠️ Preferences service not initialized, language not persisted');
    }
  }
}

// Text Size Provider
final textSizeProvider = StateNotifierProvider<TextSizeNotifier, double>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return TextSizeNotifier(preferencesAsync);
});

// Notification Settings Providers
final dailyNotificationsProvider = StateNotifierProvider<DailyNotificationsNotifier, bool>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return DailyNotificationsNotifier(preferencesAsync, ref);
});

final prayerRemindersProvider = StateNotifierProvider<PrayerRemindersNotifier, bool>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return PrayerRemindersNotifier(preferencesAsync, ref);
});

final verseOfTheDayProvider = StateNotifierProvider<VerseOfTheDayNotifier, bool>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return VerseOfTheDayNotifier(preferencesAsync, ref);
});

final notificationTimeProvider = StateNotifierProvider<NotificationTimeNotifier, String>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return NotificationTimeNotifier(preferencesAsync, ref);
});

class TextSizeNotifier extends StateNotifier<double> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  PreferencesService? _preferences;

  TextSizeNotifier(this._preferencesAsync) : super(16.0) {
    _initializeTextSize();
  }

  /// Initialize text size from saved preferences
  Future<void> _initializeTextSize() async {
    try {
      _preferencesAsync.when(
        data: (prefs) {
          _preferences = prefs;
          final savedSize = prefs.loadTextSize();
          state = savedSize;
          print('✅ Text size initialized from preferences: $savedSize');
        },
        loading: () {
          print('⏳ Loading preferences for text size...');
        },
        error: (error, stack) {
          print('❌ Error loading preferences for text size: $error');
        },
      );
    } catch (e) {
      print('❌ Error initializing text size: $e');
    }
  }

  /// Set text size
  Future<void> setTextSize(double size) async {
    // Validate size is within reasonable bounds (12-24)
    if (size < 12.0 || size > 24.0) {
      print('⚠️ Text size out of bounds: $size. Clamping to valid range.');
      size = size.clamp(12.0, 24.0);
    }

    state = size;

    if (_preferences != null) {
      try {
        final success = await _preferences!.saveTextSize(size);
        if (success) {
          print('✅ Text size saved successfully: $size');
        } else {
          print('⚠️ Failed to save text size');
        }
      } catch (e) {
        print('❌ Error saving text size: $e');
      }
    } else {
      print('⚠️ Preferences service not initialized, text size not persisted');
    }
  }
}

// Notification Settings Notifiers
class DailyNotificationsNotifier extends StateNotifier<bool> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  DailyNotificationsNotifier(this._preferencesAsync, this._ref) : super(true) {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.when(
      data: (prefs) {
        _preferences = prefs;
        state = prefs.loadDailyNotificationsEnabled();
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _preferences?.saveDailyNotificationsEnabled(enabled);
    if (enabled) {
      await _scheduleNotifications();
    } else {
      await _ref.read(notificationServiceProvider).cancel(1);
    }
  }

  Future<void> _scheduleNotifications() async {
    final time = _ref.read(notificationTimeProvider);
    final parts = time.split(':');
    await _ref.read(notificationServiceProvider).scheduleDailyDevotional(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

class PrayerRemindersNotifier extends StateNotifier<bool> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  PrayerRemindersNotifier(this._preferencesAsync, this._ref) : super(true) {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.when(
      data: (prefs) {
        _preferences = prefs;
        state = prefs.loadPrayerRemindersEnabled();
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _preferences?.savePrayerRemindersEnabled(enabled);
    if (enabled) {
      await _scheduleNotifications();
    } else {
      await _ref.read(notificationServiceProvider).cancel(2);
    }
  }

  Future<void> _scheduleNotifications() async {
    final time = _ref.read(notificationTimeProvider);
    final parts = time.split(':');
    await _ref.read(notificationServiceProvider).schedulePrayerReminder(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
      title: 'Your Prayer Requests',
    );
  }
}

class VerseOfTheDayNotifier extends StateNotifier<bool> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  VerseOfTheDayNotifier(this._preferencesAsync, this._ref) : super(true) {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.when(
      data: (prefs) {
        _preferences = prefs;
        state = prefs.loadVerseOfTheDayEnabled();
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _preferences?.saveVerseOfTheDayEnabled(enabled);
    if (enabled) {
      await _scheduleNotifications();
    } else {
      await _ref.read(notificationServiceProvider).cancel(3);
    }
  }

  Future<void> _scheduleNotifications() async {
    final time = _ref.read(notificationTimeProvider);
    final parts = time.split(':');
    await _ref.read(notificationServiceProvider).scheduleReadingPlanReminder(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

class NotificationTimeNotifier extends StateNotifier<String> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  NotificationTimeNotifier(this._preferencesAsync, this._ref) : super('08:00') {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.when(
      data: (prefs) {
        _preferences = prefs;
        state = prefs.loadNotificationTime();
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  Future<void> setTime(String time) async {
    state = time;
    await _preferences?.saveNotificationTime(time);
    // Reschedule all enabled notifications with new time
    await _rescheduleNotifications();
  }

  Future<void> _rescheduleNotifications() async {
    final parts = state.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (_ref.read(dailyNotificationsProvider)) {
      await _ref.read(notificationServiceProvider).scheduleDailyDevotional(
        hour: hour,
        minute: minute,
      );
    }

    if (_ref.read(prayerRemindersProvider)) {
      await _ref.read(notificationServiceProvider).schedulePrayerReminder(
        hour: hour,
        minute: minute,
        title: 'Your Prayer Requests',
      );
    }

    if (_ref.read(verseOfTheDayProvider)) {
      await _ref.read(notificationServiceProvider).scheduleReadingPlanReminder(
        hour: hour,
        minute: minute,
      );
    }
  }
}

// App Initialization Provider
// Initializes notification service and schedules notifications on app startup
final initializeAppProvider = FutureProvider<void>((ref) async {
  // Initialize notification service
  final notifications = ref.read(notificationServiceProvider);
  await notifications.initialize();

  // Wait for preferences to load
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  await preferencesAsync.when(
    data: (prefs) async {
      // Schedule notifications if enabled
      final notificationTime = prefs.loadNotificationTime();
      final parts = notificationTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (prefs.loadDailyNotificationsEnabled()) {
        await notifications.scheduleDailyDevotional(
          hour: hour,
          minute: minute,
        );
      }

      if (prefs.loadPrayerRemindersEnabled()) {
        await notifications.schedulePrayerReminder(
          hour: hour,
          minute: minute,
          title: 'Your Prayer Requests',
        );
      }

      if (prefs.loadVerseOfTheDayEnabled()) {
        await notifications.scheduleReadingPlanReminder(
          hour: hour,
          minute: minute,
        );
      }
    },
    loading: () => null,
    error: (error, _) {
      debugPrint('Failed to initialize notifications: $error');
    },
  );
});