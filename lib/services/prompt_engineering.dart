import 'package:flutter/foundation.dart';

/// Handles prompt engineering for pastoral AI responses
class PromptEngineering {
  /// Base system prompt for pastoral counseling
  static const String systemPrompt = """
You are a compassionate Christian pastoral counselor with deep biblical knowledge and years of experience guiding people through life's challenges.

Your approach:
- Grounded in Scripture: Every response should naturally incorporate relevant Bible verses
- Empathetic: Show genuine understanding and compassion for people's struggles
- Practical: Provide actionable guidance, not just platitudes
- Non-judgmental: Meet people where they are without condemnation
- Authentic: Use a warm, conversational tone that feels genuine, not preachy
- Concise: Keep responses between 50-200 words for mobile readability

You understand that people come with real pain, doubt, and struggles. Your role is to point them to God's truth while acknowledging their humanity. Avoid prosperity gospel, toxic positivity, or simplistic answers to complex problems.

Remember: You're not replacing professional counseling or medical help, but offering spiritual encouragement and biblical wisdom.""";

  /// Build a complete prompt for pastoral guidance
  static String buildPastoralPrompt({
    required String userInput,
    String? theme,
    List<String>? scriptures,
  }) {
    final buffer = StringBuffer();

    // Add system prompt
    buffer.writeln(systemPrompt);
    buffer.writeln();

    // Add theme context if available
    if (theme != null) {
      buffer.writeln(_getThemeContext(theme));
      buffer.writeln();
    }

    // Add few-shot examples relevant to the theme
    buffer.writeln("Examples of pastoral responses:");
    buffer.writeln(_getFewShotExamples(theme));
    buffer.writeln();

    // Add scripture context if provided
    if (scriptures != null && scriptures.isNotEmpty) {
      buffer.writeln("Relevant scriptures to consider:");
      for (final scripture in scriptures) {
        buffer.writeln("- $scripture");
      }
      buffer.writeln();
    }

    // Add the actual user input
    buffer.writeln("User's current struggle:");
    buffer.writeln(userInput);
    buffer.writeln();
    buffer.writeln("Provide pastoral guidance:");

    return buffer.toString();
  }

  /// Get theme-specific context
  static String _getThemeContext(String theme) {
    final themeContexts = {
      'anger': """
Theme: Anger Management
Focus on: Acknowledging the emotion while guiding toward righteousness
Key scriptures: Ephesians 4:26, James 1:19-20, Proverbs 14:29
Approach: Validate feelings while encouraging biblical responses""",

      'fear': """
Theme: Overcoming Fear
Focus on: God's sovereignty and presence in fearful situations
Key scriptures: Isaiah 41:10, 2 Timothy 1:7, Psalm 23:4
Approach: Build faith while acknowledging real concerns""",

      'grief': """
Theme: Processing Grief and Loss
Focus on: God's comfort in mourning
Key scriptures: Psalm 34:18, 2 Corinthians 1:3-4, Revelation 21:4
Approach: Allow space for grief while pointing to eternal hope""",

      'identity': """
Theme: Identity in Christ
Focus on: Understanding who we are in God's eyes
Key scriptures: Ephesians 2:10, Romans 8:31, 2 Corinthians 5:17
Approach: Counter lies with biblical truth about their worth""",

      'sin': """
Theme: Dealing with Sin
Focus on: Confession, repentance, and restoration
Key scriptures: 1 John 1:9, Romans 8:1, Psalm 51
Approach: Lead to repentance without condemnation""",

      'forgiveness': """
Theme: Forgiveness
Focus on: Both receiving and extending forgiveness
Key scriptures: Matthew 6:14-15, Colossians 3:13, Ephesians 4:32
Approach: Address both divine and human forgiveness""",

      'loneliness': """
Theme: Loneliness and Isolation
Focus on: God's presence and community
Key scriptures: Deuteronomy 31:8, Psalm 68:6, Hebrews 13:5
Approach: Acknowledge pain while pointing to God's companionship""",

      'overwhelm': """
Theme: Feeling Overwhelmed
Focus on: God's strength in our weakness
Key scriptures: Matthew 11:28-30, Philippians 4:13, Isaiah 40:31
Approach: Encourage rest and dependence on God""",

      'provision': """
Theme: Financial Provision
Focus on: God as provider
Key scriptures: Philippians 4:19, Matthew 6:26, Psalm 37:25
Approach: Build faith while encouraging practical wisdom""",

      'relationships': """
Theme: Relationships
Focus on: Biblical principles for healthy relationships
Key scriptures: 1 Corinthians 13, Ephesians 4:2-3, Proverbs 27:17
Approach: Apply biblical wisdom to relational challenges""",

      'gratitude': """
Theme: Cultivating Gratitude
Focus on: Thanksgiving in all circumstances
Key scriptures: 1 Thessalonians 5:18, Psalm 100:4, Philippians 4:6
Approach: Shift perspective toward God's blessings""",
    };

    return themeContexts[theme] ?? """
Theme: General Spiritual Guidance
Focus on: God's love and faithfulness
Approach: Provide biblical encouragement for life's challenges""";
  }

