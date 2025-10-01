import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../features/chat/screens/chat_screen.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/feature_card.dart';
import '../components/glass_button.dart';
import '../components/gradient_background.dart';
import '../core/navigation/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String greeting;
  late String userName;

  @override
  void initState() {
    super.initState();
    _setGreeting();
    userName = "Friend"; // In production, get from user preferences
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = "Good morning";
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
          const GradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildMainFeatures(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildDailyVerse(),
                const SizedBox(height: 24),
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
    return Column(
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
                    '$greeting, $userName! 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
                  const SizedBox(height: 4),
                  Text(
                    'How can I encourage you today?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.3),
                ],
              ),
            ),
            const SizedBox(width: 12),
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
                color: Colors.white,
                size: 20,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms).scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: ClearGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "7",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.orange,
                      ),
                    ),
                    Icon(
                      Icons.local_fire_department,
                      size: 20,
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Day Streak",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClearGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "42",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.red,
                      ),
                    ),
                    Icon(
                      Icons.favorite,
                      size: 20,
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Prayers",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 700.ms).slideY(begin: 0.3),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClearGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "156",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Icon(
                      Icons.menu_book,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Verses Read",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3),
        ),
      ],
    );
  }

  Widget _buildMainFeatures() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FrostedGlassCard(
                onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "AI Guidance",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Get biblical wisdom for any situation you're facing",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 900.ms).slideX(begin: -0.3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FrostedGlassCard(
                onTap: () => Navigator.pushNamed(context, AppRoutes.verseLibrary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.book_outlined,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Daily Verse",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Start your day with God's word and encouragement",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideX(begin: 0.3),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FrostedGlassCard(
                onTap: () => Navigator.pushNamed(context, AppRoutes.prayerJournal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.favorite_outline,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Prayer Journal",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Track your prayers and see God's faithfulness",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 1100.ms).slideX(begin: -0.3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FrostedGlassCard(
                onTap: () => Navigator.pushNamed(context, AppRoutes.verseLibrary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.library_books_outlined,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Verse Library",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Explore thousands of verses by topic and theme",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 1200.ms).slideX(begin: 0.3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 1300.ms),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ClearGlassCard(
                onTap: () => Navigator.pushNamed(context, AppRoutes.verseLibrary),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 10,
                      child: Icon(
                        Icons.search,
                        size: 20,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        "Find Verse",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 1400.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(width: 12),
              ClearGlassCard(
                onTap: () => Navigator.pushNamed(context, AppRoutes.prayerJournal),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 10,
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        "Add Prayer",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 1500.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(width: 12),
              ClearGlassCard(
                onTap: () {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 10,
                      child: Icon(
                        Icons.share,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        "Share Verse",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 1600.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(width: 12),
              ClearGlassCard(
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClearGlassCard(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 10,
                      child: Icon(
                        Icons.settings,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 1700.ms).scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyVerse() {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClearGlassCard(
                padding: const EdgeInsets.all(8),
                borderRadius: 8,
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Verse of the Day',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '"The Lord is my shepherd; I shall not want. He makes me lie down in green pastures. He leads me beside still waters."',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontStyle: FontStyle.italic,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Psalm 23:1-2 ESV',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 1800.ms).slideY(begin: 0.3);
  }

  Widget _buildStartChatButton() {
    return GlassButton(
      text: 'Start Spiritual Conversation',
      onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
    ).animate().fadeIn(duration: 600.ms, delay: 1900.ms).slideY(begin: 0.5);
  }
}