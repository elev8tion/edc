import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_card.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_card.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_card.dart';
import '../components/category_badge.dart';
import '../components/base_bottom_sheet.dart';
import '../theme/app_theme.dart';
import '../core/navigation/navigation_service.dart';

class VerseLibraryScreen extends StatefulWidget {
  const VerseLibraryScreen({super.key});

  @override
  State<VerseLibraryScreen> createState() => _VerseLibraryScreenState();
}

class _VerseLibraryScreenState extends State<VerseLibraryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<BibleVerse> _filteredVerses = [];
  bool _isSearching = false;

  final List<String> _categories = [
    'All', 'Faith', 'Hope', 'Love', 'Peace', 'Strength', 'Comfort', 'Guidance', 'Wisdom', 'Forgiveness'
  ];

  final List<BibleVerse> _allVerses = [
    BibleVerse(
      id: '1',
      text: 'For I know the plans I have for you, declares the Lord, plans for welfare and not for evil, to give you a future and a hope.',
      reference: 'Jeremiah 29:11',
      category: 'Hope',
      isFavorite: true,
    ),
    BibleVerse(
      id: '2',
      text: 'Trust in the Lord with all your heart, and do not lean on your own understanding.',
      reference: 'Proverbs 3:5',
      category: 'Faith',
      isFavorite: false,
    ),
    BibleVerse(
      id: '3',
      text: 'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.',
      reference: 'Romans 8:28',
      category: 'Faith',
      isFavorite: true,
    ),
    BibleVerse(
      id: '4',
      text: 'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
      reference: 'Joshua 1:9',
      category: 'Strength',
      isFavorite: false,
    ),
    BibleVerse(
      id: '5',
      text: 'Peace I leave with you; my peace I give you. I do not give to you as the world gives. Do not let your hearts be troubled and do not be afraid.',
      reference: 'John 14:27',
      category: 'Peace',
      isFavorite: true,
    ),
    BibleVerse(
      id: '6',
      text: 'The Lord is my shepherd; I shall not want. He makes me lie down in green pastures. He leads me beside still waters.',
      reference: 'Psalm 23:1-2',
      category: 'Comfort',
      isFavorite: false,
    ),
    BibleVerse(
      id: '7',
      text: 'Love is patient, love is kind. It does not envy, it does not boast, it is not proud.',
      reference: '1 Corinthians 13:4',
      category: 'Love',
      isFavorite: true,
    ),
    BibleVerse(
      id: '8',
      text: 'If any of you lacks wisdom, you should ask God, who gives generously to all without finding fault, and it will be given to you.',
      reference: 'James 1:5',
      category: 'Wisdom',
      isFavorite: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredVerses = _allVerses;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterVerses() {
    setState(() {
      _filteredVerses = _allVerses.where((verse) {
        final matchesSearch = _searchController.text.isEmpty ||
            verse.text.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            verse.reference.toLowerCase().contains(_searchController.text.toLowerCase());

        final matchesCategory = _selectedCategory == 'All' || verse.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _toggleFavorite(BibleVerse verse) {
    setState(() {
      verse.isFavorite = !verse.isFavorite;
    });
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
                _buildSearchBar(),
                _buildCategoryFilter(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllVerses(),
                      _buildFavoriteVerses(),
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
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => NavigationService.pop(),
            child: const ClearGlassCard(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.primaryText,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verse Library',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ).animate().fadeIn(duration: AppAnimations.slow).slideX(begin: -0.3),
                const SizedBox(height: 4),
                Text(
                  'Find comfort in God\'s word',
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

  Widget _buildSearchBar() {
    return Container(
      margin: AppSpacing.horizontalXl,
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _isSearching = value.isNotEmpty;
            });
            _filterVerses();
          },
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Search verses or references...',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            contentPadding: AppSpacing.verticalMd,
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.secondaryText,
            ),
            suffixIcon: _isSearching
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                      });
                      _filterVerses();
                    },
                    child: Icon(
                      Icons.clear,
                      color: AppColors.secondaryText,
                    ),
                  )
                : null,
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.normal);
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: AppSpacing.verticalLg,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.horizontalXl,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                _filterVerses();
              },
              child: CategoryBadge(
                text: category,
                isSelected: isSelected,
              ),
            ),
          ).animate().fadeIn(duration: AppAnimations.slow, delay: (600 + index * 100).ms).scale(begin: const Offset(0.8, 0.8));
        },
      ),
    );
  }

  Widget _buildTabBar() {
    final favoriteCount = _allVerses.where((v) => v.isFavorite).length;

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
            Tab(text: 'All Verses (${_filteredVerses.length})'),
            Tab(text: 'Favorites ($favoriteCount)'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: 800.ms);
  }

  Widget _buildAllVerses() {
    if (_filteredVerses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'No verses found',
        subtitle: _isSearching
            ? 'Try adjusting your search or category filter'
            : 'No verses available in this category',
      );
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: _filteredVerses.length,
      itemBuilder: (context, index) {
        final verse = _filteredVerses[index];
        return _buildVerseCard(verse, index).animate()
            .fadeIn(duration: AppAnimations.slow, delay: (1000 + index * 100).ms)
            .slideY(begin: 0.3);
      },
    );
  }

  Widget _buildFavoriteVerses() {
    final favoriteVerses = _allVerses.where((v) => v.isFavorite).toList();

    if (favoriteVerses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_outline,
        title: 'No favorite verses yet',
        subtitle: 'Tap the heart icon on any verse to add it to your favorites',
      );
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: favoriteVerses.length,
      itemBuilder: (context, index) {
        final verse = favoriteVerses[index];
        return _buildVerseCard(verse, index).animate()
            .fadeIn(duration: AppAnimations.slow, delay: (1000 + index * 100).ms)
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

  Widget _buildVerseCard(BibleVerse verse, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FrostedGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryBadge(
                  text: verse.category,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  fontSize: 12,
                ),
                const Spacer(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleFavorite(verse),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Icon(
                          verse.isFavorite ? Icons.favorite : Icons.favorite_outline,
                          size: 20,
                          color: verse.isFavorite ? Colors.red : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showShareOptions(verse),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Icon(
                          Icons.share,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '"${verse.text}"',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primaryText,
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(
                  Icons.book,
                  size: 16,
                  color: AppTheme.goldColor.withValues(alpha: 0.8),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  verse.reference,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BibleVerse verse) {
    showCustomBottomSheet(
      context: context,
      title: 'Share Verse',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.white),
              title: const Text('Copy to Clipboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Copy verse to clipboard
                NavigationService.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share with Friends', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Share verse
                NavigationService.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.white),
              title: const Text('Create Image Quote', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Create image quote
                NavigationService.pop();
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class BibleVerse {
  final String id;
  final String text;
  final String reference;
  final String category;
  bool isFavorite;

  BibleVerse({
    required this.id,
    required this.text,
    required this.reference,
    required this.category,
    required this.isFavorite,
  });
}