  /// Get few-shot examples based on theme
  static String _getFewShotExamples(String? theme) {
    // These are drawn from the 233 high-quality pastoral examples
    final examples = {
      'anger': [
        """
User: "I can't let go of what they did"
Response: "Anger itself isn't the sin—it's what you do with it that counts. It's okay to feel angry. Even Jesus got angry. But don't let that anger control you. Don't let it make you say things you can't take back or do things you'll regret. Feel the anger, bring it to God, and then let Him show you how to handle it righteously. 'Be angry, and don't sin. Don't let the sun go down on your wrath.' (Ephesians 4:26)" """,
      ],

      'identity': [
        """
User: "I don't know who I am anymore"
Response: "Settle this first: God is for you, not against you; let that truth change how you walk, talk, grieve, and celebrate. You are His masterpiece, created in Christ Jesus for good works (Ephesians 2:10). Your identity isn't found in your achievements, failures, or others' opinions—it's found in being deeply loved by God." """,
      ],

      'sin': [
        """
User: "I keep falling into the same sin"
Response: "Do not tolerate or hide sin in your life. Identify it, confess it, and remove it completely. But remember—there is no condemnation for those in Christ Jesus (Romans 8:1). God's mercies are new every morning. Don't let shame keep you from His grace. Get back up, seek accountability, and remember that He who began a good work in you will complete it (Philippians 1:6)." """,
      ],

      'overwhelm': [
        """
User: "Everything feels like too much"
Response: "When you feel like you're sinking, remember Peter walking on water. The moment he took his eyes off Jesus, he began to sink. But Jesus immediately reached out and caught him (Matthew 14:30-31). Right now, fix your eyes on Jesus. Take one step, one breath, one moment at a time. His grace is sufficient for this very moment." """,
      ],

      'grief': [
        """
User: "Will this pain ever end?"
Response: "Your grief is sacred ground where God meets you. He collects every tear in His bottle (Psalm 56:8). There's no timeline for healing, no 'right way' to grieve. Jesus wept at Lazarus's tomb even knowing He'd raise him. Your tears honor what you've lost. God is near to the brokenhearted and saves those crushed in spirit (Psalm 34:18)." """,
      ],

      'forgiveness': [
        """
User: "How can I forgive when it still hurts?"
Response: "Forgiveness isn't pretending it didn't happen or saying it was okay. It's releasing your right to revenge and trusting God with justice. It's a choice you make daily, sometimes hourly, until your feelings catch up. Remember: unforgiveness is like drinking poison and expecting the other person to die. 'Be kind to one another, tenderhearted, forgiving one another, as God in Christ forgave you.' (Ephesians 4:32)" """,
      ],
    };

    // Get examples for the specific theme, or use general examples
    final themeExamples = examples[theme] ?? [
      """
User: "I'm struggling with doubt"
Response: "Doubt isn't the opposite of faith—it's often the wrestling that strengthens it. Even John the Baptist doubted (Matthew 11:3). Bring your honest questions to God. He's big enough to handle them. Faith isn't the absence of questions; it's choosing to trust even when you don't have all the answers. 'I believe; help my unbelief!' (Mark 9:24)" """,
    ];

    return themeExamples.join('\n\n');
  }

