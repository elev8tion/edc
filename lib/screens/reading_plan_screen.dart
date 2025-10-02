import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_button.dart';
import '../components/category_badge.dart';
import '../theme/app_theme.dart';
import '../core/providers/app_providers.dart';
import '../core/models/reading_plan.dart';

class ReadingPlanScreen extends ConsumerStatefulWidget {
  const ReadingPlanScreen({super.key});

  @override
  ConsumerState<ReadingPlanScreen> createState() => _ReadingPlanScreenState();
}

class _ReadingPlanScreenState extends ConsumerState<ReadingPlanScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 1,
            ),
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
    final currentPlanAsync = ref.watch(currentReadingPlanProvider);

    return currentPlanAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (currentPlan) {
        if (currentPlan == null) {
          return _buildEmptyState(
            icon: Icons.book_outlined,
            title: 'No Active Reading Plan',
            subtitle: 'Start a reading plan to see today\'s readings here',
            action: () => _tabController.animateTo(2),
            actionText: 'Explore Plans',
          );
        }

        final todaysReadingsAsync =
            ref.watch(todaysReadingsProvider(currentPlan.id));

        return todaysReadingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error.toString()),
          data: (todaysReadings) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentPlanCard(currentPlan),
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
                  if (todaysReadings.isEmpty)
                    _buildEmptyReadingsMessage()
                  else
                    ...List.generate(todaysReadings.length, (index) {
                      final reading = todaysReadings[index];
                      return _buildReadingCard(reading, index)
                          .animate()
                          .fadeIn(duration: 600.ms, delay: (700 + index * 100).ms)
                          .slideY(begin: 0.3);
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyPlansTab() {
    final activePlansAsync = ref.watch(activeReadingPlansProvider);

    return activePlansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (activePlans) {
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
            return _buildPlanCard(plan, index, isActive: true)
                .animate()
                .fadeIn(duration: 600.ms, delay: (600 + index * 100).ms)
                .slideY(begin: 0.3);
          },
        );
      },
    );
  }

  Widget _buildExplorePlansTab() {
    final allPlansAsync = ref.watch(allReadingPlansProvider);

    return allPlansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (allPlans) {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: allPlans.length,
          itemBuilder: (context, index) {
            final plan = allPlans[index];
            return _buildPlanCard(plan, index, isActive: false)
                .animate()
                .fadeIn(duration: 600.ms, delay: (600 + index * 100).ms)
                .slideY(begin: 0.3);
          },
        );
      },
    );
  }

  Widget _buildCurrentPlanCard(ReadingPlan plan) {
    final progressAsync = ref.watch(planProgressPercentageProvider(plan.id));
    final currentDayAsync = ref.watch(planCurrentDayProvider(plan.id));
    final streakAsync = ref.watch(planStreakProvider(plan.id));

    final progress = (plan.completedReadings / plan.totalReadings).clamp(0.0, 1.0);

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
                      plan.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.category.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CategoryBadge(
                text: plan.difficulty.displayName,
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
                plan.estimatedTimePerDay,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 16),
              currentDayAsync.when(
                data: (day) => Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Day $day',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              const Spacer(),
              streakAsync.when(
                data: (streak) => streak > 0
                    ? Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.orange.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$streak day${streak > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
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
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          progressAsync.when(
            data: (percentage) => Text(
              '${percentage.toStringAsFixed(1)}% complete',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
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
            GestureDetector(
              onTap: () => _toggleReadingComplete(reading),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: reading.isCompleted
                      ? Colors.green.withValues(alpha: 0.2)
                      : AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  reading.isCompleted ? Icons.check : Icons.circle_outlined,
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
    final progressPercentageAsync = plan.isStarted
        ? ref.watch(planProgressPercentageProvider(plan.id))
        : null;

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
                        plan.category.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                CategoryBadge(
                  text: plan.difficulty.displayName,
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
                value: (plan.completedReadings / plan.totalReadings).clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                borderRadius: BorderRadius.circular(4),
              ),
              if (progressPercentageAsync != null) ...[
                const SizedBox(height: 8),
                progressPercentageAsync.when(
                  data: (percentage) => Text(
                    '${percentage.toStringAsFixed(1)}% complete',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    text: plan.isStarted ? 'Continue Reading' : 'Start Plan',
                    height: 48,
                    onPressed: () => _handlePlanAction(plan),
                  ),
                ),
                if (plan.isStarted) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showResetConfirmation(plan),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.restart_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ],
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReadingsMessage() {
    return FrostedGlassCard(
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: 48,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No readings scheduled for today',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleReadingComplete(DailyReading reading) async {
    final progressService = ref.read(readingPlanProgressServiceProvider);

    try {
      if (reading.isCompleted) {
        await progressService.markDayIncomplete(reading.id);
      } else {
        await progressService.markDayComplete(reading.id);
      }

      // Refresh providers
      ref.invalidate(currentReadingPlanProvider);
      ref.invalidate(todaysReadingsProvider(reading.planId));
      ref.invalidate(planProgressPercentageProvider(reading.planId));
      ref.invalidate(planStreakProvider(reading.planId));
      ref.invalidate(activeReadingPlansProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reading.isCompleted
                  ? 'Marked as incomplete'
                  : 'Great job! Keep up the good work!',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: reading.isCompleted
                ? Colors.orange
                : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePlanAction(ReadingPlan plan) async {
    if (plan.isStarted) {
      // Navigate to today's tab
      _tabController.animateTo(0);
    } else {
      // Start the plan
      final planService = ref.read(readingPlanServiceProvider);
      final progressService = ref.read(readingPlanProgressServiceProvider);

      try {
        await planService.startPlan(plan.id);

        // Check if readings exist, if not create sample ones
        final readings = await progressService.getTodaysReadings(plan.id);
        if (readings.isEmpty) {
          await progressService.createSampleReadings(
            plan.id,
            plan.totalReadings,
          );
        }

        // Refresh providers
        ref.invalidate(currentReadingPlanProvider);
        ref.invalidate(activeReadingPlansProvider);
        ref.invalidate(allReadingPlansProvider);

        // Navigate to today's tab
        _tabController.animateTo(0);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reading plan started! Let\'s begin your journey.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error starting plan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showResetConfirmation(ReadingPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Reading Plan?'),
        content: Text(
          'Are you sure you want to reset "${plan.title}"? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final progressService = ref.read(readingPlanProgressServiceProvider);

      try {
        await progressService.resetPlan(plan.id);

        // Refresh all providers
        ref.invalidate(currentReadingPlanProvider);
        ref.invalidate(activeReadingPlansProvider);
        ref.invalidate(allReadingPlansProvider);
        ref.invalidate(planProgressPercentageProvider(plan.id));
        ref.invalidate(planStreakProvider(plan.id));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reading plan has been reset'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error resetting plan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
