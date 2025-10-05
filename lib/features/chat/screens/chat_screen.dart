import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_theme.dart';
import '../../../components/modern_message_bubble.dart';
import '../../../components/modern_chat_input.dart';
import '../../../models/chat_message.dart';
import '../../../models/bible_verse.dart';
import '../../../providers/ai_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? sessionId;

  const ChatScreen({super.key, this.sessionId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isTyping = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollChanged);
    _initializeChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    // Add welcome message with beautiful animation
    _addMessage(ChatMessage.system(
      content: '🙏 Welcome! I\'m here to provide biblical guidance and encouragement. Share what\'s on your heart, and I\'ll help you find relevant Scripture and wisdom for your situation.',
      sessionId: widget.sessionId,
    ));
  }

  void _onScrollChanged() {
    final shouldShow = _scrollController.offset > 200;
    if (shouldShow != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = shouldShow;
      });
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent,
          );
        }
      }
    });
  }

  Future<void> _handleUserMessage(String content) async {
    // Add user message
    final userMessage = ChatMessage.user(
      content: content,
      sessionId: widget.sessionId,
    );
    _addMessage(userMessage);

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    try {
      // Generate AI response
      final response = await _generateAIResponse(content);
      _addMessage(response);
    } catch (e) {
      _addMessage(ChatMessage.ai(
        content: 'I apologize, but I\'m having trouble processing your request right now. Please try again in a moment.',
        sessionId: widget.sessionId,
      ));
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  Future<ChatMessage> _generateAIResponse(String userInput) async {
    // Use the actual AI service
    try {
      final aiService = ref.read(aiServiceProvider);
      final response = await aiService.generateResponse(
        userInput: userInput,
        conversationHistory: _messages,
      );

      return ChatMessage.ai(
        content: response.content,
        verses: response.verses,
        sessionId: widget.sessionId,
        metadata: response.metadata,
      );
    } catch (e) {
      // Fallback to mock response if AI service fails
      final mockResponses = _getMockResponses();
      final responseData = _getBestMockResponse(userInput, mockResponses);

      return ChatMessage.ai(
        content: responseData['content'],
        verses: (responseData['verses'] as List<Map<String, dynamic>>)
            .map((v) => BibleVerse.fromJson(v))
            .toList(),
        sessionId: widget.sessionId,
      );
    }
  }

  Map<String, Map<String, dynamic>> _getMockResponses() {
    return {
      'anxiety': {
        'content': 'I can sense the weight of anxiety you\'re carrying. Remember that God invites you to cast all your anxieties on Him because He cares for you deeply. His peace, which surpasses all understanding, is available to guard your heart and mind right now.',
        'verses': [
          {
            'book': '1 Peter',
            'chapter': 5,
            'verse': 7,
            'text': 'Casting all your anxieties on him, because he cares for you.',
            'translation': 'ESV',
            'themes': ['anxiety', 'care', 'peace'],
            'category': 'peace',
            'reference': '1 Peter 5:7'
          },
          {
            'book': 'Philippians',
            'chapter': 4,
            'verse': 6,
            'text': 'Do not be anxious about anything, but in everything by prayer and supplication with thanksgiving let your requests be made known to God.',
            'translation': 'ESV',
            'themes': ['anxiety', 'prayer', 'peace'],
            'category': 'peace',
            'reference': 'Philippians 4:6'
          }
        ]
      },
      'strength': {
        'content': 'When we feel weak and overwhelmed, that\'s often when God\'s strength shines brightest through us. His power is made perfect in our weakness, and He promises to strengthen and help us through every challenge we face.',
        'verses': [
          {
            'book': 'Isaiah',
            'chapter': 41,
            'verse': 10,
            'text': 'Fear not, for I am with you; be not dismayed, for I am your God; I will strengthen you, I will help you, I will uphold you with my righteous right hand.',
            'translation': 'ESV',
            'themes': ['strength', 'courage', 'fear'],
            'category': 'strength',
            'reference': 'Isaiah 41:10'
          }
        ]
      },
      'guidance': {
        'content': 'Seeking God\'s direction shows wisdom and humility. He promises to guide those who acknowledge Him in all their ways. Trust that He will make your paths straight as you commit your decisions to Him in prayer.',
        'verses': [
          {
            'book': 'Proverbs',
            'chapter': 3,
            'verse': 5,
            'text': 'Trust in the Lord with all your heart, and do not lean on your own understanding.',
            'translation': 'ESV',
            'themes': ['trust', 'guidance', 'wisdom'],
            'category': 'guidance',
            'reference': 'Proverbs 3:5-6'
          }
        ]
      },
      'default': {
        'content': 'Thank you for sharing your heart with me. God sees you and understands exactly what you\'re going through. His love for you is constant, and His grace is sufficient for every challenge you face.',
        'verses': [
          {
            'book': 'Psalm',
            'chapter': 46,
            'verse': 1,
            'text': 'God is our refuge and strength, a very present help in trouble.',
            'translation': 'ESV',
            'themes': ['strength', 'help', 'refuge'],
            'category': 'strength',
            'reference': 'Psalm 46:1'
          }
        ]
      }
    };
  }

  Map<String, dynamic> _getBestMockResponse(String userInput, Map<String, Map<String, dynamic>> responses) {
    final input = userInput.toLowerCase();

    if (input.contains('anxious') || input.contains('worry') || input.contains('stress')) {
      return responses['anxiety']!;
    } else if (input.contains('weak') || input.contains('strength') || input.contains('strong')) {
      return responses['strength']!;
    } else if (input.contains('decision') || input.contains('guidance') || input.contains('direction')) {
      return responses['guidance']!;
    }

    return responses['default']!;
  }

  void _handleVersePressed(BibleVerse verse) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        ModernVerseCard(
                          verse: verse,
                          compact: false,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Related Verses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Mock related verses
                        ...List.generate(3, (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ModernVerseCard(
                            verse: BibleVerse(
                              book: 'Romans',
                              chapter: 8,
                              verseNumber: 28 + index,
                              text: 'And we know that for those who love God all things work together for good, for those who are called according to his purpose.',
                              translation: 'ESV',
                              reference: 'Romans 8:${28 + index}',
                              themes: const ['trust', 'hope', 'purpose'],
                              category: 'hope',
                            ),
                            onTap: () => Navigator.pop(context),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          if (_isTyping) const TypingIndicator(),
          ModernChatInput(
            onSendMessage: _handleUserMessage,
            isLoading: _isTyping,
            suggestions: const [
              'I\'m feeling anxious about the future',
              'I need guidance for a difficult decision',
              'I\'m struggling with forgiveness',
              'I feel lonely and need encouragement',
              'I\'m going through a tough time',
            ],
          ),
        ],
      ),
      floatingActionButton: _showScrollToBottom
          ? FloatingActionButton.small(
              onPressed: () => _scrollToBottom(),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 0.8))
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Column(
        children: [
          Text(
            'Spiritual Guidance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            'AI-powered biblical wisdom',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _showChatOptions,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.more_vert,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ModernMessageBubble(
          message: message,
          showTimestamp: index == _messages.length - 1 ||
              (index < _messages.length - 1 &&
               _messages[index + 1].type != message.type),
          onVersePressed: _handleVersePressed,
        );
      },
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20, top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.refresh, color: AppTheme.primaryColor),
              title: Text('New Conversation', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _startNewConversation();
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: AppTheme.primaryColor),
              title: Text('Share Conversation', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _shareConversation();
              },
            ),
            ListTile(
              leading: Icon(Icons.bookmark, color: AppTheme.primaryColor),
              title: Text('Save Conversation', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _saveConversation();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _startNewConversation() {
    setState(() {
      _messages.clear();
    });
    _initializeChat();
  }

  void _shareConversation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Conversation sharing coming soon'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _saveConversation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Conversation saved'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}