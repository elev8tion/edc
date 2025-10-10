import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/bible_verse.dart';
import '../core/logging/app_logger.dart';

class TrainingExample {
  final String userInput;
  final String response;

  TrainingExample({required this.userInput, required this.response});
}

/// Google Gemini AI service trained on 19,750 real examples
class GeminiAIService {
  static GeminiAIService? _instance;
  static GeminiAIService get instance {
    _instance ??= GeminiAIService._internal();
    return _instance!;
  }

  GeminiAIService._internal();

  final AppLogger _logger = AppLogger.instance;
  GenerativeModel? _model;
  bool _isInitialized = false;

  // Your 19,750 training examples loaded in memory
  List<TrainingExample> _trainingExamples = [];

  // API key from environment variable (passed via --dart-define)
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  bool get isReady => _isInitialized && _model != null && _trainingExamples.isNotEmpty;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.info('Initializing Gemini AI Service', context: 'GeminiAIService');

      // Initialize Gemini model
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.9,
          topP: 0.95,
          topK: 40,
          maxOutputTokens: 1000,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        ],
      );

      // Load your 19,750 training examples
      await _loadTrainingData();

      _isInitialized = true;
      _logger.info('✅ Gemini AI ready with ${_trainingExamples.length} training examples', context: 'GeminiAIService');
    } catch (e) {
      _logger.error('Failed to initialize Gemini: $e', context: 'GeminiAIService');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Load your 19,750 LSTM training examples
  Future<void> _loadTrainingData() async {
    try {
      final String data = await rootBundle.loadString('assets/lstm_training_data.txt');
      final lines = data.split('\n');

      String? currentUser;
      String? currentResponse;

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        if (line.startsWith('USER: ')) {
          // Save previous example if we have one
          if (currentUser != null && currentResponse != null) {
            _trainingExamples.add(TrainingExample(
              userInput: currentUser,
              response: currentResponse,
            ));
          }
          currentUser = line.substring(6).trim();
          currentResponse = null;
        } else if (line.startsWith('RESPONSE: ')) {
          currentResponse = line.substring(10).trim();
        }
      }

      // Add final example
      if (currentUser != null && currentResponse != null) {
        _trainingExamples.add(TrainingExample(
          userInput: currentUser,
          response: currentResponse,
        ));
      }

      _logger.info('Loaded ${_trainingExamples.length} training examples', context: 'GeminiAIService');
    } catch (e) {
      _logger.error('Failed to load training data: $e', context: 'GeminiAIService');
      throw Exception('Cannot initialize without training data');
    }
  }

  /// Find the most relevant training examples for the user's input
  List<TrainingExample> _findRelevantExamples(String userInput, int count) {
    final inputLower = userInput.toLowerCase();
    final words = inputLower.split(RegExp(r'\W+')).where((w) => w.length > 3).toSet();

    // Score each example by keyword overlap
    final scored = _trainingExamples.map((example) {
      final exampleLower = example.userInput.toLowerCase();
      int score = 0;

      // Check for word matches
      for (final word in words) {
        if (exampleLower.contains(word)) {
          score += 2;
        }
      }

      // Bonus for similar sentence structure
      if (exampleLower.contains('?') && inputLower.contains('?')) score += 1;
      if (exampleLower.startsWith('i ') && inputLower.startsWith('i ')) score += 1;
      if (exampleLower.contains('help') && inputLower.contains('help')) score += 2;
      if (exampleLower.contains('feel') && inputLower.contains('feel')) score += 2;

      return {'example': example, 'score': score};
    }).toList();

    // Sort by score descending
    scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    // Return top matches
    return scored
        .take(count)
        .where((item) => (item['score'] as int) > 0)
        .map((item) => item['example'] as TrainingExample)
        .toList();
  }

  /// Generate response using Gemini + your 19,750 training examples
  Future<String> generateResponse({
    required String userInput,
    required String theme,
    required List<BibleVerse> verses,
    List<String>? conversationHistory,
  }) async {
    if (!isReady) {
      throw Exception('Gemini AI Service not initialized - cannot generate response');
    }

    try {
      // Find 3-5 most relevant examples from your training data
      final relevantExamples = _findRelevantExamples(userInput, 5);

      _logger.info('Found ${relevantExamples.length} relevant training examples', context: 'GeminiAIService');

      final prompt = _buildPrompt(
        userInput: userInput,
        theme: theme,
        verses: verses,
        relevantExamples: relevantExamples,
        conversationHistory: conversationHistory,
      );

      _logger.info('Sending request to Gemini...', context: 'GeminiAIService');

      final response = await _model!.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini returned empty response');
      }

      _logger.info('✅ Generated intelligent response from Gemini', context: 'GeminiAIService');
      return response.text!;
    } catch (e) {
      _logger.error('Gemini generation error: $e', context: 'GeminiAIService');
      rethrow; // NO FALLBACKS
    }
  }

  String _buildPrompt({
    required String userInput,
    required String theme,
    required List<BibleVerse> verses,
    required List<TrainingExample> relevantExamples,
    List<String>? conversationHistory,
  }) {
    final buffer = StringBuffer();

    // System prompt
    buffer.writeln('''You are a compassionate Christian pastoral counselor trained on 19,750 real counseling examples.

YOUR ROLE:
- Provide empathetic, biblical, practical guidance
- Use warm, understanding tone
- Reference Bible verses naturally in your response
- Keep responses 2-3 paragraphs
- Be specific and actionable

The user is experiencing: $theme

Relevant Bible verses to weave into your response:''');

    // Add Bible verses
    for (final verse in verses) {
      buffer.writeln('- "${verse.text}" (${verse.reference})');
    }
    buffer.writeln();

    // Real training examples for context
    if (relevantExamples.isNotEmpty) {
      buffer.writeln('TRAINING EXAMPLES (learn from these pastoral responses):');
      buffer.writeln();
      for (final example in relevantExamples) {
        buffer.writeln('USER: ${example.userInput}');
        buffer.writeln('COUNSELOR: ${example.response}');
        buffer.writeln();
      }
    }

    // Conversation context
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      buffer.writeln('Recent conversation:');
      for (final msg in conversationHistory.take(3)) {
        buffer.writeln(msg);
      }
      buffer.writeln();
    }

    // User's message
    buffer.writeln('USER: $userInput');
    buffer.writeln();
    buffer.writeln('COUNSELOR: ');

    return buffer.toString();
  }

  void dispose() {
    _isInitialized = false;
    _model = null;
    _trainingExamples.clear();
    _logger.info('Gemini AI Service disposed', context: 'GeminiAIService');
  }
}
