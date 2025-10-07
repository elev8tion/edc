import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Tokenizer for Phi-3 Mini model
/// Handles text encoding/decoding using the model's vocabulary
class Phi3Tokenizer {
  static Phi3Tokenizer? _instance;

  Map<String, int>? _vocab;
  Map<int, String>? _reverseVocab;
  bool _isInitialized = false;

  // Special tokens for Phi-3
  static const int bosTokenId = 1;  // Beginning of sequence
  static const int eosTokenId = 2;  // End of sequence
  static const int padTokenId = 0;  // Padding
  static const int unkTokenId = 3;  // Unknown token

  // Phi-3 chat template tokens
  static const String systemStartToken = '<|system|>';
  static const String systemEndToken = '<|end|>';
  static const String userStartToken = '<|user|>';
  static const String userEndToken = '<|end|>';
  static const String assistantStartToken = '<|assistant|>';
  static const String assistantEndToken = '<|end|>';

  Phi3Tokenizer._();

  static Phi3Tokenizer get instance {
    _instance ??= Phi3Tokenizer._();
    return _instance!;
  }

  bool get isReady => _isInitialized;

  /// Initialize the tokenizer by loading vocabulary
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ Tokenizer already initialized');
      return;
    }

    try {
      debugPrint('📖 Initializing Phi-3 tokenizer...');

      // Try to load tokenizer.json from assets
      try {
        final tokenizerJson = await rootBundle.loadString('assets/models/tokenizer.json');
        final data = json.decode(tokenizerJson);

        // Extract vocabulary
        if (data['model'] != null && data['model']['vocab'] != null) {
          _vocab = Map<String, int>.from(data['model']['vocab']);
          _reverseVocab = _vocab!.map((key, value) => MapEntry(value, key));

          _isInitialized = true;
          debugPrint('✅ Tokenizer initialized with ${_vocab!.length} tokens');
          return;
        }
      } catch (e) {
        debugPrint('⚠️ Could not load tokenizer.json: $e');
      }

      // Fallback: Use basic tokenization
      debugPrint('⚠️ Using fallback basic tokenization');
      _initializeFallbackTokenizer();

    } catch (e) {
      debugPrint('❌ Failed to initialize tokenizer: $e');
      _initializeFallbackTokenizer();
    }
  }

  /// Initialize a basic fallback tokenizer
  void _initializeFallbackTokenizer() {
    // Simple word-based tokenization for fallback
    _vocab = {};
    _reverseVocab = {};
    _isInitialized = true;
    debugPrint('✅ Fallback tokenizer initialized');
  }

  /// Encode text to token IDs
  List<int> encode(String text, {bool addSpecialTokens = true}) {
    if (!_isInitialized) {
      throw StateError('Tokenizer not initialized');
    }

    // Simple whitespace tokenization for fallback
    if (_vocab == null || _vocab!.isEmpty) {
      return _encodeBasic(text);
    }

    final tokens = <int>[];

    if (addSpecialTokens) {
      tokens.add(bosTokenId);
    }

    // Tokenize using vocabulary
    final words = text.split(RegExp(r'\s+'));
    for (final word in words) {
      final tokenId = _vocab![word] ?? unkTokenId;
      tokens.add(tokenId);
    }

    if (addSpecialTokens) {
      tokens.add(eosTokenId);
    }

    return tokens;
  }

  /// Basic encoding fallback (character-based)
  List<int> _encodeBasic(String text) {
    // Convert to character codes with offset
    return text.codeUnits.map((c) => c + 100).toList();
  }

  /// Decode token IDs to text
  String decode(List<int> tokenIds, {bool skipSpecialTokens = true}) {
    if (!_isInitialized) {
      throw StateError('Tokenizer not initialized');
    }

    if (_reverseVocab == null || _reverseVocab!.isEmpty) {
      return _decodeBasic(tokenIds);
    }

    final tokens = <String>[];

    for (final id in tokenIds) {
      // Skip special tokens if requested
      if (skipSpecialTokens) {
        if (id == bosTokenId || id == eosTokenId || id == padTokenId) {
          continue;
        }
      }

      final token = _reverseVocab![id] ?? '<unk>';
      tokens.add(token);
    }

    return tokens.join(' ');
  }

  /// Basic decoding fallback
  String _decodeBasic(List<int> tokenIds) {
    return String.fromCharCodes(tokenIds.map((id) => id - 100));
  }

  /// Build a chat prompt using Phi-3 format
  String buildChatPrompt({
    String? systemMessage,
    required String userMessage,
    List<String>? conversationHistory,
  }) {
    final buffer = StringBuffer();

    // Add system message if provided
    if (systemMessage != null && systemMessage.isNotEmpty) {
      buffer.write(systemStartToken);
      buffer.write('\n$systemMessage\n');
      buffer.write(systemEndToken);
      buffer.write('\n');
    }

    // Add conversation history if provided
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      for (var i = 0; i < conversationHistory.length; i += 2) {
        // User message
        if (i < conversationHistory.length) {
          buffer.write(userStartToken);
          buffer.write('\n${conversationHistory[i]}\n');
          buffer.write(userEndToken);
          buffer.write('\n');
        }

        // Assistant response
        if (i + 1 < conversationHistory.length) {
          buffer.write(assistantStartToken);
          buffer.write('\n${conversationHistory[i + 1]}\n');
          buffer.write(assistantEndToken);
          buffer.write('\n');
        }
      }
    }

    // Add current user message
    buffer.write(userStartToken);
    buffer.write('\n$userMessage\n');
    buffer.write(userEndToken);
    buffer.write('\n');

    // Add assistant start token (model will complete)
    buffer.write(assistantStartToken);
    buffer.write('\n');

    return buffer.toString();
  }

  /// Get the vocabulary size
  int get vocabSize => _vocab?.length ?? 0;
}
