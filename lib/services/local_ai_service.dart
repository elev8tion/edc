import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'ai_service.dart';
import 'verse_service.dart';
import '../models/chat_message.dart';
import '../models/bible_verse.dart';

/// Local AI service implementation using Llama model
class LocalAIService implements AIService {
  final VerseService _verseService = VerseService();

  bool _isInitialized = false;
  bool _isModelLoaded = false;

  // Simulated model state (will be replaced with actual Llama integration)
  static const Duration _processingDelay = Duration(milliseconds: 1500);
  static const Duration _streamDelay = Duration(milliseconds: 50);

  @override
  bool get isReady => _isInitialized && _isModelLoaded;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🤖 Initializing Local AI Service...');

      // Simulate model loading time
      await Future.delayed(const Duration(seconds: 2));

      // In production, this would:
      // 1. Check device compatibility
      // 2. Download/load Llama 3.2 1B model
      // 3. Initialize ONNX runtime or Ollama
      // 4. Warm up the model with test inference

      _isModelLoaded = await _loadModel();
      _isInitialized = true;

      debugPrint('✅ Local AI Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize AI Service: $e');
      _isInitialized = false;
      _isModelLoaded = false;
    }
  }

  Future<bool> _loadModel() async {
    try {
      // Simulate device compatibility check
      if (!_isDeviceCompatible()) {
        debugPrint('⚠️ Device not compatible with local AI model');
        return false;
      }

      // Simulate model loading
      debugPrint('📦 Loading Llama 3.2 1B model...');
      await Future.delayed(const Duration(seconds: 1));

      // In production, this would:
      // - Load the quantized model file
      // - Initialize the inference engine
      // - Set up memory allocation
      // - Validate model integrity

      debugPrint('🚀 Model loaded and ready for inference');
      return true;
    } catch (e) {
      debugPrint('❌ Model loading failed: $e');
      return false;
    }
  }

  bool _isDeviceCompatible() {
    // In production, check:
    // - Available RAM (need ~2GB for 1B model)
    // - CPU architecture compatibility
    // - Operating system support
    // - Flutter platform (mobile vs desktop)

    return true; // Simplified for demo
  }

  @override
  Future<AIResponse> generateResponse({
    required String userInput,
    List<ChatMessage> conversationHistory = const [],
    Map<String, dynamic>? context,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      if (!isReady) {
        debugPrint('⚠️ AI Service not ready, using fallback response');
        return _getFallbackResponse(userInput);
      }

      // Detect themes from user input
      final themes = BiblicalPrompts.detectThemes(userInput);
      debugPrint('🎯 Detected themes: $themes');

      // Get relevant verses
      final verses = await _getRelevantVersesForInput(userInput, themes);

      // Generate AI response
      final response = await _generateAIResponse(
        userInput: userInput,
        themes: themes,
        verses: verses,
        conversationHistory: conversationHistory,
      );

      stopwatch.stop();

      return AIResponse(
        content: response,
        verses: verses,
        processingTime: stopwatch.elapsed,
        confidence: 0.85 + (Random().nextDouble() * 0.1), // 0.85-0.95
        metadata: {
          'themes': themes,
          'model': 'llama-3.2-1b-instruct',
          'processing_method': 'local_inference',
        },
      );

    } catch (e) {
      debugPrint('❌ AI generation error: $e');
      stopwatch.stop();

      return AIResponse(
        content: 'I apologize, but I\'m having trouble processing your request right now. Let me share some encouraging verses instead.',
        verses: await _getComfortVerses(),
        processingTime: stopwatch.elapsed,
        confidence: 0.5,
        metadata: {'error': e.toString(), 'fallback': true},
      );
    }
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

  Future<String> _generateAIResponse({
    required String userInput,
    required List<String> themes,
    required List<BibleVerse> verses,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    // Simulate AI processing time
    await Future.delayed(_processingDelay);

    // In production, this would:
    // 1. Build the prompt with biblical context
    // 2. Run inference on the Llama model
    // 3. Parse and validate the response
    // 4. Ensure theological soundness

    return _buildContextualResponse(userInput, themes, verses);
  }

  String _buildContextualResponse(
    String userInput,
    List<String> themes,
    List<BibleVerse> verses,
  ) {
    final responses = _getContextualResponses();
    final themeKey = themes.isNotEmpty ? themes.first : 'general';
    final responseTemplates = responses[themeKey] ?? responses['general']!;

    final template = responseTemplates[Random().nextInt(responseTemplates.length)];

    // Personalize the response based on user input
    return template
        .replaceAll('{situation}', _extractSituation(userInput))
        .replaceAll('{theme}', _getThemeDescription(themeKey))
        .replaceAll('{verse_count}', '${verses.length}');
  }

  String _extractSituation(String userInput) {
    // Simple extraction - in production would use more sophisticated NLP
    if (userInput.length > 50) {
      return userInput.substring(0, 47) + '...';
    }
    return userInput;
  }

  String _getThemeDescription(String theme) {
    const descriptions = {
      'anxiety': 'feelings of worry and stress',
      'depression': 'feelings of sadness and discouragement',
      'strength': 'need for spiritual strength',
      'guidance': 'seeking God\'s direction',
      'forgiveness': 'questions about forgiveness',
      'purpose': 'searching for life\'s purpose',
      'relationships': 'relationship challenges',
      'fear': 'feelings of fear and uncertainty',
      'doubt': 'spiritual doubts and questions',
      'gratitude': 'expressions of thankfulness',
      'general': 'your spiritual journey',
    };
    return descriptions[theme] ?? descriptions['general']!;
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

  AIResponse _getFallbackResponse(String userInput) {
    final themes = BiblicalPrompts.detectThemes(userInput);
    if (themes.isNotEmpty) {
      return FallbackResponses.getThemeResponse(themes.first);
    }
    return FallbackResponses.getRandomResponse();
  }

  Stream<String> _streamFallbackResponse(String userInput) async* {
    final response = _getFallbackResponse(userInput);
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
    // In production, this would:
    // - Unload the model from memory
    // - Clean up ONNX runtime resources
    // - Close any open streams or connections

    _isInitialized = false;
    _isModelLoaded = false;
    debugPrint('🤖 Local AI Service disposed');
  }

  /// Get contextual response templates
  Map<String, List<String>> _getContextualResponses() {
    return {
      'anxiety': [
        'I can sense the weight of worry in your words about {situation}. It\'s completely natural to feel anxious, and God understands these feelings. He invites you to cast all your anxieties on Him because He cares for you deeply. Take comfort in knowing that His peace, which surpasses all understanding, is available to guard your heart and mind.',
        'Your concerns about {situation} are valid, and it\'s okay to feel overwhelmed. Remember that God is bigger than any anxiety you\'re facing. He promises to be your refuge and strength, a very present help in trouble. These verses speak to His care for you in moments of worry.',
        'I hear the anxiety in your heart regarding {situation}. Please know that you don\'re alone in this feeling. God sees your struggle and wants to comfort you. His perfect love casts out fear, and His presence brings peace that the world cannot give.',
      ],
      'depression': [
        'I can feel the heaviness in your words about {situation}, and I want you to know that your feelings are valid. Even in the darkest moments, God\'s love for you remains constant and unwavering. He is close to the brokenhearted and promises that weeping may endure for a night, but joy comes in the morning.',
        'Thank you for sharing your heart about {situation}. Depression can feel isolating, but remember that God is with you in the valley. His plans for you are good, to give you a future and a hope. These verses remind us of His faithfulness even in difficult seasons.',
        'Your struggle with {situation} doesn\'t define you or diminish your worth in God\'s eyes. He sees your pain and wants to bring healing and hope. Remember that His strength is made perfect in weakness, and He can bring beauty from ashes.',
      ],
      'strength': [
        'When facing {situation}, it\'s natural to feel like our own strength isn\'t enough - and that\'s exactly where God wants us to be. His power is made perfect in our weakness, and when we can\'t, He can. These verses remind us that divine strength is available in our weakest moments.',
        'I understand you\'re going through {situation} and feeling overwhelmed. Remember that those who wait on the Lord will renew their strength. God doesn\'t promise the journey will be easy, but He promises to be with you every step of the way.',
        'Your situation with {situation} requires strength beyond what you feel you have, and that\'s okay. God specializes in doing the impossible through ordinary people who rely on Him. His strength is limitless and always available to those who call on His name.',
      ],
      'guidance': [
        'Seeking direction regarding {situation} shows wisdom and humility. God promises to guide those who acknowledge Him in all their ways. Trust that He will make your paths straight as you commit your decisions to Him in prayer.',
        'Your question about {situation} shows a heart that wants to follow God\'s will. He promises that if any of us lacks wisdom, we can ask Him, and He gives generously to all without finding fault. These verses will encourage you as you seek His guidance.',
        'Navigating {situation} can feel overwhelming when the path isn\'t clear. Remember that God\'s word is a lamp to your feet and a light to your path. He will guide you step by step as you trust in Him.',
      ],
      'general': [
        'Thank you for sharing about {situation}. God sees your heart and understands exactly what you\'re going through. His love for you is constant, and His grace is sufficient for every challenge you face. These verses speak to His faithfulness in all circumstances.',
        'I appreciate you opening your heart about {situation}. Remember that God is working all things together for good for those who love Him. Even when we can\'t see the bigger picture, we can trust in His character and His promises.',
        'Your experience with {situation} matters to God, and so do you. He has plans for your life that are good, and His presence goes with you wherever you go. Take comfort in these truths from His word.',
      ],
    };
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