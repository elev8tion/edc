import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'ai_service.dart';
import 'verse_service.dart';
import 'theme_classifier_service.dart';
import 'ai_style_learning_service.dart';
import 'template_guidance_service.dart';
import 'gemini_ai_service.dart';
import '../models/chat_message.dart';
import '../models/bible_verse.dart';
import '../core/error/error_handler.dart';
import '../core/logging/app_logger.dart';

/// Local AI service implementation using Google Gemini AI
///
/// This service combines:
/// - Theme detection (keyword-based classification)
/// - Style learning (extracts patterns from 233 templates)
/// - Verse integration (Bible database queries)
/// - Gemini AI (intelligent responses using templates as few-shot examples)
class LocalAIService implements AIService {
  final VerseService _verseService = VerseService();
  final ThemeClassifierService _themeClassifier = ThemeClassifierService.instance;
  final AIStyleLearningService _styleService = AIStyleLearningService.instance;
  final GeminiAIService _geminiService = GeminiAIService.instance;
  final AppLogger _logger = AppLogger.instance;

  bool _isInitialized = false;

  // Delays for realistic response timing
  static const Duration _processingDelay = Duration(milliseconds: 1500);
  static const Duration _streamDelay = Duration(milliseconds: 50);

  @override
  bool get isReady => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    return await ErrorHandler.handleAsync(
      () async {
        _logger.info('Initializing AI Service (Gemini AI Mode)', context: 'LocalAIService');

        // Initialize Gemini AI
        await _geminiService.initialize();
        _logger.info('✅ Gemini AI initialized (gemini-1.5-flash)', context: 'LocalAIService');

        // Initialize theme classifier (keyword-based)
        await _themeClassifier.initialize();
        _logger.info('✅ Theme classifier initialized', context: 'LocalAIService');

        // Initialize style learning service (extracts patterns from 233 templates)
        await _styleService.initialize();
        _logger.info('✅ Style learning service initialized (233 templates)', context: 'LocalAIService');

        _isInitialized = true;
        _logger.info('✅ AI Service ready (Mode: Gemini AI with template guidance)', context: 'LocalAIService');
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
            'model': 'gemini-1.5-flash',
            'processing_method': 'ai_generation',
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

  /// Generate AI response using Gemini AI (NO FALLBACKS)
  Future<String> _generateAIResponse({
    required String userInput,
    required List<String> themes,
    required List<BibleVerse> verses,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    // Use Gemini AI for intelligent response - NO FALLBACKS
    final theme = themes.isNotEmpty ? themes.first : 'general';
    final conversationStrings = conversationHistory
        .take(3)
        .map((msg) => '${msg.isUser ? "USER" : "ASSISTANT"}: ${msg.content}')
        .toList();

    _logger.info('🤖 Generating Gemini AI response for theme: $theme', context: 'LocalAIService');

    return await _geminiService.generateResponse(
      userInput: userInput,
      theme: theme,
      verses: verses,
      conversationHistory: conversationStrings,
    );
  }

  /// Generate template-based response
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
