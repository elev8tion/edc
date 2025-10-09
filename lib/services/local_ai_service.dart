import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'ai_service.dart';
import 'verse_service.dart';
import 'theme_classifier_service.dart';
import 'cloudflare_ai_service.dart';
import 'ai_style_learning_service.dart';
import 'template_guidance_service.dart';
import '../models/chat_message.dart';
import '../models/bible_verse.dart';
import '../core/error/error_handler.dart';
import '../core/logging/app_logger.dart';

/// Local AI service implementation using Cloudflare Workers AI
///
/// This service combines:
/// - Cloudflare Workers AI (cloud-hosted LLM inference)
/// - Theme detection (keyword-based classification)
/// - Style learning (extracts patterns from 233 templates)
/// - Verse integration (Bible database queries)
/// - Template fallback (when Cloudflare unavailable)
class LocalAIService implements AIService {
  final VerseService _verseService = VerseService();
  final ThemeClassifierService _themeClassifier = ThemeClassifierService.instance;
  final AIStyleLearningService _styleService = AIStyleLearningService.instance;
  final AppLogger _logger = AppLogger.instance;

  bool _isInitialized = false;
  bool _cloudflareAvailable = false;

  // Fallback delays for template mode
  static const Duration _processingDelay = Duration(milliseconds: 1500);
  static const Duration _streamDelay = Duration(milliseconds: 50);

  @override
  bool get isReady => _isInitialized;

