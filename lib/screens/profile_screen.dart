import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../components/category_badge.dart';
import '../components/glass_button.dart';
import '../theme/app_theme.dart';
import '../core/navigation/navigation_service.dart';
import '../utils/responsive_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User data - In production, this would come from a user service/provider
  final String userName = "Friend";
  final String userEmail = "friend@example.com";
  final DateTime memberSince = DateTime(2024, 1, 15);

  // Spiritual journey stats
  final int totalPrayers = 42;
  final int answeredPrayers = 12;
  final int daysStreak = 7;
  final int versesRead = 156;
  final int devotionalsCompleted = 23;
  final int readingPlansActive = 2;

  // Achievements
  final List<Achievement> achievements = [
    Achievement(
      title: 'Prayer Warrior',
      description: 'Prayed for 7 days in a row',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      isUnlocked: true,
    ),
    Achievement(
      title: 'Bible Scholar',
      description: 'Read 100 verses',
      icon: Icons.book,
      color: Colors.blue,
      isUnlocked: true,
    ),
    Achievement(
      title: 'Faithful Friend',
      description: 'Complete 30 devotionals',
      icon: Icons.favorite,
      color: Colors.pink,
      isUnlocked: false,
      progress: 23,
      total: 30,
    ),
    Achievement(
      title: 'Scripture Master',
      description: 'Complete 5 reading plans',
      icon: Icons.stars,
      color: AppTheme.goldColor,
      isUnlocked: false,
      progress: 2,
      total: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveUtils.maxContentWidth(context),
                      ),
                      child: Padding(
                        padding: ResponsiveUtils.padding(context, horizontal: 16, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileCard(),
                            const SizedBox(height: AppSpacing.xxl),
                            _buildStatsSection(),
                            const SizedBox(height: AppSpacing.xxl),
                            _buildAchievementsSection(),
                            const SizedBox(height: AppSpacing.xxl),
                            _buildMenuSection(),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Row(
          children: [
            const GlassmorphicFABMenu(),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'Profile',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AutoSizeText(
                    'Your spiritual journey and achievements',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ).animate().fadeIn(duration: AppAnimations.slow).slideX(begin: -0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return FrostedGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar on the LEFT
          Container(
            width: ResponsiveUtils.scaleSize(context, 80, minScale: 0.9, maxScale: 1.3),
            height: ResponsiveUtils.scaleSize(context, 80, minScale: 0.9, maxScale: 1.3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.goldColor,
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                userName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 32, minSize: 28, maxSize: 36),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ).animate().scale(duration: AppAnimations.slow),

          const SizedBox(width: 12),

          // Name, email, member info in the MIDDLE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 22, minSize: 18, maxSize: 26),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast),

                const SizedBox(height: AppSpacing.sm),

                CategoryBadge(
                  text: 'Member since ${_formatDate(memberSince)}',
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  fontSize: ResponsiveUtils.fontSize(context, 9, minSize: 7, maxSize: 11),
                ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.normal),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Edit Profile Button on the RIGHT
          Flexible(
            child: GestureDetector(
              onTap: _showEditProfileDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.goldColor,
                  ],
                ),
                borderRadius: AppRadius.mediumRadius,
              ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ).animate().fadeIn(duration: AppAnimations.slow, delay: 500.ms),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: 0.2);
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Spiritual Journey',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.slow),

        const SizedBox(height: AppSpacing.lg),

        // Responsive grid: 2 columns on mobile, 3 on tablet, 4 on desktop
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = ResponsiveUtils.gridColumns(
              context,
              mobile: 2,
              tablet: 3,
              desktop: 4,
            );

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: ResponsiveUtils.spacing(context, 12),
              crossAxisSpacing: ResponsiveUtils.spacing(context, 12),
              childAspectRatio: ResponsiveUtils.valueByDevice(
                context,
                mobile: 1.3,
                tablet: 1.2,
                desktop: 1.1,
              ),
              children: [
            _buildStatCard(
              'Prayer Streak',
              '$daysStreak days',
              Icons.local_fire_department,
              Colors.orange,
              700,
            ),
            _buildStatCard(
              'Total Prayers',
              '$totalPrayers',
              Icons.favorite,
              Colors.pink,
              800,
            ),
            _buildStatCard(
              'Verses Read',
              '$versesRead',
              Icons.book,
              Colors.blue,
              900,
            ),
            _buildStatCard(
              'Devotionals',
              '$devotionalsCompleted',
              Icons.auto_stories,
              Colors.purple,
              1000,
            ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, int delay) {
    return FrostedGlassCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Icon(
              icon,
              size: ResponsiveUtils.iconSize(context, 22),
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 10, minSize: 9, maxSize: 12),
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: delay.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            CategoryBadge(
              text: '${achievements.where((a) => a.isUnlocked).length}/${achievements.length}',
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              fontSize: ResponsiveUtils.fontSize(context, 11, minSize: 9, maxSize: 13),
            ),
          ],
        ).animate().fadeIn(duration: AppAnimations.slow, delay: 1100.ms),

        const SizedBox(height: AppSpacing.lg),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementCard(achievement, index)
                .animate()
                .fadeIn(duration: AppAnimations.slow, delay: (1200 + index * 100).ms)
                .slideX(begin: 0.2);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: FrostedGlassCard(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? achievement.color.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Icon(
                achievement.icon,
                size: ResponsiveUtils.iconSize(context, 24),
                color: achievement.isUnlocked
                    ? achievement.color
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),

            const SizedBox(width: AppSpacing.lg),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                            fontWeight: FontWeight.w700,
                            color: achievement.isUnlocked
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      if (achievement.isUnlocked)
                        Icon(
                          Icons.check_circle,
                          size: ResponsiveUtils.iconSize(context, 20),
                          color: achievement.color,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  if (!achievement.isUnlocked && achievement.progress != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xs / 2),
                      child: LinearProgressIndicator(
                        value: achievement.progress! / achievement.total!,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(achievement.color),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${achievement.progress}/${achievement.total}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 10, minSize: 9, maxSize: 12),
                        color: AppColors.tertiaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ).animate().fadeIn(duration: AppAnimations.slow, delay: 1500.ms),

        const SizedBox(height: AppSpacing.lg),

        FrostedGlassCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              _buildMenuItem(
                'Settings',
                Icons.settings,
                () => NavigationService.goToSettings(),
              ),
              _buildDivider(),
              _buildMenuItem(
                'Privacy Policy',
                Icons.privacy_tip,
                () {},
              ),
              _buildDivider(),
              _buildMenuItem(
                'Terms of Service',
                Icons.description,
                () {},
              ),
              _buildDivider(),
              _buildMenuItem(
                'Help & Support',
                Icons.help,
                () {},
              ),
              _buildDivider(),
              _buildMenuItem(
                'Sign Out',
                Icons.logout,
                _showSignOutDialog,
                isDestructive: true,
              ),
            ],
          ),
        ).animate().fadeIn(duration: AppAnimations.slow, delay: 1200.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.white.withValues(alpha: 0.9),
        size: ResponsiveUtils.iconSize(context, 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? Colors.red.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5),
        size: ResponsiveUtils.iconSize(context, 20),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  void _showEditProfileDialog() {
    String newName = userName;
    String newEmail = userEmail;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: FrostedGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(
                'Name',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: TextEditingController(text: userName),
                onChanged: (value) => newName = value,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mediumRadius,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'Email',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: TextEditingController(text: userEmail),
                onChanged: (value) => newEmail = value,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mediumRadius,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'Cancel',
                      height: 48,
                      onPressed: () => NavigationService.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      text: 'Save',
                      height: 48,
                      onPressed: () {
                        // In production, save to user service/provider
                        NavigationService.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Profile updated successfully'),
                            backgroundColor: AppTheme.primaryColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.mediumRadius,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: FrostedGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout,
                size: ResponsiveUtils.iconSize(context, 48),
                color: Colors.red,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Sign Out?',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Are you sure you want to sign out?',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'Cancel',
                      height: 48,
                      onPressed: () => NavigationService.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      text: 'Sign Out',
                      height: 48,
                      onPressed: () {
                        // In production, handle sign out logic
                        NavigationService.pop();
                        NavigationService.pop(); // Go back to home
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final int? progress;
  final int? total;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    this.progress,
    this.total,
  });
}
