import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/category_badge.dart';
import '../theme/app_theme.dart';
import '../core/navigation/app_routes.dart';

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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 24),
                        _buildStatsSection(),
                        const SizedBox(height: 24),
                        _buildAchievementsSection(),
                        const SizedBox(height: 24),
                        _buildMenuSection(),
                        const SizedBox(height: 24),
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
    return SliverToBoxAdapter(
      child: Padding(
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
              child: const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              child: ClearGlassCard(
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.settings,
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

  Widget _buildProfileCard() {
    return FrostedGlassCard(
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
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
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ).animate().scale(duration: 600.ms),

          const SizedBox(height: 16),

          // Name
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

          const SizedBox(height: 4),

          // Email
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

          const SizedBox(height: 12),

          // Member since
          CategoryBadge(
            text: 'Member since ${_formatDate(memberSince)}',
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            fontSize: 11,
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

          const SizedBox(height: 20),

          // Edit Profile Button
          GestureDetector(
            onTap: _showEditProfileDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.goldColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Spiritual Journey',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

        const SizedBox(height: 16),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
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
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, int delay) {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: delay.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            CategoryBadge(
              text: '${achievements.where((a) => a.isUnlocked).length}/${achievements.length}',
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              fontSize: 11,
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 1100.ms),

        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementCard(achievement, index)
                .animate()
                .fadeIn(duration: 600.ms, delay: (1200 + index * 100).ms)
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
        padding: const EdgeInsets.all(16),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                achievement.icon,
                size: 24,
                color: achievement.isUnlocked
                    ? achievement.color
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),

            const SizedBox(width: 16),

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
                            fontSize: 16,
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
                          size: 20,
                          color: achievement.color,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  if (!achievement.isUnlocked && achievement.progress != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
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
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.6),
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
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 1500.ms),

        const SizedBox(height: 16),

        FrostedGlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildMenuItem(
                'Settings',
                Icons.settings,
                () => Navigator.pushNamed(context, AppRoutes.settings),
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
        ).animate().fadeIn(duration: 600.ms, delay: 1600.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.white.withValues(alpha: 0.9),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? Colors.red.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5),
        size: 20,
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
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
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
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
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
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // In production, save to user service/provider
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Profile updated successfully'),
                            backgroundColor: AppTheme.primaryColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save'),
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
              const Icon(
                Icons.logout,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign Out?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to sign out?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // In production, handle sign out logic
                        Navigator.pop(context);
                        Navigator.pop(context); // Go back to home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Sign Out'),
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
