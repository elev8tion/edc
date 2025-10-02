import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_button.dart';
import '../components/category_badge.dart';
import '../theme/app_theme.dart';

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
                  'Prayer Journal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
                const SizedBox(height: 4),
                Text(
                  'Bring your requests to God',
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
          tabs: [
            Tab(text: 'Active (${_activePrayers.length})'),
            Tab(text: 'Answered (${_answeredPrayers.length})'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
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
      padding: const EdgeInsets.all(20),
      itemCount: _activePrayers.length,
      itemBuilder: (context, index) {
        final prayer = _activePrayers[index];
        return _buildPrayerCard(prayer, index).animate()
            .fadeIn(duration: 600.ms, delay: (600 + index * 100).ms)
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
      padding: const EdgeInsets.all(20),
      itemCount: _answeredPrayers.length,
      itemBuilder: (context, index) {
        final prayer = _answeredPrayers[index];
        return _buildPrayerCard(prayer, index).animate()
            .fadeIn(duration: 600.ms, delay: (600 + index * 100).ms)
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
                    onSelected: (value) {
                      if (value == 'mark_answered') {
                        _markPrayerAnswered(prayer);
                      } else if (value == 'delete') {
                        _deletePrayer(prayer);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'mark_answered',
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 18),
                            SizedBox(width: 8),
                            Text('Mark as Answered'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.more_vert,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prayer.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prayer.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
            if (prayer.isAnswered && prayer.answerDescription != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(prayer.dateCreated),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                if (prayer.isAnswered && prayer.dateAnswered != null) ...[
                  const SizedBox(width: 16),
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Title',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) => title = value,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'What are you praying for?',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
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
                    'Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<PrayerCategory>(
                      value: selectedCategory,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: AppTheme.primaryColor,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      items: PrayerCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_getCategoryName(category)),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) => description = value,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Share more details about your prayer request...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
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
                            if (title.isNotEmpty && description.isNotEmpty) {
                              _addPrayer(title, description, selectedCategory);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Add Prayer'),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'How did God answer this prayer?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => answerDescription = value,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Share how God answered your prayer...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
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
                          if (answerDescription.isNotEmpty) {
                            setState(() {
                              prayer.isAnswered = true;
                              prayer.dateAnswered = DateTime.now();
                              prayer.answerDescription = answerDescription;
                              _activePrayers.remove(prayer);
                              _answeredPrayers.insert(0, prayer);
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Mark Answered'),
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