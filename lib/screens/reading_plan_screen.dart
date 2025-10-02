import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_button.dart';
import '../components/category_badge.dart';
import '../theme/app_theme.dart';

class ReadingPlanScreen extends StatefulWidget {
  const ReadingPlanScreen({super.key});

  @override
  State<ReadingPlanScreen> createState() => _ReadingPlanScreenState();
}

class _ReadingPlanScreenState extends State<ReadingPlanScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  ReadingPlan? _currentPlan;

  final List<ReadingPlan> _availablePlans = [
    ReadingPlan(
      id: '1',
      title: 'Bible in a Year',
      description: 'Read the entire Bible in 365 days with daily readings',
      duration: '365 days',
      category: 'Complete Bible',
      difficulty: 'Intermediate',
      estimatedTimePerDay: '15-20 minutes',
      totalReadings: 365,
      completedReadings: 45,
      isStarted: true,
    ),
    ReadingPlan(
      id: '2',
      title: 'New Testament in 90 Days',
      description: 'Journey through the New Testament in just 3 months',
      duration: '90 days',
      category: 'New Testament',
      difficulty: 'Beginner',
      estimatedTimePerDay: '10-15 minutes',
      totalReadings: 90,
      completedReadings: 0,
      isStarted: false,
    ),
    ReadingPlan(
      id: '3',
      title: 'Psalms & Proverbs',
      description: 'Daily wisdom from Psalms and Proverbs',
      duration: '31 days',
      category: 'Wisdom Literature',
      difficulty: 'Beginner',
      estimatedTimePerDay: '5-10 minutes',
      totalReadings: 31,
      completedReadings: 0,
      isStarted: false,
    ),
    ReadingPlan(
      id: '4',
      title: 'Gospels Deep Dive',
      description: 'In-depth study of Matthew, Mark, Luke, and John',
      duration: '120 days',
      category: 'Gospels',
      difficulty: 'Advanced',
      estimatedTimePerDay: '20-25 minutes',
      totalReadings: 120,
      completedReadings: 0,
      isStarted: false,
    ),
  ];

  final List<DailyReading> _todaysReadings = [
    DailyReading(
      id: '1',
      title: 'Genesis 1-3',
      description: 'The Beginning of All Things',
      book: 'Genesis',
      chapters: '1-3',
      estimatedTime: '8 minutes',
      isCompleted: true,
      date: DateTime.now(),
    ),
    DailyReading(
      id: '2',
      title: 'Matthew 1-2',
      description: 'The Birth of Jesus',
      book: 'Matthew',
      chapters: '1-2',
      estimatedTime: '6 minutes',
      isCompleted: false,
      date: DateTime.now(),
    ),
    DailyReading(
      id: '3',
      title: 'Psalm 1',
      description: 'Blessed is the One',
      book: 'Psalms',
      chapters: '1',
      estimatedTime: '2 minutes',
      isCompleted: false,
      date: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentPlan = _availablePlans.firstWhere((plan) => plan.isStarted);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTodayTab(),
                      _buildMyPlansTab(),
                      _buildExplorePlansTab(),
                    ],
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
                  'Reading Plans',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
                const SizedBox(height: 4),
                Text(
                  'Grow in God\'s word daily',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: FrostedGlassCard(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'My Plans'),
            Tab(text: 'Explore'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }

  Widget _buildTodayTab() {
    if (_currentPlan == null) {
      return _buildEmptyState(
        icon: Icons.book_outlined,
        title: 'No Active Reading Plan',
        subtitle: 'Start a reading plan to see today\'s readings here',
        action: () => _tabController.animateTo(2),
        actionText: 'Explore Plans',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentPlanCard(),
          const SizedBox(height: 24),
          const Text(
            'Today\'s Readings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
          const SizedBox(height: 16),
          ...List.generate(_todaysReadings.length, (index) {
            final reading = _todaysReadings[index];
            return _buildReadingCard(reading, index).animate()
                .fadeIn(duration: 600.ms, delay: (700 + index * 100).ms)
                .slideY(begin: 0.3);
          }),
        ],
      ),
    );
  }

  Widget _buildMyPlansTab() {
    final activePlans = _availablePlans.where((plan) => plan.isStarted).toList();

    if (activePlans.isEmpty) {
      return _buildEmptyState(
        icon: Icons.library_books_outlined,
        title: 'No Active Plans',
        subtitle: 'Start a reading plan to track your progress',
        action: () => _tabController.animateTo(2),
        actionText: 'Explore Plans',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: activePlans.length,
      itemBuilder: (context, index) {
        final plan = activePlans[index];
        return _buildPlanCard(plan, index, isActive: true).animate()
            .fadeIn(duration: 600.ms, delay: (600 + index * 100).ms)
            .slideY(begin: 0.3);
      },
    );
  }

  Widget _buildExplorePlansTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _availablePlans.length,
      itemBuilder: (context, index) {
        final plan = _availablePlans[index];
        return _buildPlanCard(plan, index, isActive: false).animate()
            .fadeIn(duration: 600.ms, delay: (600 + index * 100).ms)
            .slideY(begin: 0.3);
      },
    );
  }

  Widget _buildCurrentPlanCard() {
    if (_currentPlan == null) return const SizedBox();

    final progress = _currentPlan!.completedReadings / _currentPlan!.totalReadings;

    return FrostedGlassCard(
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
                      _currentPlan!.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentPlan!.category,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryColor.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CategoryBadge(
                text: _currentPlan!.difficulty,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                fontSize: 12,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                _currentPlan!.estimatedTimePerDay,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                _currentPlan!.duration,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${_currentPlan!.completedReadings} / ${_currentPlan!.totalReadings}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% complete',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 500.ms);
  }

  Widget _buildReadingCard(DailyReading reading, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FrostedGlassCard(
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: reading.isCompleted
                    ? Colors.green.withValues(alpha: 0.2)
                    : AppTheme.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: reading.isCompleted
                      ? Colors.green.withValues(alpha: 0.5)
                      : AppTheme.primaryColor.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                reading.isCompleted ? Icons.check_circle : Icons.book,
                color: reading.isCompleted ? Colors.green : AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reading.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reading.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reading.estimatedTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!reading.isCompleted)
              GestureDetector(
                onTap: () => _markReadingComplete(reading),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(ReadingPlan plan, int index, {required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FrostedGlassCard(
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
                        plan.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.category,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(plan.difficulty).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getDifficultyColor(plan.difficulty).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    plan.difficulty,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDifficultyColor(plan.difficulty),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              plan.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildPlanStat(Icons.schedule, plan.estimatedTimePerDay),
                const SizedBox(width: 16),
                _buildPlanStat(Icons.calendar_today, plan.duration),
              ],
            ),

            if (plan.isStarted) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${plan.completedReadings} / ${plan.totalReadings}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: plan.completedReadings / plan.totalReadings,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                borderRadius: BorderRadius.circular(4),
              ),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePlanAction(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.isStarted
                      ? Colors.transparent
                      : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  side: plan.isStarted
                      ? BorderSide(color: Colors.white.withValues(alpha: 0.3))
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  plan.isStarted ? 'Continue Reading' : 'Start Plan',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? action,
    String? actionText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClearGlassCard(
              padding: const EdgeInsets.all(24),
              child: Icon(
                icon,
                size: 48,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
            if (action != null && actionText != null) ...[
              const SizedBox(height: 24),
              GlassButton(
                text: actionText,
                onPressed: action,
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            ],
          ],
        ),
      ),
    );
  }

  void _markReadingComplete(DailyReading reading) {
    setState(() {
      reading.isCompleted = true;
      if (_currentPlan != null) {
        _currentPlan!.completedReadings++;
      }
    });
  }

  void _handlePlanAction(ReadingPlan plan) {
    if (plan.isStarted) {
      // Navigate to reading content or continue
      _tabController.animateTo(0);
    } else {
      // Start the plan
      setState(() {
        plan.isStarted = true;
        _currentPlan = plan;
      });
      _tabController.animateTo(0);
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class ReadingPlan {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String category;
  final String difficulty;
  final String estimatedTimePerDay;
  final int totalReadings;
  int completedReadings;
  bool isStarted;

  ReadingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.difficulty,
    required this.estimatedTimePerDay,
    required this.totalReadings,
    required this.completedReadings,
    required this.isStarted,
  });
}

class DailyReading {
  final String id;
  final String title;
  final String description;
  final String book;
  final String chapters;
  final String estimatedTime;
  bool isCompleted;
  final DateTime date;

  DailyReading({
    required this.id,
    required this.title,
    required this.description,
    required this.book,
    required this.chapters,
    required this.estimatedTime,
    required this.isCompleted,
    required this.date,
  });
}