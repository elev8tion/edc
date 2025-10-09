import 'dart:math';
import 'package:flutter/foundation.dart';

/// Template-based guidance service that requires NO AI model
/// Uses your 233 training examples as templates for responses
class TemplateGuidanceService {
  static TemplateGuidanceService? _instance;

  static TemplateGuidanceService get instance {
    _instance ??= TemplateGuidanceService._internal();
    return _instance!;
  }

  TemplateGuidanceService._internal();

  /// Response templates based on your 233 training examples
  static const Map<String, List<ResponseTemplate>> templates = {
    'anxiety': [
      ResponseTemplate(
        intro: 'I can sense the weight of worry you\'re carrying about {concern}. Let me share what God says about our anxious thoughts.',
        verses: [
          'Cast all your anxiety on him because he cares for you. - 1 Peter 5:7',
          'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. - Philippians 4:6',
        ],
        application: 'Take a moment right now to name your specific worries to God. He\'s not overwhelmed by them - He\'s already working on your behalf.',
        closing: 'Remember, the God who holds the universe holds your situation too. You are not alone in this.',
      ),
      ResponseTemplate(
        intro: 'Your concerns about {concern} are valid, and God understands the anxiety you\'re experiencing.',
        verses: [
          'When anxiety was great within me, your consolation brought me joy. - Psalm 94:19',
          'Peace I leave with you; my peace I give you. I do not give to you as the world gives. Do not let your hearts be troubled and do not be afraid. - John 14:27',
        ],
        application: 'Consider writing down your worries and literally handing that paper to God in prayer. Sometimes physical acts help us release mental burdens.',
        closing: 'May His perfect peace guard your heart and mind today.',
      ),
    ],
    'depression': [
      ResponseTemplate(
        intro: 'The darkness you\'re experiencing with {concern} is real, and God sees you in this valley.',
        verses: [
          'The Lord is close to the brokenhearted and saves those who are crushed in spirit. - Psalm 34:18',
          'He heals the brokenhearted and binds up their wounds. - Psalm 147:3',
        ],
        application: 'Even if you can\'t feel His presence right now, know that God is especially near to those who hurt. You don\'t need to pretend to be okay.',
        closing: 'Hold on, dear one. Dawn is coming, even if you can\'t see it yet.',
      ),
    ],
    'fear': [
      ResponseTemplate(
        intro: 'Fear about {concern} can be paralyzing, but God offers us a different spirit.',
        verses: [
          'For God has not given us a spirit of fear, but of power and of love and of a sound mind. - 2 Timothy 1:7',
          'When I am afraid, I put my trust in you. - Psalm 56:3',
        ],
        application: 'Name your fear out loud to God. Speaking it can often reduce its power over you.',
        closing: 'The One who is in you is greater than whatever you\'re facing.',
      ),
    ],
    'guidance': [
      ResponseTemplate(
        intro: 'Seeking direction about {concern} shows wisdom. Let\'s see what God\'s Word says about finding our way.',
        verses: [
          'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight. - Proverbs 3:5-6',
          'Your word is a lamp for my feet, a light on my path. - Psalm 119:105',
        ],
        application: 'Sometimes God\'s guidance comes through open doors, closed doors, wise counsel, or inner peace. Stay alert to all the ways He might be leading you.',
        closing: 'Trust the process. God is directing your steps even when the path isn\'t clear.',
      ),
    ],
    'general': [
      ResponseTemplate(
        intro: 'Thank you for sharing about {concern}. God\'s Word has something to say about every situation we face.',
        verses: [
          'For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, plans to give you hope and a future. - Jeremiah 29:11',
          'And we know that in all things God works for the good of those who love him, who have been called according to his purpose. - Romans 8:28',
        ],
        application: 'Whatever you\'re facing, remember that God is working behind the scenes in ways you cannot yet see.',
        closing: 'You are loved, you are seen, and you are never alone.',
      ),
    ],
  };

  /// Extract the main concern from user input
  String extractConcern(String input) {
    // Simple extraction - takes the main topic after common phrases
    final patterns = [
      RegExp(r'about (.+?)(?:\.|$)', caseSensitive: false),
      RegExp(r'with (.+?)(?:\.|$)', caseSensitive: false),
      RegExp(r'regarding (.+?)(?:\.|$)', caseSensitive: false),
      RegExp(r'because (.+?)(?:\.|$)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.toLowerCase().trim();
      }
    }

    // Fallback: use a generic phrase
    if (input.length > 20) {
      return 'what you\'re going through';
    }
    return 'this situation';
  }

