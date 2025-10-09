import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/bible_verse.dart';

/// Cloudflare Workers AI Service
///
/// Connects to Cloudflare's serverless GPU infrastructure to run LLM inference
/// Uses Llama 3.1 8B Instruct or Llama 4 Scout 17B models
///
/// Features:
/// - REST API based (works from any platform)
/// - Global GPU distribution (180+ cities)
/// - Free tier: 10,000 neurons/day (~1,300 responses)
/// - Optional AI Gateway for caching and analytics
class CloudflareAIService {
  final String accountId;
  final String apiToken;
  final String? gatewayName; // Optional: for AI Gateway features
  final bool useCache;
  final int cacheTTL; // Cache Time To Live in seconds

  // Available models
  static const String llama31_8b = '@cf/meta/llama-3.1-8b-instruct';
  static const String llama4_scout = '@cf/meta/llama-4-scout-17b-instruct';
  static const String mistral_7b = '@cf/mistral/mistral-7b-instruct-v0.1';

  static CloudflareAIService? _instance;

  CloudflareAIService._({
    required this.accountId,
    required this.apiToken,
    this.gatewayName,
    this.useCache = true,
    this.cacheTTL = 3600, // Default: 1 hour cache
  });

  /// Initialize the service with Cloudflare credentials
  static void initialize({
    required String accountId,
    required String apiToken,
    String? gatewayName,
    bool useCache = true,
    int cacheTTL = 3600,
  }) {
    _instance = CloudflareAIService._(
      accountId: accountId,
      apiToken: apiToken,
      gatewayName: gatewayName,
      useCache: useCache,
      cacheTTL: cacheTTL,
    );
    debugPrint('✅ Cloudflare AI Service initialized');
    debugPrint('   Account: $accountId');
    debugPrint('   Gateway: ${gatewayName ?? "None (direct API)"}');
    debugPrint('   Cache: ${useCache ? "Enabled (${cacheTTL}s TTL)" : "Disabled"}');
  }

  static CloudflareAIService get instance {
    if (_instance == null) {
      throw Exception(
        'CloudflareAIService not initialized. Call CloudflareAIService.initialize() first.'
      );
    }
    return _instance!;
  }

  /// Get the appropriate base URL (with or without AI Gateway)
  String _getBaseUrl() {
    if (gatewayName != null && gatewayName!.isNotEmpty) {
      // Use AI Gateway for caching, analytics, rate limiting
      return 'https://gateway.ai.cloudflare.com/v1/$accountId/$gatewayName/workers-ai';
    } else {
      // Direct Workers AI API
      return 'https://api.cloudflare.com/client/v4/accounts/$accountId/ai/run';
    }
  }