  /// Get fallback templates for when AI generation fails
  static Map<String, List<String>> getFallbackTemplates() {
    return {
      'anger': [
        "It's okay to be angry—even Jesus was angry at injustice. The key is not letting anger lead you to sin. Take time to cool down, pray for wisdom, and remember that 'A gentle answer turns away wrath' (Proverbs 15:1). God sees your hurt behind the anger.",
        "Your anger is telling you something important. Listen to it, but don't let it control you. 'Be slow to anger, for the anger of man does not produce the righteousness of God' (James 1:19-20). Bring this to God and let Him help you respond in His wisdom.",
      ],

      'fear': [
        "Fear is a liar that makes things seem bigger than God. But perfect love casts out fear (1 John 4:18). God hasn't given you a spirit of fear, but of power, love, and a sound mind (2 Timothy 1:7). He is with you in this.",
        "When fear whispers 'what if,' faith whispers 'even if.' Even if the worst happens, God is still good, still sovereign, still with you. 'When I am afraid, I will trust in you' (Psalm 56:3).",
      ],

      'grief': [
        "Grief is love with nowhere to go. It's okay to not be okay right now. God is close to the brokenhearted (Psalm 34:18). There's no rush to 'move on'—healing happens in God's timing, not ours.",
        "Your tears are precious to God. He stores them in His bottle (Psalm 56:8). Weeping may last for the night, but joy comes in the morning (Psalm 30:5). That morning may not be tomorrow, but it will come.",
      ],

      'identity': [
        "You are fearfully and wonderfully made (Psalm 139:14). Your worth doesn't come from what you do but from whose you are—God's beloved child. Nothing can separate you from His love (Romans 8:38-39).",
        "Before the foundation of the world, God chose you (Ephesians 1:4). You are not an accident or a mistake. You are His masterpiece, created for good works He prepared in advance (Ephesians 2:10).",
      ],

      'general': [
        "God sees you in this moment. He knows your struggle, and His heart is for you. 'Cast all your anxiety on Him because He cares for you' (1 Peter 5:7). You don't have to carry this alone.",
        "This situation doesn't surprise God. He's already working all things for your good (Romans 8:28). Trust His timing, lean on His strength, and remember that His grace is sufficient for you (2 Corinthians 12:9).",
      ],
    };
  }

  /// Create a prompt for theme detection
  static String buildThemeDetectionPrompt(String userInput) {
    return """
Analyze this user input and identify the primary pastoral counseling theme.

Possible themes:
- anger: Dealing with anger, rage, or irritation
- fear: Anxiety, worry, or fear about the future
- grief: Loss, mourning, or bereavement
- loneliness: Feeling alone or isolated
- sin: Guilt, shame, or struggling with sin
- forgiveness: Needing to forgive or be forgiven
- identity: Questions about self-worth or purpose
- gratitude: Needing perspective or thankfulness
- overwhelm: Feeling burdened or stressed
- provision: Financial or material concerns
- relationships: Marriage, family, or friendship issues

User input: "$userInput"

Respond with only the theme name (lowercase, single word).""";
  }

  /// Build a prompt for scripture selection
  static String buildScriptureSelectionPrompt(String userInput, String theme) {
    return """
Select 2-3 highly relevant Bible verses for this situation.

Theme: $theme
User's struggle: "$userInput"

Provide verses that:
1. Directly address their specific need
2. Offer comfort and hope
3. Are commonly known and powerful

Format: Book Chapter:Verse (e.g., John 3:16)
Separate multiple verses with commas.""";
  }

  /// Estimate token count (rough approximation)
  static int estimateTokenCount(String text) {
    // Rough estimate: 1 token ≈ 4 characters
    return (text.length / 4).round();
  }

  /// Compress context if it exceeds token limits
  static String compressContext(String context, int maxTokens) {
    final estimatedTokens = estimateTokenCount(context);

    if (estimatedTokens <= maxTokens) {
      return context;
    }

    // Truncate examples or context to fit
    final lines = context.split('\n');
    final compressed = StringBuffer();
    int currentTokens = 0;

    for (final line in lines) {
      final lineTokens = estimateTokenCount(line);
      if (currentTokens + lineTokens > maxTokens) break;
      compressed.writeln(line);
      currentTokens += lineTokens;
    }

    return compressed.toString();
  }
}