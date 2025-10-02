import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences using SharedPreferences
///
/// This service provides type-safe methods for storing and retrieving
/// user settings like theme mode, language preference, and text size.
class PreferencesService {
  // Singleton pattern
  static PreferencesService? _instance;
  static SharedPreferences? _preferences;

  // Private constructor
  PreferencesService._();

  /// Get the singleton instance
  static Future<PreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = PreferencesService._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// Initialize SharedPreferences
  Future<void> _init() async {
    try {
      _preferences = await SharedPreferences.getInstance();
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
      rethrow;
    }
  }

  // Keys for stored preferences
  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language_preference';
  static const String _textSizeKey = 'text_size';

  // Default values
  static const String _defaultThemeMode = 'dark';
  static const String _defaultLanguage = 'English';
  static const double _defaultTextSize = 16.0;

  // ============================================================================
  // THEME MODE METHODS
  // ============================================================================

  /// Save theme mode to preferences
  ///
  /// Converts ThemeMode enum to string for storage.
  /// Returns true if save was successful, false otherwise.
  Future<bool> saveThemeMode(ThemeMode mode) async {
    try {
      final String modeString = _themeModeToString(mode);
      final result = await _preferences?.setString(_themeModeKey, modeString);
      if (result == true) {
        print('✅ Theme mode saved: $modeString');
      }
      return result ?? false;
    } catch (e) {
      print('❌ Error saving theme mode: $e');
      return false;
    }
  }

  /// Load theme mode from preferences
  ///
  /// Returns saved ThemeMode or defaults to ThemeMode.dark if not found.
  ThemeMode loadThemeMode() {
    try {
      final String? modeString = _preferences?.getString(_themeModeKey);
      if (modeString == null) {
        print('ℹ️ No saved theme mode, using default: $_defaultThemeMode');
        return _stringToThemeMode(_defaultThemeMode);
      }
      print('✅ Theme mode loaded: $modeString');
      return _stringToThemeMode(modeString);
    } catch (e) {
      print('❌ Error loading theme mode: $e');
      return _stringToThemeMode(_defaultThemeMode);
    }
  }

  /// Convert ThemeMode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Convert string to ThemeMode
  ThemeMode _stringToThemeMode(String modeString) {
    switch (modeString.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  // ============================================================================
  // LANGUAGE PREFERENCE METHODS
  // ============================================================================

  /// Save language preference to preferences
  ///
  /// Returns true if save was successful, false otherwise.
  Future<bool> saveLanguage(String language) async {
    try {
      final result = await _preferences?.setString(_languageKey, language);
      if (result == true) {
        print('✅ Language saved: $language');
      }
      return result ?? false;
    } catch (e) {
      print('❌ Error saving language: $e');
      return false;
    }
  }

  /// Load language preference from preferences
  ///
  /// Returns saved language or defaults to 'English' if not found.
  String loadLanguage() {
    try {
      final String? language = _preferences?.getString(_languageKey);
      if (language == null) {
        print('ℹ️ No saved language, using default: $_defaultLanguage');
        return _defaultLanguage;
      }
      print('✅ Language loaded: $language');
      return language;
    } catch (e) {
      print('❌ Error loading language: $e');
      return _defaultLanguage;
    }
  }

  // ============================================================================
  // TEXT SIZE METHODS
  // ============================================================================

  /// Save text size to preferences
  ///
  /// Returns true if save was successful, false otherwise.
  Future<bool> saveTextSize(double size) async {
    try {
      final result = await _preferences?.setDouble(_textSizeKey, size);
      if (result == true) {
        print('✅ Text size saved: $size');
      }
      return result ?? false;
    } catch (e) {
      print('❌ Error saving text size: $e');
      return false;
    }
  }

  /// Load text size from preferences
  ///
  /// Returns saved text size or defaults to 16.0 if not found.
  double loadTextSize() {
    try {
      final double? size = _preferences?.getDouble(_textSizeKey);
      if (size == null) {
        print('ℹ️ No saved text size, using default: $_defaultTextSize');
        return _defaultTextSize;
      }
      print('✅ Text size loaded: $size');
      return size;
    } catch (e) {
      print('❌ Error loading text size: $e');
      return _defaultTextSize;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Clear all preferences (useful for testing or reset functionality)
  Future<bool> clearAll() async {
    try {
      final result = await _preferences?.clear();
      if (result == true) {
        print('✅ All preferences cleared');
      }
      return result ?? false;
    } catch (e) {
      print('❌ Error clearing preferences: $e');
      return false;
    }
  }

  /// Clear specific preference by key
  Future<bool> remove(String key) async {
    try {
      final result = await _preferences?.remove(key);
      if (result == true) {
        print('✅ Preference removed: $key');
      }
      return result ?? false;
    } catch (e) {
      print('❌ Error removing preference: $e');
      return false;
    }
  }

  /// Check if preferences have been initialized
  bool get isInitialized => _preferences != null;

  /// Get all stored preferences (for debugging)
  Map<String, dynamic> getAllPreferences() {
    if (_preferences == null) {
      return {};
    }

    return {
      'theme_mode': _preferences!.getString(_themeModeKey),
      'language': _preferences!.getString(_languageKey),
      'text_size': _preferences!.getDouble(_textSizeKey),
    };
  }
}