  bool get useCloudflareAI => _cloudflareAvailable;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    return await ErrorHandler.handleAsync(
      () async {
        _logger.info('Initializing AI Service with Cloudflare Workers AI', context: 'LocalAIService');

        // Initialize theme classifier (keyword-based, always works)
        await _themeClassifier.initialize();
        _logger.info('✅ Theme classifier initialized', context: 'LocalAIService');

        // Initialize style learning service (extracts patterns from 233 templates)
        await _styleService.initialize();
        _logger.info('✅ Style learning service initialized (233 templates analyzed)', context: 'LocalAIService');

        // Check if Cloudflare is available
        try {
          _cloudflareAvailable = await CloudflareAIService.instance.healthCheck();
          if (_cloudflareAvailable) {
            _logger.info('✅ Cloudflare Workers AI connected', context: 'LocalAIService');
          } else {
            _logger.warning('⚠️ Cloudflare Workers AI unavailable - using template mode', context: 'LocalAIService');
          }
        } catch (e) {
          _logger.error('❌ Cloudflare check failed: $e', context: 'LocalAIService');
          _logger.info('   Using template fallback mode', context: 'LocalAIService');
          _cloudflareAvailable = false;
        }

        _isInitialized = true;
        _logger.info('✅ AI Service ready (Mode: ${_cloudflareAvailable ? "Cloud AI" : "Template Fallback"})', context: 'LocalAIService');
      },
      context: 'LocalAIService.initialize',
    );
  }

  @override
  Future<AIResponse> generateResponse({
    required String userInput,
    List<ChatMessage> conversationHistory = const [],
    Map<String, dynamic>? context,
  }) async {
    final stopwatch = Stopwatch()..start();

    return await ErrorHandler.handleAsync(
      () async {
        if (!isReady) {
          _logger.warning('AI Service not ready, using fallback', context: 'LocalAIService');
          return _getFallbackResponse(userInput);
        }

        // Detect theme using keyword classifier
        final primaryTheme = await _themeClassifier.getPrimaryTheme(userInput);
        final themes = [primaryTheme];
        _logger.debug('Detected primary theme: $primaryTheme', context: 'LocalAIService');

        // Get relevant Bible verses from database
        final verses = await _getRelevantVersesForInput(userInput, themes);
        _logger.debug('Found ${verses.length} relevant verses', context: 'LocalAIService');

        // Generate AI response (Cloudflare or template fallback)
        final response = await _generateAIResponse(
          userInput: userInput,
          themes: themes,
          verses: verses,
          conversationHistory: conversationHistory,
        );

        stopwatch.stop();
        _logger.info(
          'Generated AI response in ${stopwatch.elapsedMilliseconds}ms',
          context: 'LocalAIService',
        );

        return AIResponse(
          content: response,
          verses: verses,
          processingTime: stopwatch.elapsed,
          confidence: 0.85 + (Random().nextDouble() * 0.1),
          metadata: {
            'themes': themes,
            'model': _cloudflareAvailable ? 'cloudflare-llama-3.1-8b' : 'template-fallback',
            'processing_method': _cloudflareAvailable ? 'cloud_ai' : 'template_selection',
            'verse_count': verses.length,
          },
        );
      },
      context: 'LocalAIService.generateResponse',
      fallbackValue: AIResponse(
        content: 'I apologize, but I\'m having trouble processing your request right now. Let me share some encouraging verses instead.',
        verses: await _getComfortVerses(),
        processingTime: stopwatch.elapsed,
        confidence: 0.5,
        metadata: {'error': 'Service error', 'fallback': true},
      ),
    );
  }

  @override
  Stream<String> generateResponseStream({
    required String userInput,
    List<ChatMessage> conversationHistory = const [],
    Map<String, dynamic>? context,
  }) async* {
    if (!isReady) {
      yield* _streamFallbackResponse(userInput);
      return;
    }

    try {
      // Generate the full response first
      final aiResponse = await generateResponse(
        userInput: userInput,
        conversationHistory: conversationHistory,
        context: context,
      );

      // Stream the response word by word for real-time feel
      final words = aiResponse.content.split(' ');
      for (int i = 0; i < words.length; i++) {
        await Future.delayed(_streamDelay);

        if (i == 0) {
          yield words[i];
        } else {
          yield ' ${words[i]}';
        }
      }
    } catch (e) {
      yield* _streamFallbackResponse(userInput);
    }
  }

  /// Generate AI response using Cloudflare or template fallback
  Future<String> _generateAIResponse({
    required String userInput,
    required List<String> themes,
    required List<BibleVerse> verses,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    if (_cloudflareAvailable) {
      try {
        return await _generateCloudflareResponse(
          userInput: userInput,
          themes: themes,
          verses: verses,
          conversationHistory: conversationHistory,
        );
      } catch (e) {
        _logger.error('❌ Cloudflare generation failed: $e', context: 'LocalAIService');
        _logger.info('   Falling back to templates', context: 'LocalAIService');
        _cloudflareAvailable = false; // Disable for this session
      }
    }

    // Fallback to template-based response
    return await _generateTemplateResponse(userInput, themes, verses);
  }

  /// Generate response using Cloudflare Workers AI with style learning
  Future<String> _generateCloudflareResponse({
    required String userInput,
    required List<String> themes,
    required List<BibleVerse> verses,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    final theme = themes.isNotEmpty ? themes.first : 'general';
    _logger.info('🤖 Generating Cloudflare AI response for theme: $theme', context: 'LocalAIService');

    // Get style patterns from our 233 templates
    final stylePatterns = _styleService.getStylePatterns();

    // Build system prompt using learned pastoral style
    final systemPrompt = _buildPastoralSystemPrompt(theme, stylePatterns);

    // Convert conversation history to Cloudflare format
    final messages = conversationHistory.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      };
    }).toList();

    // Call Cloudflare AI
    final response = await CloudflareAIService.instance.generatePastoralGuidance(
      userInput: userInput,
      systemPrompt: systemPrompt,
      conversationHistory: messages,
      verses: verses,
      maxTokens: 300,
    );

    _logger.info('✅ Cloudflare AI generated response (${response.length} chars)', context: 'LocalAIService');
    return response;
  }

  /// Build system prompt using learned pastoral style patterns
  String _buildPastoralSystemPrompt(String theme, PastoralStylePatterns stylePatterns) {
    final introStyle = stylePatterns.getIntroPattern(theme);
    final closingStyle = stylePatterns.getClosingPattern(theme);
    final verseStyle = stylePatterns.getVerseIntegrationPattern();

    return '''
You are a compassionate pastoral counselor providing biblical guidance.

RESPONSE STYLE (learned from 233 templates):

Opening Style: $introStyle
- Acknowledge the person's situation with empathy
- Validate their feelings
- Connect to their specific concern

Scripture Integration: $verseStyle
- Weave Bible verses naturally into your response
- Don't just list verses - explain how they apply
- Connect verses to their situation

Closing Style: $closingStyle
- End with hope and encouragement
- Remind them of God's presence
- Offer practical next steps

IMPORTANT:
- Keep responses under 300 tokens
- Be warm, compassionate, and Christ-centered
- Use the Bible verses provided in context
- Speak directly to their specific situation
''';
  }

  /// Generate template-based response (fallback when Cloudflare unavailable)
  Future<String> _generateTemplateResponse(
    String userInput,
    List<String> themes,
    List<BibleVerse> verses,
  ) async {
    await Future.delayed(_processingDelay);

    final theme = themes.isNotEmpty ? themes.first : 'general';
    _logger.info('ℹ️ Using template response for theme: $theme', context: 'LocalAIService');

    // Use template service to generate response
    return await TemplateGuidanceService.instance.generateTemplateResponse(
      userInput: userInput,
      theme: theme,
      understanding: null,
      additionalVerses: verses.map((v) => '${v.text} - ${v.reference}').toList(),
    );
  }

  @override
  Future<List<BibleVerse>> getRelevantVerses(String topic, {int limit = 3}) async {
    return await _verseService.getVersesForSituation(topic, limit: limit)
        .then((verses) => verses.map((v) => BibleVerse.fromMap(v)).toList());
  }

  Future<List<BibleVerse>> _getRelevantVersesForInput(
    String userInput,
    List<String> themes,
  ) async {
    final verses = <BibleVerse>[];

    // Get verses for detected themes
    for (final theme in themes.take(2)) {
      final themeVerses = await _verseService.getVersesByTheme(theme, limit: 2);
      verses.addAll(themeVerses.map((v) => BibleVerse.fromMap(v)));
    }

    // If no theme verses found, get situation-based verses
    if (verses.isEmpty) {
      final situationVerses = await _verseService.getVersesForSituation(userInput, limit: 2);
      verses.addAll(situationVerses.map((v) => BibleVerse.fromMap(v)));
    }

    return verses.take(3).toList();
  }

  Future<List<BibleVerse>> _getComfortVerses() async {
    final verses = await _verseService.getVersesByTheme('comfort', limit: 2);
    return verses.map((v) => BibleVerse.fromMap(v)).toList();
  }

  Future<AIResponse> _getFallbackResponse(String userInput) async {
    final theme = await _themeClassifier.getPrimaryTheme(userInput);
    return FallbackResponses.getThemeResponse(theme);
  }

  Stream<String> _streamFallbackResponse(String userInput) async* {
    final response = await _getFallbackResponse(userInput);
    final words = response.content.split(' ');

    for (int i = 0; i < words.length; i++) {
      await Future.delayed(_streamDelay);
      if (i == 0) {
        yield words[i];
      } else {
        yield ' ${words[i]}';
      }
    }
  }

  @override
  Future<void> dispose() async {
    await _themeClassifier.dispose();
    CloudflareAIService.instance.dispose();
    _isInitialized = false;
    debugPrint('🤖 Local AI Service disposed');
  }
}

