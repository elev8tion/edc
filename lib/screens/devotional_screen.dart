import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_button.dart';
import '../components/category_badge.dart';
import '../theme/app_theme.dart';

class DevotionalScreen extends StatefulWidget {
  const DevotionalScreen({super.key});

  @override
  State<DevotionalScreen> createState() => _DevotionalScreenState();
}

class _DevotionalScreenState extends State<DevotionalScreen> {
  int _currentDay = 0;
  bool _isCompleted = false;

  final List<Devotional> _devotionals = [
    Devotional(
      id: '1',
      title: 'Walking in Faith',
      subtitle: 'Trust in God\'s Plan',
      date: DateTime.now(),
      readingTime: '5 min read',
      verse: 'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
      verseReference: 'Proverbs 3:5-6',
      content: '''
Today, let's reflect on what it means to truly trust in the Lord with all our hearts. In a world filled with uncertainty and rapid changes, it's natural to want to rely on our own understanding and wisdom. However, God calls us to something deeper – complete dependence on Him.

When we trust in the Lord with ALL our heart, we're not just giving Him part of our concerns or problems. We're surrendering our entire being – our fears, hopes, dreams, and struggles – into His capable hands.

The second part of this verse is equally important: "lean not on your own understanding." This doesn't mean we should abandon wisdom or critical thinking, but rather that we should recognize the limitations of human perspective. Our view is finite; God's is infinite.

**Reflection Questions:**
• What areas of your life are you struggling to surrender to God?
• How can you practice trusting God more in your daily decisions?
• When have you seen God make your "paths straight" in the past?

**Prayer:**
Lord, help me to trust You completely. When I'm tempted to lean on my own understanding, remind me of Your faithfulness. Guide my steps today and help me to walk in faith, knowing that Your plans for me are good. Amen.
''',
      isCompleted: false,
    ),
    Devotional(
      id: '2',
      title: 'The Power of Gratitude',
      subtitle: 'Cultivating a Thankful Heart',
      date: DateTime.now().add(const Duration(days: 1)),
      readingTime: '4 min read',
      verse: 'Give thanks in all circumstances; for this is God\'s will for you in Christ Jesus.',
      verseReference: '1 Thessalonians 5:18',
      content: '''
Gratitude has the power to transform our perspective and our hearts. When Paul wrote to the Thessalonians about giving thanks "in all circumstances," he wasn't suggesting that we be thankful for every situation we face. Rather, he was encouraging us to find reasons to be grateful even in the midst of difficulties.

Gratitude is not about denying pain or pretending that hard things aren't hard. It's about choosing to see God's goodness and faithfulness even when life is challenging. It's about remembering His past mercies while walking through present trials.

When we cultivate a heart of gratitude, several things happen:
- Our focus shifts from what we lack to what we have
- We become more aware of God's daily provisions
- Our relationship with God deepens
- We experience greater peace and contentment

**Reflection Questions:**
• What are three things you can thank God for today?
• How has gratitude changed your perspective in difficult times?
• What daily practices help you maintain a grateful heart?

**Prayer:**
Father, thank You for Your countless blessings. Help me to develop eyes that see Your goodness in every day. Even in difficult circumstances, may I remember Your faithfulness and respond with thanksgiving. Amen.
''',
      isCompleted: false,
    ),
    Devotional(
      id: '3',
      title: 'Living with Purpose',
      subtitle: 'God\'s Calling on Your Life',
      date: DateTime.now().add(const Duration(days: 2)),
      readingTime: '6 min read',
      verse: 'For we are God\'s handiwork, created in Christ Jesus to do good works, which God prepared in advance for us to do.',
      verseReference: 'Ephesians 2:10',
      content: '''
You are not an accident. You are not a mistake. You are God's handiwork – His masterpiece, created with intention and purpose. Today's verse reminds us that before you were even born, God had already prepared good works for you to accomplish.

This truth should bring both comfort and motivation. Comfort, because it means your life has meaning and significance in God's grand design. Motivation, because it calls us to actively seek and embrace the purposes God has for us.

Living with purpose doesn't necessarily mean having a dramatic calling or being in full-time ministry. God's purposes for you might include:
- Being a loving parent or spouse
- Showing kindness to coworkers
- Using your talents to serve others
- Being a light in your community

The key is being available and willing to be used by God in whatever way He sees fit.

**Reflection Questions:**
• What unique gifts and talents has God given you?
• How might God want to use you in your current circumstances?
• What "good works" is God calling you to embrace today?

**Prayer:**
Lord, thank You for creating me with purpose. Help me to discover and embrace the good works You have prepared for me. Give me wisdom to see opportunities to serve and the courage to step into them. May my life bring glory to You. Amen.
''',
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentDevotional = _devotionals[_currentDay];

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildDevotionalCard(currentDevotional),
                        const SizedBox(height: 20),
                        _buildNavigationButtons(),
                        const SizedBox(height: 20),
                        _buildProgressIndicator(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClearGlassCard(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Devotional',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
                const SizedBox(height: 4),
                Text(
                  'Grow closer to God each day',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
              ],
            ),
          ),
          ClearGlassCard(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Day ${_currentDay + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildDevotionalCard(Devotional devotional) {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      devotional.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      devotional.subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CategoryBadge(
                text: devotional.readingTime,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                fontSize: 12,
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Today\'s Verse',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '"${devotional.verse}"',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  devotional.verseReference,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Reflection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            devotional.content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 24),

          if (!devotional.isCompleted)
            GlassButton(
              text: 'Mark as Completed',
              onPressed: () {
                setState(() {
                  devotional.isCompleted = true;
                  _isCompleted = true;
                });
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Devotional Completed',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3);
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: _currentDay > 0
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentDay--;
                    });
                  },
                  child: ClearGlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Previous Day',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ),
        if (_currentDay > 0 && _currentDay < _devotionals.length - 1)
          const SizedBox(width: 16),
        Expanded(
          child: _currentDay < _devotionals.length - 1
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentDay++;
                    });
                  },
                  child: ClearGlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Next Day',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms);
  }

  Widget _buildProgressIndicator() {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '${_currentDay + 1} of ${_devotionals.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_currentDay + 1) / _devotionals.length,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_devotionals.length, (index) {
              final isCompleted = _devotionals[index].isCompleted;
              final isCurrent = index == _currentDay;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < _devotionals.length - 1 ? 8 : 0,
                  ),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.primaryColor.withValues(alpha: 0.3)
                          : isCompleted
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent
                            ? AppTheme.primaryColor
                            : isCompleted
                                ? Colors.green.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 20,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent
                                    ? AppTheme.primaryColor
                                    : Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms);
  }
}

class Devotional {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final String readingTime;
  final String verse;
  final String verseReference;
  final String content;
  bool isCompleted;

  Devotional({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.readingTime,
    required this.verse,
    required this.verseReference,
    required this.content,
    required this.isCompleted,
  });
}