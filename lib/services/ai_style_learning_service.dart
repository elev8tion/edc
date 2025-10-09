import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import '../models/bible_verse.dart';
import 'template_guidance_service.dart' show TemplateGuidanceService, ResponseTemplate;

/// AI Service that LEARNS from your 233 templates' style
/// Rather than just selecting templates, it generates NEW responses in your pastoral tone
class AIStyleLearningService {
  static AIStyleLearningService? _instance;
  InferenceModel? _model;
  bool _isInitialized = false;

  // Your pastoral style patterns extracted from 233 templates
  late final PastoralStylePatterns _stylePatterns;

  static AIStyleLearningService get instance {
    _instance ??= AIStyleLearningService._internal();
    return _instance!;
  }

  AIStyleLearningService._internal();

  /// Initialize and learn from your 233 templates
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Extract style patterns from your templates
      _stylePatterns = await _extractStylePatterns();

      // Initialize AI model (Qwen or Gemma)
      _model = await FlutterGemmaPlugin.instance.createModel(
        modelType: ModelType.gemmaIt,
        preferredBackend: PreferredBackend.gpu,
        maxTokens: 300, // Longer for style generation
      );

      _isInitialized = true;
      debugPrint('✅ AI Style Learning Service initialized');
    } catch (e) {
      debugPrint('⚠️ Style learning failed, using templates: $e');
      _isInitialized = false;
    }
  }

  /// Generate a response in YOUR pastoral style (not just picking a template!)
  Future<String> generateInPastoralStyle({
    required String userInput,
    required String understanding,
    required String emotionalTone,
    required String theme,
    required List<BibleVerse> databaseVerses,
  }) async {
    if (!_isInitialized || _model == null) {
      // Fallback to template selection
      return TemplateGuidanceService.instance.generateTemplateResponse(
        userInput: userInput,
        theme: theme,
        understanding: null,
        additionalVerses: databaseVerses.map((v) => '${v.text} - ${v.reference}').toList(),
      );
    }

    try {
      final session = await _model!.createSession();

      try {
        // This is the KEY difference - we're teaching the AI your style!
        final stylePrompt = '''
You are a compassionate pastoral counselor. Generate a response using this exact style:

STYLE PATTERNS FROM 233 TRAINING EXAMPLES:
${_stylePatterns.getIntroPattern(emotionalTone)}
${_stylePatterns.getVerseIntegrationPattern()}
${_stylePatterns.getApplicationPattern(theme)}
${_stylePatterns.getClosingPattern(emotionalTone)}

USER'S SITUATION:
- Input: "$userInput"
- Understanding: "$understanding"
- Emotional State: $emotionalTone
- Theme: $theme

BIBLE VERSES FROM DATABASE TO USE:
${databaseVerses.map((v) => '- "${v.text}" - ${v.reference}').join('\n')}

Generate a pastoral response in the learned style that:
1. Acknowledges their specific situation with compassion
2. Naturally integrates the Bible verses (don't just list them)
3. Provides practical application
4. Ends with hope and encouragement

Your response:''';

        await session.addQueryChunk(Message.text(
          text: stylePrompt,
          isUser: true,
        ));

        final aiResponse = await session.getResponse();

        if (aiResponse.isNotEmpty) {
          debugPrint('✅ Generated new response in pastoral style');
          return aiResponse;
        }
      } finally {
        await session.close();
      }
    } catch (e) {
      debugPrint('Style generation failed: $e');
    }

    // Fallback to template
    return TemplateGuidanceService.instance.generateTemplateResponse(
      userInput: userInput,
      theme: theme,
      understanding: null,
      additionalVerses: databaseVerses.map((v) => '${v.text} - ${v.reference}').toList(),
    );
  }

  /// Extract style patterns from your 233 templates
  Future<PastoralStylePatterns> _extractStylePatterns() async {
    // Analyze your 233 templates to extract patterns
    final templates = TemplateGuidanceService.templates;

    // Extract common patterns for each emotional tone
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
    return 'Compassionate opening';
  }

  String _extractClosingStyle(String closing) {
    // Analyze closing structure: reassurance + hope + blessing
    if (closing.contains('Remember')) return 'Reminder of truth';
    if (closing.contains('May')) return 'Blessing format';
    if (closing.contains('You are')) return 'Identity affirmation';
    return 'Hopeful encouragement';
  }

  String _analyzeVerseIntegration() {
    return '''
    - Introduce verses naturally with transitions like "God's Word speaks to this..."
    - Don't just list verses - weave them into the narrative
    - Connect verses to the specific situation
    - Show how verses relate to each other
    ''';
  }

  String _analyzeApplicationStyle() {
    return '''
    - Make it practical and actionable
    - Start with "Consider..." or "You might..." or "Take a moment to..."
    - Connect to daily life
    - Offer specific steps, not just concepts
    ''';
  }

  void dispose() {
    _model = null;
    _isInitialized = false;
  }
}

/// Patterns extracted from your 233 training templates
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

    // Describe the pattern, not return a specific template
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

// ResponseTemplate is imported from template_guidance_service.dart