  /// Generate pastoral guidance using Cloudflare AI
  ///
  /// Parameters:
  /// - userInput: The user's message/question
  /// - systemPrompt: System prompt defining the AI's behavior
  /// - conversationHistory: Previous messages for context
  /// - verses: Bible verses to integrate into the response
  /// - model: Which Cloudflare AI model to use
  /// - maxTokens: Maximum response length (default: 300)
  Future<String> generatePastoralGuidance({
    required String userInput,
    required String systemPrompt,
    List<Map<String, String>> conversationHistory = const [],
    List<BibleVerse>? verses,
    String model = llama31_8b,
    int maxTokens = 300,
  }) async {
    try {
      final url = Uri.parse('${_getBaseUrl()}/$model');

      // Build messages array
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': systemPrompt},
      ];

      // Add conversation history
      messages.addAll(conversationHistory);

      // Add current user message with verses if provided
      String userContent = userInput;
      if (verses != null && verses.isNotEmpty) {
        final verseContext = verses
            .map((v) => '"${v.text}" - ${v.reference}')
            .join('\n');
        userContent = '$userInput\n\nRelevant Scripture:\n$verseContext';
      }
      messages.add({'role': 'user', 'content': userContent});

      // Prepare request headers
      final headers = {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      };

      // Add cache header if using AI Gateway
      if (useCache && gatewayName != null) {
        headers['cf-aig-cache-ttl'] = cacheTTL.toString();
      }

      // Make API request
      debugPrint('🤖 Calling Cloudflare AI: $model');
      debugPrint('   URL: $url');
      debugPrint('   Messages: ${messages.length}');

      final stopwatch = Stopwatch()..start();

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'messages': messages,
          'max_tokens': maxTokens,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out after 30 seconds');
        },
      );

      stopwatch.stop();
      debugPrint('   Response time: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('   Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if response was from cache
        final fromCache = response.headers['cf-cache-status'] == 'HIT';
        if (fromCache) {
          debugPrint('   ✨ Served from cache!');
        }

        // Extract response based on API structure
        String aiResponse;
        if (data['result'] != null) {
          if (data['result']['response'] != null) {
            aiResponse = data['result']['response'] as String;
          } else if (data['result']['content'] != null) {
            aiResponse = data['result']['content'] as String;
          } else {
            aiResponse = data['result'].toString();
          }
        } else {
          throw Exception('Unexpected response structure: ${data.keys}');
        }

        debugPrint('✅ AI response generated (${aiResponse.length} chars)');
        return aiResponse;

      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        final data = jsonDecode(response.body);
        throw Exception(
          'Rate limit exceeded. Free tier allows 10,000 neurons/day. ${data['errors']?[0]?['message'] ?? ""}'
        );

      } else {
        // Other errors
        final errorBody = response.body;
        debugPrint('❌ Cloudflare API error: $errorBody');
        throw Exception(
          'Cloudflare API error (${response.statusCode}): $errorBody'
        );
      }

    } on TimeoutException catch (e) {
      debugPrint('❌ Request timeout: $e');
      throw Exception('Request timed out. Please try again.');

    } on http.ClientException catch (e) {
      debugPrint('❌ Network error: $e');
      throw Exception('Network error. Please check your connection.');

    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      rethrow;
    }
  }

  /// Generate simple text completion (no chat format)
  Future<String> generateText({
    required String prompt,
    String model = llama31_8b,
    int maxTokens = 200,
  }) async {
    final url = Uri.parse('${_getBaseUrl()}/$model');

    final headers = {
      'Authorization': 'Bearer $apiToken',
      'Content-Type': 'application/json',
    };

    if (useCache && gatewayName != null) {
      headers['cf-aig-cache-ttl'] = cacheTTL.toString();
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'prompt': prompt,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result']['response'] as String;
    } else {
      throw Exception('Failed to generate text: ${response.body}');
    }
  }

  /// Health check - verify Cloudflare API is accessible
  Future<bool> healthCheck() async {
    try {
      // Simple test prompt
      await generateText(
        prompt: 'Say "OK"',
        maxTokens: 10,
      );
      debugPrint('✅ Cloudflare AI health check passed');
      return true;
    } catch (e) {
      debugPrint('❌ Cloudflare AI health check failed: $e');
      return false;
    }
  }

  /// Get estimated cost for neurons used
  /// Free tier: 10,000 neurons/day
  /// Paid: $0.011 per 1,000 neurons
  static double estimateCost(int neuronsUsed) {
    const int freeTierDaily = 10000;
    const double costPer1kNeurons = 0.011;

    if (neuronsUsed <= freeTierDaily) {
      return 0.0;
    }

    final billableNeurons = neuronsUsed - freeTierDaily;
    return (billableNeurons / 1000) * costPer1kNeurons;
  }

  /// Estimate neurons for LLM response
  /// Approximate: 1 response ≈ 7.7 neurons
  static int estimateNeuronsForResponse(int responseCount) {
    return (responseCount * 7.7).round();
  }

  void dispose() {
    debugPrint('🔌 Cloudflare AI Service disposed');
  }
}
