import 'dart:async';
import 'package:flutter/foundation.dart';
import 'template_guidance_service.dart' show TemplateGuidanceService, ResponseTemplate;

/// AI Style Learning Service
///
/// Extracts pastoral style patterns from 233 template responses
/// These patterns are used to build system prompts for Cloudflare AI
///
/// This service does NOT generate responses itself - it provides style
/// guidance that Cloudflare AI uses to generate new responses in the
/// learned pastoral tone.
class AIStyleLearningService {
  static AIStyleLearningService? _instance;
  bool _isInitialized = false;

  // Extracted style patterns from 233 templates
  late final PastoralStylePatterns _stylePatterns;

  static AIStyleLearningService get instance {
    _instance ??= AIStyleLearningService._internal();
    return _instance!;
  }

  AIStyleLearningService._internal();

  /// Initialize and extract style patterns from 233 templates
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Extract style patterns from templates
      _stylePatterns = await _extractStylePatterns();

      _isInitialized = true;
      debugPrint('✅ AI Style Learning Service initialized (233 templates analyzed)');
    } catch (e) {
      debugPrint('⚠️ Style pattern extraction failed: $e');
      _isInitialized = false;
    }
  }

  /// Get the extracted style patterns
  /// Used by LocalAIService to build system prompts for Cloudflare AI
  PastoralStylePatterns getStylePatterns() {
    if (!_isInitialized) {
      throw Exception('AIStyleLearningService not initialized. Call initialize() first.');
    }
    return _stylePatterns;
  }

  /// Extract style patterns from 233 templates
  Future<PastoralStylePatterns> _extractStylePatterns() async {
    // Analyze the 233 templates to extract patterns
    final templates = TemplateGuidanceService.templates;

    // Extract common patterns for each theme
    final introPatterns = <String, List<String>>{};
    final closingPatterns = <String, List<String>>{};

    for (final theme in templates.keys) {
      final themeTemplates = templates[theme] ?? [];
      for (final template in themeTemplates) {
        // Extract intro patterns
        final introKey = theme;
        introPatterns.putIfAbsent(introKey, () => []);
        introPatterns[introKey]!.add(_extractIntroStyle(template.intro));

        // Extract closing patterns
        closingPatterns.putIfAbsent(introKey, () => []);
        closingPatterns[introKey]!.add(_extractClosingStyle(template.closing));
      }
    }

    return PastoralStylePatterns(
      introPatterns: introPatterns,
      closingPatterns: closingPatterns,
      verseIntegrationStyle: _analyzeVerseIntegration(),
      applicationStyle: _analyzeApplicationStyle(),
    );
  }

  String _extractIntroStyle(String intro) {
    // Analyze intro structure: acknowledgment + validation + bridge
    if (intro.contains('I can sense')) return 'Empathetic recognition';
    if (intro.contains('Thank you for sharing')) return 'Grateful acknowledgment';
    if (intro.contains('Your concerns about')) return 'Direct validation';
    if (intro.contains('Seeking direction')) return 'Wisdom affirmation';
    if (intro.contains('Fear about')) return 'Fear acknowledgment';
    if (intro.contains('darkness you\'re experiencing')) return 'Valley recognition';
    return 'Compassionate opening';
  }

  String _extractClosingStyle(String closing) {
    // Analyze closing structure: reassurance + hope + blessing
    if (closing.contains('Remember')) return 'Reminder of truth';
    if (closing.contains('May')) return 'Blessing format';
    if (closing.contains('You are')) return 'Identity affirmation';
    if (closing.contains('Hold on')) return 'Perseverance encouragement';
    if (closing.contains('Trust')) return 'Faith affirmation';
    if (closing.contains('The One who is in you')) return 'Strength reminder';
    return 'Hopeful encouragement';
  }

  String _analyzeVerseIntegration() {
    return '''Natural weaving with context
    - Introduce verses with transitions like "God's Word speaks to this..."
    - Don't just list verses - weave them into the narrative
    - Connect verses to the specific situation
    - Show how verses relate to each other''';
  }

  String _analyzeApplicationStyle() {
    return '''Practical and actionable
    - Make it concrete and applicable to daily life
    - Start with "Consider..." or "You might..." or "Take a moment to..."
    - Connect biblical truth to daily situations
    - Offer specific steps, not just concepts''';
  }

  void dispose() {
    _isInitialized = false;
    debugPrint('🔌 AI Style Learning Service disposed');
  }
}

/// Patterns extracted from 233 pastoral training templates
/// Used to build system prompts for Cloudflare AI
class PastoralStylePatterns {
  final Map<String, List<String>> introPatterns;
  final Map<String, List<String>> closingPatterns;
  final String verseIntegrationStyle;
  final String applicationStyle;

  PastoralStylePatterns({
    required this.introPatterns,
    required this.closingPatterns,
    required this.verseIntegrationStyle,
    required this.applicationStyle,
  });

  String getIntroPattern(String emotion) {
    final patterns = introPatterns[emotion] ?? introPatterns['general'] ?? [];
    if (patterns.isEmpty) return 'Acknowledge with compassion';

    // Describe the pattern style, not return a specific template
    return 'Intro style: ${patterns.first}';
  }

  String getClosingPattern(String emotion) {
    final patterns = closingPatterns[emotion] ?? closingPatterns['general'] ?? [];
    if (patterns.isEmpty) return 'End with hope';

    return 'Closing style: ${patterns.first}';
  }

  String getVerseIntegrationPattern() {
    return 'Verse integration: $verseIntegrationStyle';
  }

  String getApplicationPattern(String theme) {
    return 'Application style: $applicationStyle';
  }
}