  /// Generate a complete response using templates only (NO AI NEEDED!)
  Future<String> generateTemplateResponse({
    required String userInput,
    required String theme,
    dynamic understanding, // UserUnderstanding object from AI service
    List<String>? additionalVerses,
  }) async {
    // Get templates for theme (can be refined based on emotional understanding)
    final themeTemplates = templates[theme] ?? templates['general'] ?? [];
    if (themeTemplates.isEmpty) {
      return _getFallbackResponse();
    }

    // Select a template (could be smarter based on understanding)
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    final template = themeTemplates[random.nextInt(themeTemplates.length)];

    // Use understanding if available, otherwise extract from input
    String concern;
    if (understanding != null && understanding.cleanedInput != null) {
      // Use the AI's understanding of what the user is really saying
      concern = understanding.cleanedInput;
    } else {
      // Fallback to simple extraction
      concern = extractConcern(userInput);
    }

    // Build the response
    final buffer = StringBuffer();

    // Add intro with concern
    buffer.writeln(template.intro.replaceAll('{concern}', concern));
    buffer.writeln();

    // Add emotional acknowledgment if we have understanding
    if (understanding != null && understanding.emotionalTone != null) {
      final emotionalAck = _getEmotionalAcknowledgment(understanding.emotionalTone);
      if (emotionalAck.isNotEmpty) {
        buffer.writeln(emotionalAck);
        buffer.writeln();
      }
    }

    // Add verses with appropriate transition
    final transition = (understanding != null && understanding.emotionalTone == 'desperate')
        ? 'God has urgent words for you right now:'
        : (understanding != null && understanding.emotionalTone == 'angry')
            ? 'God can handle your anger. Here\'s what He says:'
            : 'The Bible offers us these words:';
    buffer.writeln(transition);
    buffer.writeln();
    for (final verse in template.verses) {
      buffer.writeln('"$verse"');
      buffer.writeln();
    }

    // Add additional verses if provided
    if (additionalVerses != null && additionalVerses.isNotEmpty) {
      buffer.writeln('Also consider:');
      for (final verse in additionalVerses) {
        buffer.writeln('• $verse');
      }
      buffer.writeln();
    }

    // Add application
    buffer.writeln(template.application);
    buffer.writeln();

    // Add closing
    buffer.writeln(template.closing);

    return buffer.toString();
  }

  /// Generate response with slight variations for naturalness
  Future<String> generateVariedResponse({
    required String userInput,
    required String theme,
  }) async {
    final response = await generateTemplateResponse(
      userInput: userInput,
      theme: theme,
    );

    // Add slight variations to make it feel more natural
    final variations = [
      (String s) => s.replaceAll('God says', 'the Lord says'),
      (String s) => s.replaceAll('Let me share', 'I\'d like to share'),
      (String s) => s.replaceAll('Consider', 'You might consider'),
      (String s) => s.replaceAll('Remember,', 'Please remember,'),
      (String s) => s.replaceAll('Take a moment', 'Perhaps take a moment'),
    ];

    // Apply 1-2 random variations
    String varied = response;
    final random = Random();
    final numVariations = random.nextInt(2) + 1;

    for (int i = 0; i < numVariations; i++) {
      if (variations.isNotEmpty) {
        final variation = variations[random.nextInt(variations.length)];
        varied = variation(varied);
      }
    }

    return varied;
  }

  /// Get emotional acknowledgment based on understanding
  String _getEmotionalAcknowledgment(String emotionalTone) {
    final acknowledgments = {
      'anxious': 'I can feel the anxiety in your words. That weight is real.',
      'sad': 'Your sadness is valid, and it\'s okay to not be okay right now.',
      'angry': 'Your anger is understandable. God isn\'t afraid of your honest emotions.',
      'confused': 'Feeling lost and uncertain is part of being human.',
      'desperate': 'I hear the urgency in your heart. You\'re not alone in this moment.',
      'hopeful': 'I sense hope in your words, even amidst the challenges.',
    };

    return acknowledgments[emotionalTone] ?? '';
  }

  /// Get a simple fallback response
  String _getFallbackResponse() {
    return '''
Thank you for sharing your heart with me. While I process your specific situation,
please know that God sees you and cares deeply about what you're going through.

"Come to me, all you who are weary and burdened, and I will give you rest." - Matthew 11:28

Take a moment to breathe deeply and rest in His presence. You are not alone.

May God's peace be with you today.
''';
  }

  /// Check if response quality is sufficient without AI
  bool isQualitySufficient(String response) {
    // Check if response has all key components
    final hasIntro = response.length > 50;
    final hasVerses = response.contains('" -') || response.contains(':" ');
    final hasApplication = response.split('\n').length > 5;

    return hasIntro && hasVerses && hasApplication;
  }
}

/// Template structure for responses
class ResponseTemplate {
  final String intro;
  final List<String> verses;
  final String application;
  final String closing;

  const ResponseTemplate({
    required this.intro,
    required this.verses,
    required this.application,
    required this.closing,
  });
}