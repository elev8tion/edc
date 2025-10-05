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
import '../core/models/devotional.dart';
import '../core/navigation/navigation_service.dart';

class DevotionalScreen extends ConsumerStatefulWidget {
  const DevotionalScreen({super.key});

  @override
  ConsumerState<DevotionalScreen> createState() => _DevotionalScreenState();
}

class _DevotionalScreenState extends ConsumerState<DevotionalScreen> {
  int _currentDay = 0;

  @override
  Widget build(BuildContext context) {
    final devotionalsAsync = ref.watch(allDevotionalsProvider);
    final streakAsync = ref.watch(devotionalStreakProvider);
    final totalCompletedAsync = ref.watch(totalDevotionalsCompletedProvider);

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(streakAsync, totalCompletedAsync),
                Expanded(
                  child: devotionalsAsync.when(
                    data: (devotionals) {
                      if (devotionals.isEmpty) {
                        return _buildEmptyState();
                      }

                      // Ensure current day is within bounds
                      if (_currentDay >= devotionals.length) {
                        _currentDay = devotionals.length - 1;
                      }

                      final currentDevotional = devotionals[_currentDay];

                      return SingleChildScrollView(
                        padding: AppSpacing.horizontalXl,
                        child: Column(
                          children: [
                            _buildDevotionalCard(currentDevotional),
                            const SizedBox(height: AppSpacing.xl),
                            _buildNavigationButtons(devotionals.length),
                            const SizedBox(height: AppSpacing.xl),
                            _buildProgressIndicator(devotionals),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryText,
                      ),
                    ),
                    error: (error, stack) => _buildErrorState(error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    AsyncValue<int> streakAsync,
    AsyncValue<int> totalCompletedAsync,
  ) {
    return Padding(
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
                  'Daily Devotional',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ).animate().fadeIn(duration: AppAnimations.slow).slideX(begin: -0.3),
                const SizedBox(height: 4),
                Row(
                  children: [
                    streakAsync.when(
                      data: (streak) => Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: streak > 0 ? Colors.orange : Colors.white.withValues(alpha: 0.5),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$streak day streak',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    totalCompletedAsync.when(
                      data: (total) => Text(
                        '$total completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast),
              ],
            ),
          ),
          ClearGlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Day ${_currentDay + 1}',
              style: const TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.normal),
        ],
      ),
    );
  }

  Widget _buildDevotionalCard(Devotional devotional) {
    final progressService = ref.read(devotionalProgressServiceProvider);

    return FrostedGlassCard(
      padding: AppSpacing.screenPaddingLarge,
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
                        color: AppColors.primaryText,
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

          const SizedBox(height: AppSpacing.xxl),

          Container(
            padding: AppSpacing.screenPadding,
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
                    const SizedBox(width: AppSpacing.sm),
                    const Text(
                      'Today\'s Verse',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '"${devotional.verse}"',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryText,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  devotional.verseReference,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          const Text(
            'Reflection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            devotional.content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          if (!devotional.isCompleted)
            GlassButton(
              text: 'Mark as Completed',
              onPressed: () async {
                await progressService.markAsComplete(devotional.id);
                // Refresh the providers
                ref.invalidate(allDevotionalsProvider);
                ref.invalidate(devotionalStreakProvider);
                ref.invalidate(totalDevotionalsCompletedProvider);
                ref.invalidate(completedDevotionalsProvider);
              },
            )
          else
            Container(
              width: double.infinity,
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Devotional Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (devotional.completedDate != null)
                            Text(
                              _formatCompletedDate(devotional.completedDate!),
                              style: TextStyle(
                                color: Colors.green.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      await progressService.markAsIncomplete(devotional.id);
                      // Refresh the providers
                      ref.invalidate(allDevotionalsProvider);
                      ref.invalidate(devotionalStreakProvider);
                      ref.invalidate(totalDevotionalsCompletedProvider);
                      ref.invalidate(completedDevotionalsProvider);
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.green.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.slow).slideY(begin: 0.3);
  }

  Widget _buildNavigationButtons(int totalDevotionals) {
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
                          color: AppColors.primaryText,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Text(
                          'Previous Day',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ),
        if (_currentDay > 0 && _currentDay < totalDevotionals - 1)
          const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _currentDay < totalDevotionals - 1
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
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.primaryText,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ],
    ).animate().fadeIn(duration: AppAnimations.slow, delay: 800.ms);
  }

  Widget _buildProgressIndicator(List<Devotional> devotionals) {
    return FrostedGlassCard(
      padding: AppSpacing.screenPadding,
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
                  color: AppColors.primaryText,
                ),
              ),
              Text(
                '${_currentDay + 1} of ${devotionals.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: (_currentDay + 1) / devotionals.length,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(devotionals.length, (index) {
              final devotional = devotionals[index];
              final isCompleted = devotional.isCompleted;
              final isCurrent = index == _currentDay;

              return Container(
                width: (MediaQuery.of(context).size.width - 80) / 7 - 8,
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
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: 1000.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: FrostedGlassCard(
        padding: AppSpacing.screenPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories,
              color: Colors.white.withValues(alpha: 0.5),
              size: 64,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No Devotionals Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Check back later for daily devotionals',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: FrostedGlassCard(
        padding: AppSpacing.screenPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.withValues(alpha: 0.8),
              size: 64,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Error Loading Devotionals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCompletedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Completed today';
    } else if (dateDay == yesterday) {
      return 'Completed yesterday';
    } else {
      final difference = today.difference(dateDay).inDays;
      return 'Completed $difference days ago';
    }
  }
}