/// AI Service factory for dependency injection
class AIServiceFactory {
  static AIService? _instance;

  static AIService get instance {
    _instance ??= LocalAIService();
    return _instance!;
  }

  static Future<void> initialize() async {
    await instance.initialize();
  }

  static Future<void> dispose() async {
    await _instance?.dispose();
    _instance = null;
  }

  // Helper methods for creating ChatMessage instances
  static ChatMessage createUserMessage({required String content}) {
    return ChatMessage.user(content: content);
  }

  static ChatMessage createAIMessage({required String content}) {
    return ChatMessage.ai(content: content);
  }
}

/// Performance monitoring for AI service
class AIPerformanceMonitor {
  static final List<Duration> _responseTimes = [];
  static final List<double> _confidenceScores = [];

  static void recordResponse(Duration responseTime, double confidence) {
    _responseTimes.add(responseTime);
    _confidenceScores.add(confidence);

    // Keep only last 100 responses for memory efficiency
    if (_responseTimes.length > 100) {
      _responseTimes.removeAt(0);
      _confidenceScores.removeAt(0);
    }
  }

  static Duration get averageResponseTime {
    if (_responseTimes.isEmpty) return Duration.zero;
    final totalMs = _responseTimes.fold<int>(0, (sum, time) => sum + time.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ _responseTimes.length);
  }

  static double get averageConfidence {
    if (_confidenceScores.isEmpty) return 0.0;
    return _confidenceScores.reduce((a, b) => a + b) / _confidenceScores.length;
  }

  static Map<String, dynamic> get stats => {
    'total_responses': _responseTimes.length,
    'average_response_time_ms': averageResponseTime.inMilliseconds,
    'average_confidence': averageConfidence,
    'responses_under_3s': _responseTimes.where((t) => t.inSeconds < 3).length,
  };
}
