import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/feature_card.dart';
import '../components/glass_button.dart';
import '../components/gradient_background.dart';
import '../components/category_badge.dart';
import '../core/navigation/app_routes.dart';
import '../core/providers/app_providers.dart';
import '../core/navigation/navigation_service.dart';
import '../utils/responsive_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late String greeting;
  late String userName;
  final GlobalKey _backgroundKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _setGreeting();
    userName = "Friend"; // In production, get from user preferences
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = "Rise and shine";
    } else if (hour < 17) {
      greeting = "Good afternoon";
    } else {
      greeting = "Good evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: _backgroundKey,
            child: const GradientBackground(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              // Optimize scrolling performance
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.xxl),
                _buildStatsRow(),
                const SizedBox(height: AppSpacing.xxl),
                _buildMainFeatures(),
                const SizedBox(height: AppSpacing.xxl),
                _buildQuickActions(),
                const SizedBox(height: AppSpacing.xxl),
                _buildDailyVerse(),
                const SizedBox(height: AppSpacing.xxl),
                _buildStartChatButton(),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppSpacing.horizontalXl,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $userName!',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ).animate().fadeIn(duration: AppAnimations.slow).slideX(begin: -0.3),
                  const SizedBox(height: 4),
                  Text(
                    'How can I encourage you today?',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast).slideX(begin: -0.3),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.goldColor.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
              child: Icon(
                Icons.person,
                color: AppColors.primaryText,
                size: 20,
              ),
            ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.normal).scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final streakAsync = ref.watch(devotionalStreakProvider);
    final totalCompletedAsync = ref.watch(totalDevotionalsCompletedProvider);
    final prayersCountAsync = ref.watch(activePrayersCountProvider);
    final versesCountAsync = ref.watch(savedVersesCountProvider);

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.horizontalXl,
        // Optimize horizontal scrolling performance
        physics: const BouncingScrollPhysics(),
        cacheExtent: 300,
        children: [
          streakAsync.when(
            data: (streak) => _buildStatCard(
              value: "$streak",
              label: "Day Streak",
              icon: Icons.local_fire_department,
              color: Colors.orange,
              delay: 600,
            ),
            loading: () => _buildStatCardLoading(
              label: "Day Streak",
              icon: Icons.local_fire_department,
              color: Colors.orange,
              delay: 600,
            ),
            error: (_, __) => _buildStatCard(
              value: "0",
              label: "Day Streak",
              icon: Icons.local_fire_department,
              color: Colors.orange,
              delay: 600,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          prayersCountAsync.when(
            data: (count) => _buildStatCard(
              value: "$count",
              label: "Prayers",
              icon: Icons.favorite,
              color: Colors.red,
              delay: 700,
            ),
            loading: () => _buildStatCardLoading(
              label: "Prayers",
              icon: Icons.favorite,
              color: Colors.red,
              delay: 700,
            ),
            error: (_, __) => _buildStatCard(
              value: "0",
              label: "Prayers",
              icon: Icons.favorite,
              color: Colors.red,
              delay: 700,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          versesCountAsync.when(
            data: (count) => _buildStatCard(
              value: "$count",
              label: "Saved Verses",
              icon: Icons.menu_book,
              color: AppTheme.goldColor,
              delay: 800,
            ),
            loading: () => _buildStatCardLoading(
              label: "Saved Verses",
              icon: Icons.menu_book,
              color: AppTheme.goldColor,
              delay: 800,
            ),
            error: (_, __) => _buildStatCard(
              value: "0",
              label: "Saved Verses",
              icon: Icons.menu_book,
              color: AppTheme.goldColor,
              delay: 800,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          totalCompletedAsync.when(
            data: (total) => _buildStatCard(
              value: "$total",
              label: "Devotionals",
              icon: Icons.auto_stories,
              color: Colors.green,
              delay: 900,
            ),
            loading: () => _buildStatCardLoading(
              label: "Devotionals",
              icon: Icons.auto_stories,
              color: Colors.green,
              delay: 900,
            ),
            error: (_, __) => _buildStatCard(
              value: "0",
              label: "Devotionals",
              icon: Icons.auto_stories,
              color: Colors.green,
              delay: 900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return Container(
      width: 140,
      padding: AppSpacing.screenPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: ResponsiveUtils.iconSize(context, 20),
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          // Value text with responsive sizing that scales down if needed
          LayoutBuilder(
            builder: (context, constraints) {
              return Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 16, maxSize: 22),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            },
          ),
          const SizedBox(height: 2),
          // Label text with responsive sizing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 9, minSize: 8, maxSize: 11),
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: delay.ms).slideY(begin: 0.3);
  }

  Widget _buildStatCardLoading({
    required String label,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return Container(
      width: 140,
      padding: AppSpacing.screenPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: ResponsiveUtils.iconSize(context, 20),
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: ResponsiveUtils.scaleSize(context, 20, minScale: 0.9, maxScale: 1.2),
            height: ResponsiveUtils.scaleSize(context, 20, minScale: 0.9, maxScale: 1.2),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 9, minSize: 8, maxSize: 11),
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: delay.ms).slideY(begin: 0.3);
  }

  Widget _buildMainFeatures() {
    return Padding(
      padding: AppSpacing.horizontalXl,
      child: Column(
        children: [
        Row(
          children: [
            Expanded(
              child: FrostedGlassCard(
                onTap: () => NavigationService.goToChat(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: ResponsiveUtils.iconSize(context, 24),
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "AI Guidance",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Get biblical wisdom for any situation you're facing",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                        color: AppColors.secondaryText,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: AppAnimations.slow, delay: 900.ms).slideX(begin: -0.3),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FrostedGlassCard(
                onTap: () => NavigationService.goToDevotional(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.auto_stories,
                        size: ResponsiveUtils.iconSize(context, 24),
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "Daily Devotional",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Grow closer to God with daily reflections",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                        color: AppColors.secondaryText,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: AppAnimations.slow, delay: 1000.ms).slideX(begin: 0.3),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: FrostedGlassCard(
                onTap: () => NavigationService.goToPrayerJournal(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.favorite_outline,
                        size: ResponsiveUtils.iconSize(context, 24),
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "Prayer Journal",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Track your prayers and see God's faithfulness",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                        color: AppColors.secondaryText,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: AppAnimations.slow, delay: 1100.ms).slideX(begin: -0.3),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FrostedGlassCard(
                onTap: () => NavigationService.goToReadingPlan(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.library_books_outlined,
                        size: ResponsiveUtils.iconSize(context, 24),
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "Reading Plans",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Structured Bible reading with daily guidance",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                        color: AppColors.secondaryText,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: AppAnimations.slow, delay: 1200.ms).slideX(begin: 0.3),
            ),
          ],
        ),
      ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.horizontalXl,
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ).animate().fadeIn(duration: AppAnimations.slow, delay: 1300.ms),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.horizontalXl,
            // Optimize horizontal scrolling performance
            physics: const BouncingScrollPhysics(),
            cacheExtent: 200,
            children: [
              _buildQuickActionCard(
                label: "Read Bible",
                icon: Icons.menu_book,
                color: AppTheme.goldColor,
                onTap: () => NavigationService.goToBibleBrowser(),
                delay: 1400,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildQuickActionCard(
                label: "Verse Library",
                icon: Icons.search,
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, AppRoutes.verseLibrary),
                delay: 1500,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildQuickActionCard(
                label: "Add Prayer",
                icon: Icons.add,
                color: Colors.green,
                onTap: () => NavigationService.goToPrayerJournal(),
                delay: 1600,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildQuickActionCard(
                label: "Settings",
                icon: Icons.settings,
                color: Colors.grey[300]!,
                onTap: () => NavigationService.goToSettings(),
                delay: 1700,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildQuickActionCard(
                label: "Profile",
                icon: Icons.person,
                color: Colors.purple,
                onTap: () => NavigationService.goToProfile(),
                delay: 1800,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: ResponsiveUtils.iconSize(context, 24),
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 11, minSize: 9, maxSize: 13),
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: delay.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildDailyVerse() {
    return Padding(
      padding: AppSpacing.horizontalXl,
      child: Container(
        padding: AppSpacing.screenPaddingLarge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryText,
                  size: ResponsiveUtils.iconSize(context, 20),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  'Verse of the Day',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"The Lord is my shepherd; I shall not want. He makes me lie down in green pastures. He leads me beside still waters."',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    color: AppColors.primaryText,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
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
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Psalm 23:1-2 ESV',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                        color: AppTheme.goldColor,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const CategoryBadge(
                      text: 'Comfort',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: 1800.ms).slideY(begin: 0.3);
  }

  Widget _buildStartChatButton() {
    return GlassButton(
      text: 'Start Spiritual Conversation',
      onPressed: () => NavigationService.goToChat(),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: 1900.ms).slideY(begin: 0.5);
  }
}