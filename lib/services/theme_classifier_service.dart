import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// TFLite-based theme classifier for biblical guidance
/// Uses sentiment analysis model to detect emotional themes in user input
class ThemeClassifierService {
  static ThemeClassifierService? _instance;
  late Interpreter _interpreter;
  final _dict = <String, int>{};
  bool _isInitialized = false;

  // Model configuration
  static const String _modelFile = 'assets/models/text_classification.tflite';
  static const String _vocabFile = 'assets/models/vocab';
  static const int _sentenceLen = 256;
  static const String _start = '<START>';
  static const String _pad = '<PAD>';
  static const String _unk = '<UNKNOWN>';

  // Biblical themes mapping based on sentiment
  // The model returns [negative_score, positive_score]
  // We map these to biblical themes contextually
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

  // Singleton pattern
  static ThemeClassifierService get instance {
    _instance ??= ThemeClassifierService._internal();
    return _instance!;
  }

  ThemeClassifierService._internal();

  /// Initialize the TFLite model and vocabulary
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadModel();
      await _loadDictionary();
      _isInitialized = true;
      print('✅ Theme classifier initialized with TFLite sentiment model');
    } catch (e, stackTrace) {
      print('⚠️ Theme classifier initialization failed: $e');
      print('Stack trace: $stackTrace');
      _isInitialized = false;
    }
  }

  /// Load TFLite model with platform-specific optimization
  Future<void> _loadModel() async {
    final options = InterpreterOptions();

    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    _interpreter = await Interpreter.fromAsset(_modelFile, options: options);
    print('✅ TFLite model loaded successfully');
  }

  /// Load vocabulary for tokenization
  Future<void> _loadDictionary() async {
    final vocab = await rootBundle.loadString(_vocabFile);
    _dict.addEntries(
      vocab
          .split('\n')
          .map((e) => e.trim().split(' '))
          .where((e) => e.length == 2)
          .map((e) => MapEntry(e[0], int.parse(e[1]))),
    );
    print('✅ Vocabulary loaded (${_dict.length} tokens)');
  }

  /// Classify user input and return detected themes with confidence scores
  Future<Map<String, double>> classifyThemes(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      // Fallback to keyword-based if model failed to load
      return _classifyWithKeywords(text.toLowerCase());
    }

    try {
      // Run sentiment analysis using TFLite
      final sentimentScores = _classifySentiment(text);
      final negativeScore = sentimentScores[0];
      final positiveScore = sentimentScores[1];

      // Combine TFLite sentiment with keyword detection for better accuracy
      final keywordScores = _classifyWithKeywords(text.toLowerCase());

      // Blend AI sentiment with keyword-based theme detection
      return _blendScores(keywordScores, negativeScore, positiveScore);
    } catch (e) {
      print('⚠️ TFLite classification failed, using keyword fallback: $e');
      return _classifyWithKeywords(text.toLowerCase());
    }
  }

  /// Run TFLite sentiment classification
  List<double> _classifySentiment(String rawText) {
    final input = _tokenizeInputText(rawText);
    final output = <List<double>>[List<double>.filled(2, 0)];

    _interpreter.run(input, output);

    return [output[0][0], output[0][1]]; // [negative, positive]
  }

  /// Tokenize text for TFLite model input
  List<List<double>> _tokenizeInputText(String text) {
    final toks = text.toLowerCase().split(' ');

    final vec = List<double>.generate(_sentenceLen, (index) {
      if (index >= toks.length) {
        return _dict[_pad]!.toDouble();
      }
      final tok = toks[index];
      return _dict.containsKey(tok)
          ? _dict[tok]!.toDouble()
          : _dict[_unk]!.toDouble();
    });

    return [vec];
  }

  /// Blend TFLite sentiment scores with keyword-based theme detection
  Map<String, double> _blendScores(
    Map<String, double> keywordScores,
    double negativeScore,
    double positiveScore,
  ) {
    // If keywords found a strong match, use those
    if (keywordScores.isNotEmpty && keywordScores.values.first > 0.7) {
      return keywordScores;
    }

    // Otherwise, map sentiment to themes
    final blended = <String, double>{};

    // Negative sentiment suggests these themes
    if (negativeScore > 0.6) {
      blended['anxiety'] = negativeScore * 0.8;
      blended['depression'] = negativeScore * 0.7;
      blended['fear'] = negativeScore * 0.6;
      blended['doubt'] = negativeScore * 0.5;
    }

    // Positive sentiment suggests these themes
    if (positiveScore > 0.6) {
      blended['gratitude'] = positiveScore * 0.9;
      blended['strength'] = positiveScore * 0.7;
      blended['purpose'] = positiveScore * 0.6;
    }

    // Merge with keyword scores
    for (final entry in keywordScores.entries) {
      blended[entry.key] = (blended[entry.key] ?? 0) + (entry.value * 0.5);
    }

    if (blended.isEmpty) {
      return {'general': 1.0};
    }

    // Normalize
    final maxScore = blended.values.reduce((a, b) => a > b ? a : b);
    return blended.map((k, v) => MapEntry(k, v / maxScore));
  }

  /// Get the primary theme from user input
  Future<String> getPrimaryTheme(String text) async {
    final themeScores = await classifyThemes(text);
    if (themeScores.isEmpty) return 'general';

    // Return theme with highest confidence
    return themeScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Keyword-based classification (fallback or supplement to TFLite)
  Map<String, double> _classifyWithKeywords(String text) {
    final scores = <String, double>{};

    // Anxiety keywords
    final anxietyKeywords = ['anxious', 'worry', 'worried', 'stress', 'stressed', 'nervous', 'panic', 'overwhelmed', 'fear', 'afraid'];
    scores['anxiety'] = _calculateKeywordScore(text, anxietyKeywords);

    // Depression keywords
    final depressionKeywords = ['depressed', 'sad', 'hopeless', 'alone', 'lonely', 'empty', 'worthless', 'dark', 'despair'];
    scores['depression'] = _calculateKeywordScore(text, depressionKeywords);

    // Strength keywords
    final strengthKeywords = ['weak', 'tired', 'exhausted', 'strength', 'strong', 'courage', 'power', 'energy'];
    scores['strength'] = _calculateKeywordScore(text, strengthKeywords);

    // Guidance keywords
    final guidanceKeywords = ['confused', 'lost', 'direction', 'path', 'guide', 'decision', 'choice', 'unsure', 'uncertain', 'help'];
    scores['guidance'] = _calculateKeywordScore(text, guidanceKeywords);

    // Forgiveness keywords
    final forgivenessKeywords = ['forgive', 'forgiveness', 'guilt', 'guilty', 'shame', 'regret', 'sorry', 'mistake'];
    scores['forgiveness'] = _calculateKeywordScore(text, forgivenessKeywords);

    // Purpose keywords
    final purposeKeywords = ['purpose', 'meaning', 'why', 'point', 'calling', 'plan', 'destiny'];
    scores['purpose'] = _calculateKeywordScore(text, purposeKeywords);

    // Relationships keywords
    final relationshipsKeywords = ['relationship', 'marriage', 'family', 'friend', 'friendship', 'conflict', 'argument', 'divorce'];
    scores['relationships'] = _calculateKeywordScore(text, relationshipsKeywords);

    // Fear keywords
    final fearKeywords = ['fear', 'scared', 'afraid', 'terrified', 'frightened', 'dread'];
    scores['fear'] = _calculateKeywordScore(text, fearKeywords);

    // Doubt keywords
    final doubtKeywords = ['doubt', 'question', 'unsure', 'uncertain', 'faith', 'believe', 'trust'];
    scores['doubt'] = _calculateKeywordScore(text, doubtKeywords);

    // Gratitude keywords
    final gratitudeKeywords = ['thank', 'grateful', 'thankful', 'blessing', 'blessed', 'appreciate', 'gratitude'];
    scores['gratitude'] = _calculateKeywordScore(text, gratitudeKeywords);

    // Filter out zero scores and normalize
    final nonZeroScores = Map.fromEntries(
      scores.entries.where((e) => e.value > 0),
    );

    if (nonZeroScores.isEmpty) {
      return {'general': 1.0};
    }

    // Normalize scores
    final maxScore = nonZeroScores.values.reduce((a, b) => a > b ? a : b);
    return nonZeroScores.map((k, v) => MapEntry(k, v / maxScore));
  }

  /// Calculate keyword match score
  double _calculateKeywordScore(String text, List<String> keywords) {
    double score = 0.0;
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        score += 1.0;
      }
    }
    return score;
  }

  /// Check if classifier is ready
  bool get isReady => _isInitialized;

  /// Dispose resources
  Future<void> dispose() async {
    try {
      if (_isInitialized) {
        _interpreter.close();
      }
      _isInitialized = false;
      print('Theme classifier disposed');
    } catch (e) {
      print('⚠️ Error disposing theme classifier: $e');
    }
  }
}
