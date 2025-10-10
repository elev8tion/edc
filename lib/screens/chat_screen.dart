import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../core/navigation/navigation_service.dart';
import '../models/chat_message.dart';
import '../providers/ai_provider.dart';
import '../components/gradient_background.dart';
import '../components/base_bottom_sheet.dart';
import '../components/glass_effects/glass_dialog.dart';
import '../components/glass_card.dart';
import '../services/conversation_service.dart';

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});

  ChatMessage _createWelcomeMessage() {
    return ChatMessage.system(
      content: 'Peace be with you! 🙏\n\nI\'m here to provide biblical guidance and spiritual support. Feel free to ask me about:\n\n• Scripture interpretation\n• Prayer requests\n• Life challenges\n• Faith questions\n• Daily encouragement\n\nHow can I help you today?',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final messages = useState<List<ChatMessage>>([]);
    final isTyping = useState(false);
    final sessionId = useState<String?>(null);
    final conversationService = useMemoized(() => ConversationService());

    // Initialize session and load messages from database
    useEffect(() {
      Future<void> initializeSession() async {
        try {
          // Create new session
          final newSessionId = await conversationService.createSession(
            title: 'New Conversation',
          );
          sessionId.value = newSessionId;

          // Add welcome message with sessionId
          final welcomeMessage = ChatMessage.system(
            content: 'Peace be with you! 🙏\n\nI\'m here to provide biblical guidance and spiritual support. Feel free to ask me about:\n\n• Scripture interpretation\n• Prayer requests\n• Life challenges\n• Faith questions\n• Daily encouragement\n\nHow can I help you today?',
            sessionId: newSessionId,
          );
          await conversationService.saveMessage(welcomeMessage);

          // Load all messages from database
          final loadedMessages = await conversationService.getMessages(newSessionId);
          messages.value = loadedMessages;
        } catch (e) {
          debugPrint('Failed to initialize session: $e');
          // Fallback to in-memory
          messages.value = [_createWelcomeMessage()];
        }
      }

      initializeSession();
      return null;
    }, []);

    // Auto-scroll when messages change
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      return null;
    }, [messages.value]);

    void scrollToBottom() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    Future<void> sendMessage(String text) async {
      if (text.trim().isEmpty) return;

      final userMessage = ChatMessage.user(
        content: text.trim(),
        sessionId: sessionId.value,
      );

      messages.value = [...messages.value, userMessage];
      isTyping.value = true;
      messageController.clear();

      // Save user message to database
      if (sessionId.value != null) {
        await conversationService.saveMessage(userMessage);
      }

      scrollToBottom();

      try {
        // Use actual AI service
        final aiService = ref.read(aiServiceProvider);
        final response = await aiService.generateResponse(
          userInput: text.trim(),
          conversationHistory: messages.value,
        );

        final aiMessage = ChatMessage.ai(
          content: response.content,
          verses: response.verses,
          metadata: response.metadata,
          sessionId: sessionId.value,
        );

        isTyping.value = false;
        messages.value = [...messages.value, aiMessage];

        // Save AI message to database
        if (sessionId.value != null) {
          await conversationService.saveMessage(aiMessage);
        }

        scrollToBottom();
      } catch (e) {
        // Fallback to contextual response if AI service fails
        final response = _getContextualResponse(text.trim().toLowerCase());
        final aiMessage = ChatMessage.ai(
          content: response,
          sessionId: sessionId.value,
        );

        isTyping.value = false;
        messages.value = [...messages.value, aiMessage];

        // Save fallback AI message to database
        if (sessionId.value != null) {
          await conversationService.saveMessage(aiMessage);
        }

        scrollToBottom();
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, messages, sessionId, conversationService),
                Expanded(
                  child: _buildMessagesList(scrollController, messages.value, isTyping.value),
                ),
                _buildMessageInput(messageController, sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ValueNotifier<List<ChatMessage>> messages,
    ValueNotifier<String?> sessionId,
    ConversationService conversationService,
  ) {
    return Container(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          Container(
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
              onPressed: () => NavigationService.pop(),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biblical AI Guidance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Gemini AI',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
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
              icon: const Icon(Icons.history, color: Colors.white, size: 20),
              onPressed: () => _showConversationHistory(context, messages, sessionId, conversationService),
              tooltip: 'Conversation History',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.goldColor.withValues(alpha: 0.3),
                  AppTheme.goldColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.goldColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.primaryText, size: 20),
              onPressed: () => _startNewConversation(context, messages, sessionId, conversationService),
              tooltip: 'New Conversation',
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: -0.3);
  }

  Widget _buildMessagesList(ScrollController scrollController, List<ChatMessage> messages, bool isTyping) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isTyping) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(messages[index], index);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.3),
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primaryText,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Flexible(
            child: Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: message.isUser
                      ? [
                          AppTheme.primaryColor.withValues(alpha: 0.8),
                          AppTheme.primaryColor.withValues(alpha: 0.6),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(message.isUser ? 20 : 8),
                  topRight: Radius.circular(message.isUser ? 8 : 20),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primaryText,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.goldColor.withValues(alpha: 0.3),
                    AppTheme.goldColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.goldColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primaryText,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.normal, delay: (index * 100).ms).slideX(
          begin: message.isUser ? 0.3 : -0.3,
        );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.3),
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primaryText,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(200),
                const SizedBox(width: 4),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.tertiaryText,
        borderRadius: BorderRadius.circular(4),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).fadeIn(
          duration: AppAnimations.slow,
          delay: delay.ms,
        );
  }

  Widget _buildMessageInput(TextEditingController messageController, void Function(String) sendMessage) {
    return Container(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: messageController,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask for biblical guidance...',
                  hintStyle: TextStyle(
                    color: AppColors.tertiaryText,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: sendMessage,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => sendMessage(messageController.text),
              icon: const Icon(
                Icons.send,
                color: AppColors.primaryText,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast).slideY(begin: 0.3);
  }

  String _getContextualResponse(String message) {
    if (message.contains('prayer') || message.contains('pray')) {
      return 'Prayer is our direct line to God. As it says in Philippians 4:6-7: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus."\n\nWhat specific area would you like prayer for?';
    } else if (message.contains('fear') || message.contains('afraid') || message.contains('worry')) {
      return 'I understand you\'re feeling fearful. Remember what God says in Isaiah 41:10: "Fear not, for I am with you; be not dismayed, for I am your God; I will strengthen you, I will help you, I will uphold you with my righteous right hand."\n\nGod is always with you, even in your darkest moments. What is causing you to feel this way?';
    } else if (message.contains('love') || message.contains('relationship')) {
      return 'Love is at the heart of the Christian faith. 1 John 4:19 tells us "We love because he first loved us." God\'s love for us is unconditional and eternal.\n\nIn our relationships with others, we\'re called to love as Christ loved us - with patience, kindness, and forgiveness. How can I help you apply God\'s love in your situation?';
    } else if (message.contains('forgive') || message.contains('forgiveness')) {
      return 'Forgiveness is one of God\'s greatest gifts to us. As Jesus taught us in Matthew 6:14-15: "If you forgive other people when they sin against you, your heavenly Father will also forgive you."\n\nForgiveness doesn\'t mean forgetting or excusing wrong behavior, but it frees us from the burden of resentment. What situation are you struggling to forgive?';
    } else if (message.contains('purpose') || message.contains('calling')) {
      return 'God has a unique purpose for your life! Jeremiah 29:11 reminds us: "For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, to give you hope and a future."\n\nYour purpose is found in loving God and serving others. What gifts and passions has God given you that you could use to serve Him?';
    } else {
      return 'Thank you for sharing with me. God cares deeply about every aspect of your life, both big and small. As it says in 1 Peter 5:7: "Cast all your anxiety on him because he cares for you."\n\nRemember that you are loved, valued, and never alone. God is always listening and ready to help. Would you like to explore a specific Bible verse or topic related to your question?';
    }
  }

  void _showConversationHistory(
    BuildContext context,
    ValueNotifier<List<ChatMessage>> messages,
    ValueNotifier<String?> sessionId,
    ConversationService conversationService,
  ) async {
    final sessions = await conversationService.getSessions();

    if (!context.mounted) return;

    showCustomBottomSheet(
      context: context,
      title: 'Conversation History',
      height: MediaQuery.of(context).size.height * 0.75,
      child: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No conversation history yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: sessions.length > 20 ? 20 : sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final createdAt = DateTime.fromMillisecondsSinceEpoch(
                  session['created_at'] as int,
                );
                final messageCount = session['message_count'] as int? ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                    leading: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.goldColor.withValues(alpha: 0.3),
                            AppTheme.goldColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.goldColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.primaryText,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      session['title'] as String? ?? 'Conversation',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${_formatDate(createdAt)} • $messageCount messages',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.secondaryText,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _loadConversation(
                        session['id'] as String,
                        messages,
                        sessionId,
                        conversationService,
                      );
                    },
                  ),
                ).animate().fadeIn(duration: AppAnimations.fast).slideX(begin: 0.2);
              },
            ),
    );
  }

  void _startNewConversation(
    BuildContext context,
    ValueNotifier<List<ChatMessage>> messages,
    ValueNotifier<String?> sessionId,
    ConversationService conversationService,
  ) async {
    // Show confirmation dialog using your glass dialog component
    showGlassDialog(
      context: context,
      child: GlassContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Start New Conversation?',
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Current conversation will be saved. Start fresh?',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GlassDialogButton(
                  text: 'Cancel',
                  onTap: () => Navigator.pop(context),
                ),
                GlassDialogButton(
                  text: 'New Chat',
                  isPrimary: true,
                  onTap: () async {
                    Navigator.pop(context);
                    // Create new session
                    final newSessionId = await conversationService.createSession(
                      title: 'New Conversation',
                    );
                    sessionId.value = newSessionId;

                    // Reset messages with welcome message (with sessionId)
                    final welcomeMessage = ChatMessage.system(
                      content: 'Peace be with you! 🙏\n\nI\'m here to provide biblical guidance and spiritual support. Feel free to ask me about:\n\n• Scripture interpretation\n• Prayer requests\n• Life challenges\n• Faith questions\n• Daily encouragement\n\nHow can I help you today?',
                      sessionId: newSessionId,
                    );
                    await conversationService.saveMessage(welcomeMessage);
                    messages.value = [welcomeMessage];
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _loadConversation(
    String conversationSessionId,
    ValueNotifier<List<ChatMessage>> messages,
    ValueNotifier<String?> sessionId,
    ConversationService conversationService,
  ) async {
    try {
      // Load messages from database
      final loadedMessages = await conversationService.getMessages(conversationSessionId);

      // Update session ID
      sessionId.value = conversationSessionId;

      // Update messages list
      messages.value = loadedMessages;

      debugPrint('✅ Loaded conversation: $conversationSessionId with ${loadedMessages.length} messages');
    } catch (e) {
      debugPrint('❌ Failed to load conversation: $e');
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
