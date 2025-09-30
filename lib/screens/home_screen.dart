import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../features/chat/screens/chat_screen.dart';
import '../components/feature_card.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
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
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                color: AppTheme.primaryColor,
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
          child: StatsCard(
            value: "7",
            label: "Day Streak",
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            value: "42",
            label: "Prayers",
            icon: Icons.favorite,
            color: Colors.red,
          ).animate().fadeIn(duration: 600.ms, delay: 700.ms).slideY(begin: 0.3),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            value: "156",
            label: "Verses Read",
            icon: Icons.menu_book,
            color: AppTheme.primaryColor,
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
              child: FeatureCard(
                icon: Icons.chat_bubble_outline,
                title: "AI Guidance",
                subtitle: "Get biblical wisdom for any situation you're facing",
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
              ).animate().fadeIn(duration: 600.ms, delay: 900.ms).slideX(begin: -0.3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FeatureCard(
                icon: Icons.book_outlined,
                title: "Daily Verse",
                subtitle: "Start your day with God's word and encouragement",
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.pushNamed(context, AppRoutes.verseLibrary),
              ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideX(begin: 0.3),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                icon: Icons.favorite_outline,
                title: "Prayer Journal",
                subtitle: "Track your prayers and see God's faithfulness",
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.pushNamed(context, AppRoutes.prayerJournal),
              ).animate().fadeIn(duration: 600.ms, delay: 1100.ms).slideX(begin: -0.3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FeatureCard(
                icon: Icons.library_books_outlined,
                title: "Verse Library",
                subtitle: "Explore thousands of verses by topic and theme",
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.pushNamed(context, AppRoutes.verseLibrary),
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
              QuickActionCard(
                icon: Icons.search,
                title: "Find Verse",
                onTap: () => Navigator.pushNamed(context, AppRoutes.verseLibrary),
                color: AppTheme.primaryColor,
              ).animate().fadeIn(duration: 600.ms, delay: 1400.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(width: 12),
              QuickActionCard(
                icon: Icons.add,
                title: "Add Prayer",
                onTap: () => Navigator.pushNamed(context, AppRoutes.prayerJournal),
                color: Colors.green,
              ).animate().fadeIn(duration: 600.ms, delay: 1500.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(width: 12),
              QuickActionCard(
                icon: Icons.share,
                title: "Share Verse",
                onTap: () {},
                color: Colors.blue,
              ).animate().fadeIn(duration: 600.ms, delay: 1600.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(width: 12),
              QuickActionCard(
                icon: Icons.settings,
                title: "Settings",
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                color: Colors.grey,
              ).animate().fadeIn(duration: 600.ms, delay: 1700.ms).scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyVerse() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
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
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Start Spiritual Conversation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 1900.ms).slideY(begin: 0.5);
  }
}