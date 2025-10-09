import 'dart:async';
import 'package:flutter/foundation.dart';

/// Theme classifier for biblical guidance
/// Uses keyword matching to detect emotional themes in user input
/// (Previously used TFLite, now simplified for Flutter Gemma migration)
class ThemeClassifierService {
  static ThemeClassifierService? _instance;
  bool _isInitialized = false;

  // Biblical themes mapping
  static const List<String> themes = [
    'anxiety',
    'depression',
    'strength',
    'guidance',
    'forgiveness',
    'purpose',
    'relationships',
    'fear',
    'doubt',
    'gratitude',
    'general',
  ];

  // Theme keywords for classification
  static final Map<String, List<String>> themeKeywords = {
    'anxiety': ['anxious', 'worried', 'worry', 'nervous', 'stressed', 'stress', 'overwhelmed', 'panic', 'restless'],
    'depression': ['depressed', 'sad', 'hopeless', 'empty', 'numb', 'despair', 'down', 'lonely', 'worthless'],
    'fear': ['afraid', 'scared', 'fearful', 'terrified', 'frightened', 'terror', 'phobia', 'dread'],
    'anger': ['angry', 'mad', 'furious', 'rage', 'upset', 'irritated', 'annoyed', 'frustrated'],
    'guilt': ['guilty', 'shame', 'ashamed', 'regret', 'remorse', 'sorry', 'fault', 'blame'],
    'forgiveness': ['forgive', 'forgiveness', 'mercy', 'pardon', 'reconcile', 'sorry', 'apologize'],
    'doubt': ['doubt', 'uncertain', 'confused', 'questioning', 'unsure', 'skeptical', 'wondering'],
    'strength': ['strength', 'strong', 'courage', 'brave', 'power', 'overcome', 'persevere', 'endure'],
    'guidance': ['guide', 'guidance', 'direction', 'wisdom', 'advice', 'help', 'lost', 'path', 'decision'],
    'purpose': ['purpose', 'meaning', 'calling', 'destiny', 'mission', 'why', 'reason', 'goal'],
    'relationships': ['relationship', 'marriage', 'spouse', 'husband', 'wife', 'friend', 'family', 'love'],
    'gratitude': ['grateful', 'thankful', 'blessed', 'appreciate', 'gratitude', 'thanks', 'praise'],
  };

  // Singleton pattern
  static ThemeClassifierService get instance {
    _instance ??= ThemeClassifierService._internal();
    return _instance!;
  }

  ThemeClassifierService._internal();

  /// Check if service is ready
  bool get isReady => _isInitialized;

  /// Initialize the classifier (simplified version)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Simplified initialization - no model loading needed
      await Future.delayed(const Duration(milliseconds: 100));
      _isInitialized = true;
      debugPrint('✅ Theme classifier initialized (keyword-based)');
    } catch (e) {
      debugPrint('❌ Theme classifier initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// Get the primary theme from user input
  Future<String> getPrimaryTheme(String input) async {
    if (!_isInitialized) {
      await initialize();
    }

    final inputLower = input.toLowerCase();
    final themeScores = <String, int>{};

    // Count keyword matches for each theme
    for (final entry in themeKeywords.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        if (inputLower.contains(keyword)) {
          score += keyword.length; // Weight by keyword length
        }
      }
      if (score > 0) {
        themeScores[entry.key] = score;
      }
    }

    // Return theme with highest score
    if (themeScores.isNotEmpty) {
      final sortedThemes = themeScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return sortedThemes.first.key;
    }

    // Default to 'general' if no specific theme detected
    return 'general';
  }

  /// Get all detected themes with confidence scores
  Future<Map<String, double>> getThemeScores(String input) async {
    if (!_isInitialized) {
      await initialize();
    }

    final inputLower = input.toLowerCase();
    final themeScores = <String, double>{};

    // Calculate normalized scores for each theme
    int totalScore = 0;
    final rawScores = <String, int>{};

    for (final entry in themeKeywords.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        if (inputLower.contains(keyword)) {
          score += keyword.length;
        }
      }
      if (score > 0) {
        rawScores[entry.key] = score;
        totalScore += score;
      }
    }

    // Normalize scores to 0-1 range
    if (totalScore > 0) {
      for (final entry in rawScores.entries) {
        themeScores[entry.key] = entry.value / totalScore;
      }
    }

    // Add small score for 'general' if no specific theme
    if (themeScores.isEmpty) {
      themeScores['general'] = 1.0;
    }

    return themeScores;
  }

  /// Dispose of resources
  Future<void> dispose() async {
    _isInitialized = false;
    debugPrint('🧹 Theme classifier disposed');
  }

  /// Detect sentiment (simplified)
  Future<String> detectSentiment(String input) async {
    final scores = await getThemeScores(input);

    // Check for negative themes
    final negativeThemes = ['anxiety', 'depression', 'fear', 'anger', 'guilt', 'doubt'];
    final positiveThemes = ['strength', 'gratitude', 'forgiveness', 'purpose'];

    double negativeScore = 0;
    double positiveScore = 0;

    for (final entry in scores.entries) {
      if (negativeThemes.contains(entry.key)) {
        negativeScore += entry.value;
      } else if (positiveThemes.contains(entry.key)) {
        positiveScore += entry.value;
      }
    }

    if (negativeScore > positiveScore) {
      return 'negative';
    } else if (positiveScore > negativeScore) {
      return 'positive';
    }
    return 'neutral';
  }

  /// Get suggested Bible themes based on input
  List<String> getSuggestedThemes(String input) {
    final inputLower = input.toLowerCase();
    final detectedThemes = <String>[];

    for (final entry in themeKeywords.entries) {
      for (final keyword in entry.value) {
        if (inputLower.contains(keyword)) {
          if (!detectedThemes.contains(entry.key)) {
            detectedThemes.add(entry.key);
          }
          break;
        }
      }
    }

    // Return up to 3 themes
    if (detectedThemes.length > 3) {
      return detectedThemes.sublist(0, 3);
    }

    // Add 'general' if no themes detected
    if (detectedThemes.isEmpty) {
      detectedThemes.add('general');
    }

    return detectedThemes;
  }
}