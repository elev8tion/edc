import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_card.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_card.dart';
import '../components/glass_button.dart';
import '../components/category_badge.dart';
import '../components/blur_dropdown.dart';
import '../theme/app_theme.dart';
import '../core/navigation/navigation_service.dart';

class PrayerJournalScreen extends StatefulWidget {
  const PrayerJournalScreen({super.key});

  @override
  State<PrayerJournalScreen> createState() => _PrayerJournalScreenState();
}

class _PrayerJournalScreenState extends State<PrayerJournalScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _prayerController = TextEditingController();

  final List<PrayerRequest> _activePrayers = [
    PrayerRequest(
      id: '1',
      title: 'Healing for Mom',
      description: 'Praying for my mother\'s recovery from surgery',
      category: PrayerCategory.health,
      dateCreated: DateTime.now().subtract(const Duration(days: 3)),
      isAnswered: false,
    ),
    PrayerRequest(
      id: '2',
      title: 'Job Interview',
      description: 'Praying for wisdom and favor in upcoming job interview',
      category: PrayerCategory.work,
      dateCreated: DateTime.now().subtract(const Duration(days: 1)),
      isAnswered: false,
    ),
  ];

  final List<PrayerRequest> _answeredPrayers = [
    PrayerRequest(
      id: '3',
      title: 'Safe Travel',
      description: 'Praying for safe travels on family vacation',
      category: PrayerCategory.protection,
      dateCreated: DateTime.now().subtract(const Duration(days: 10)),
      isAnswered: true,
      dateAnswered: DateTime.now().subtract(const Duration(days: 2)),
      answerDescription: 'Had a wonderful and safe trip with the family!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _prayerController.dispose();
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
                      _buildActivePrayers(),
                      _buildAnsweredPrayers(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPrayerDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
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
                  'Prayer Journal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ).animate().fadeIn(duration: AppAnimations.slow).slideX(begin: -0.3),
                const SizedBox(height: 4),
                Text(
                  'Bring your requests to God',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: AppSpacing.horizontalXl,
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
          tabs: [
            Tab(text: 'Active (${_activePrayers.length})'),
            Tab(text: 'Answered (${_answeredPrayers.length})'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.normal);
  }

  Widget _buildActivePrayers() {
    if (_activePrayers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_outline,
        title: 'No Active Prayers',
        subtitle: 'Start your prayer journey by adding your first prayer request',
      );
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: _activePrayers.length,
      itemBuilder: (context, index) {
        final prayer = _activePrayers[index];
        return _buildPrayerCard(prayer, index).animate()
            .fadeIn(duration: AppAnimations.slow, delay: (600 + index * 100).ms)
            .slideY(begin: 0.3);
      },
    );
  }

  Widget _buildAnsweredPrayers() {
    if (_answeredPrayers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No Answered Prayers Yet',
        subtitle: 'When God answers your prayers, mark them as answered to see them here',
      );
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: _answeredPrayers.length,
      itemBuilder: (context, index) {
        final prayer = _answeredPrayers[index];
        return _buildPrayerCard(prayer, index).animate()
            .fadeIn(duration: AppAnimations.slow, delay: (600 + index * 100).ms)
            .slideY(begin: 0.3);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClearGlassCard(
              padding: AppSpacing.screenPaddingLarge,
              child: Icon(
                icon,
                size: 48,
                color: AppColors.tertiaryText,
              ),
            ).animate().fadeIn(duration: AppAnimations.slow).scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast),
            const SizedBox(height: AppSpacing.md),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.normal),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCard(PrayerRequest prayer, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FrostedGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryBadge(
                  text: _getCategoryName(prayer.category),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  fontSize: 11,
                ),
                const Spacer(),
                if (prayer.isAnswered)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                  )
                else
                  PopupMenuButton<String>(
                    color: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onSelected: (value) {
                      if (value == 'mark_answered') {
                        _markPrayerAnswered(prayer);
                      } else if (value == 'delete') {
                        _deletePrayer(prayer);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'mark_answered',
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () {
                                    Navigator.pop(context, 'mark_answered');
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white24
                                            : Colors.white54,
                                        width: 2,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.check, size: 18, color: Colors.white),
                                        SizedBox(width: AppSpacing.sm),
                                        Text('Mark as Answered', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () {
                                  Navigator.pop(context, 'delete');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white24
                                          : Colors.white54,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.delete, size: 18, color: Colors.red),
                                      SizedBox(width: AppSpacing.sm),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.more_vert,
                        size: 18,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              prayer.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              prayer.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
            if (prayer.isAnswered && prayer.answerDescription != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How God Answered:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prayer.answerDescription!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: AppColors.tertiaryText,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(prayer.dateCreated),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.tertiaryText,
                  ),
                ),
                if (prayer.isAnswered && prayer.dateAnswered != null) ...[
                  const SizedBox(width: AppSpacing.lg),
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.green.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Answered ${_formatDate(prayer.dateAnswered!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.withValues(alpha: 0.8),
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

  void _showAddPrayerDialog() {
    PrayerCategory selectedCategory = PrayerCategory.general;
    String title = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: FrostedGlassCard(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Prayer Request',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  const Text(
                    'Title',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    onChanged: (value) => title = value,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'What are you praying for?',
                      hintStyle: TextStyle(color: AppColors.tertiaryText),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 40,
                    child: BlurDropdown(
                      value: _getCategoryName(selectedCategory),
                      items: PrayerCategory.values.map((category) => _getCategoryName(category)).toList(),
                      hint: 'Select Category',
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = PrayerCategory.values.firstWhere(
                              (category) => _getCategoryName(category) == value,
                            );
                          });
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    onChanged: (value) => description = value,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Share more details about your prayer request...',
                      hintStyle: TextStyle(color: AppColors.tertiaryText),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                          text: 'Add Prayer',
                          height: 48,
                          onPressed: () {
                            if (title.isNotEmpty && description.isNotEmpty) {
                              _addPrayer(title, description, selectedCategory);
                              NavigationService.pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addPrayer(String title, String description, PrayerCategory category) {
    final newPrayer = PrayerRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      dateCreated: DateTime.now(),
      isAnswered: false,
    );

    setState(() {
      _activePrayers.insert(0, newPrayer);
    });
  }

  void _markPrayerAnswered(PrayerRequest prayer) {
    showDialog(
      context: context,
      builder: (context) {
        String answerDescription = '';

        return Dialog(
          backgroundColor: Colors.transparent,
          child: FrostedGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mark as Answered',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                const Text(
                  'How did God answer this prayer?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  onChanged: (value) => answerDescription = value,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Share how God answered your prayer...',
                    hintStyle: TextStyle(color: AppColors.tertiaryText),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                        text: 'Mark Answered',
                        height: 48,
                        onPressed: () {
                          if (answerDescription.isNotEmpty) {
                            setState(() {
                              prayer.isAnswered = true;
                              prayer.dateAnswered = DateTime.now();
                              prayer.answerDescription = answerDescription;
                              _activePrayers.remove(prayer);
                              _answeredPrayers.insert(0, prayer);
                            });
                            NavigationService.pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deletePrayer(PrayerRequest prayer) {
    setState(() {
      _activePrayers.remove(prayer);
    });
  }

  Color _getCategoryColor(PrayerCategory category) {
    switch (category) {
      case PrayerCategory.health:
        return Colors.red;
      case PrayerCategory.family:
        return Colors.pink;
      case PrayerCategory.work:
        return Colors.blue;
      case PrayerCategory.protection:
        return Colors.orange;
      case PrayerCategory.guidance:
        return Colors.purple;
      case PrayerCategory.gratitude:
        return Colors.green;
      case PrayerCategory.general:
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(PrayerCategory category) {
    switch (category) {
      case PrayerCategory.health:
        return 'Health';
      case PrayerCategory.family:
        return 'Family';
      case PrayerCategory.work:
        return 'Work/Career';
      case PrayerCategory.protection:
        return 'Protection';
      case PrayerCategory.guidance:
        return 'Guidance';
      case PrayerCategory.gratitude:
        return 'Gratitude';
      case PrayerCategory.general:
      default:
        return 'General';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class PrayerRequest {
  final String id;
  final String title;
  final String description;
  final PrayerCategory category;
  final DateTime dateCreated;
  bool isAnswered;
  DateTime? dateAnswered;
  String? answerDescription;

  PrayerRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateCreated,
    required this.isAnswered,
    this.dateAnswered,
    this.answerDescription,
  });
}

enum PrayerCategory {
  general,
  health,
  family,
  work,
  protection,
  guidance,
  gratitude,
}