import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../services/verse_service.dart';
import '../services/devotional_service.dart';
import '../services/reading_plan_service.dart';
import '../services/bible_loader_service.dart';
import '../services/devotional_content_loader.dart';
import '../services/preferences_service.dart';

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