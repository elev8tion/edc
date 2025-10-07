import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// LSTM-based text generation service using TFLite
/// Generates Christian-themed responses character by character
class TextGeneratorService {
  static TextGeneratorService? _instance;
  late Interpreter _interpreter;
  final Map<String, int> _char2idx = {};
  final Map<int, String> _idx2char = {};
  bool _isInitialized = false;

  // Model configuration
  static const String _modelFile = 'assets/models/text_generator.tflite';
  static const String _vocabFile = 'assets/models/char_vocab.txt';
  static const int _maxSeqLength = 100;

  // Singleton pattern
  static TextGeneratorService get instance {
    _instance ??= TextGeneratorService._internal();
    return _instance!;
  }

  TextGeneratorService._internal();

  /// Initialize the text generator
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadModel();
      await _loadVocabulary();
      _isInitialized = true;
      debugPrint('✅ Text generator initialized');
    } catch (e) {
      debugPrint('⚠️ Text generator initialization failed: $e');
      rethrow;
    }
  }

  /// Load TFLite model with platform-specific optimizations
  Future<void> _loadModel() async {
    final options = InterpreterOptions();

    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    try {
      _interpreter = await Interpreter.fromAsset(_modelFile, options: options);
      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Error loading model: $e');
      rethrow;
    }
  }

  /// Load character vocabulary
  Future<void> _loadVocabulary() async {
    try {
      final vocabData = await rootBundle.loadString(_vocabFile);
      final chars = vocabData.split('\n').where((line) => line.isNotEmpty).toList();

      for (int i = 0; i < chars.length; i++) {
        _char2idx[chars[i]] = i;
        _idx2char[i] = chars[i];
      }

      debugPrint('Loaded vocabulary: ${_char2idx.length} characters');
    } catch (e) {
      debugPrint('Error loading vocabulary: $e');
      rethrow;
    }
  }

  /// Generate text based on a prompt
  Future<String> generateText({
    required String prompt,
    int maxLength = 200,
    double temperature = 0.7,
  }) async {
    if (!_isInitialized) await initialize();

    // Encode the prompt
    final inputSequence = _encodeText(prompt);
    final generatedText = StringBuffer(prompt);

    // Generate character by character
    for (int i = 0; i < maxLength; i++) {
      final nextChar = await _predictNextChar(inputSequence, temperature);

      if (nextChar == null || nextChar == '<END>') break;

      generatedText.write(nextChar);

      // Update input sequence (sliding window)
      final charIdx = _char2idx[nextChar] ?? 0;
      inputSequence.add(charIdx);
      if (inputSequence.length > _maxSeqLength) {
        inputSequence.removeAt(0);
      }
    }

    return generatedText.toString();
  }

  /// Predict the next character using the model
  Future<String?> _predictNextChar(List<int> inputSequence, double temperature) async {
    try {
      // Prepare input tensor
      final input = _prepareInput(inputSequence);

      // Prepare output tensor
      final outputShape = _interpreter.getOutputTensor(0).shape;
      final output = List.generate(
        outputShape[0],
        (_) => List<double>.filled(outputShape[1], 0),
      );

      // Run inference
      _interpreter.run(input, output);

      // Apply temperature sampling
      final probabilities = _applySoftmax(output[0], temperature);
      final predictedIdx = _sampleFromDistribution(probabilities);

      return _idx2char[predictedIdx];
    } catch (e) {
      debugPrint('Error predicting next char: $e');
      return null;
    }
  }

  /// Prepare input tensor for the model
  List<List<double>> _prepareInput(List<int> sequence) {
    final paddedSeq = List<double>.filled(_maxSeqLength, 0.0);

    final startIdx = max(0, sequence.length - _maxSeqLength);
    for (int i = startIdx; i < sequence.length; i++) {
      paddedSeq[i - startIdx] = sequence[i].toDouble();
    }

    return [paddedSeq];
  }

  /// Encode text to character indices
  List<int> _encodeText(String text) {
    return text.split('').map((char) {
      return _char2idx[char] ?? _char2idx[' '] ?? 0;
    }).toList();
  }

  /// Apply softmax with temperature
  List<double> _applySoftmax(List<double> logits, double temperature) {
    final scaledLogits = logits.map((x) => x / temperature).toList();
    final maxLogit = scaledLogits.reduce(max);

    final expValues = scaledLogits.map((x) => exp(x - maxLogit)).toList();
    final sumExp = expValues.reduce((a, b) => a + b);

    return expValues.map((x) => x / sumExp).toList();
  }

  /// Sample from probability distribution
  int _sampleFromDistribution(List<double> probabilities) {
    final random = Random().nextDouble();
    double cumulative = 0.0;

    for (int i = 0; i < probabilities.length; i++) {
      cumulative += probabilities[i];
      if (random <= cumulative) {
        return i;
      }
    }

    return probabilities.length - 1;
  }

  /// Generate a response to user input
  Future<String> generateResponse({
    required String userInput,
    required String theme,
    int maxLength = 300,
  }) async {
    // Create a contextual prompt
    final prompt = _buildPrompt(userInput, theme);

    // Generate text
    final response = await generateText(
      prompt: prompt,
      maxLength: maxLength,
      temperature: 0.8,
    );

    // Extract just the generated part (after prompt)
    if (response.length > prompt.length) {
      return response.substring(prompt.length).trim();
    }

    return response;
  }

  /// Build a prompt for generation
  String _buildPrompt(String userInput, String theme) {
    // Create a Christian-themed prompt structure
    final prompts = {
      'anxiety': 'When facing worry, remember that ',
      'depression': 'In times of sadness, God says ',
      'strength': 'For spiritual strength, know that ',
      'guidance': 'Seeking direction? God promises ',
      'forgiveness': 'About forgiveness, Scripture tells us ',
      'purpose': 'For your life\'s purpose, understand that ',
      'general': 'In response to your heart, consider that ',
    };

    return prompts[theme] ?? prompts['general']!;
  }

  /// Check if initialized
  bool get isReady => _isInitialized;

  /// Get vocabulary size
  int get vocabSize => _char2idx.length;

  /// Dispose resources
  Future<void> dispose() async {
    if (_isInitialized) {
      _interpreter.close();
      _isInitialized = false;
      debugPrint('Text generator disposed');
    }
  }
}
