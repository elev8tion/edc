import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_card.dart';
import '../components/glass_button.dart';
import '../components/category_badge.dart';
import '../components/base_bottom_sheet.dart';
import '../theme/app_theme.dart';

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
                  'Verse Library',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
                const SizedBox(height: 4),
                Text(
                  'Find comfort in God\'s word',
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            color: Colors.white,
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
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withValues(alpha: 0.8),
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
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  )
                : null,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
          ).animate().fadeIn(duration: 600.ms, delay: (600 + index * 100).ms).scale(begin: const Offset(0.8, 0.8));
        },
      ),
    );
  }

  Widget _buildTabBar() {
    final favoriteCount = _allVerses.where((v) => v.isFavorite).length;

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
            Tab(text: 'All Verses (${_filteredVerses.length})'),
            Tab(text: 'Favorites ($favoriteCount)'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms);
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
      padding: const EdgeInsets.all(20),
      itemCount: _filteredVerses.length,
      itemBuilder: (context, index) {
        final verse = _filteredVerses[index];
        return _buildVerseCard(verse, index).animate()
            .fadeIn(duration: 600.ms, delay: (1000 + index * 100).ms)
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
      padding: const EdgeInsets.all(20),
      itemCount: favoriteVerses.length,
      itemBuilder: (context, index) {
        final verse = favoriteVerses[index];
        return _buildVerseCard(verse, index).animate()
            .fadeIn(duration: 600.ms, delay: (1000 + index * 100).ms)
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
                        padding: const EdgeInsets.all(8),
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
                        padding: const EdgeInsets.all(8),
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
            const SizedBox(height: 16),
            Text(
              '"${verse.text}"',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.book,
                  size: 16,
                  color: AppTheme.goldColor.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share with Friends', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Share verse
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.white),
              title: const Text('Create Image Quote', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Create image quote
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Faith':
        return Colors.blue;
      case 'Hope':
        return Colors.green;
      case 'Love':
        return Colors.red;
      case 'Peace':
        return Colors.purple;
      case 'Strength':
        return Colors.orange;
      case 'Comfort':
        return Colors.cyan;
      case 'Guidance':
        return Colors.amber;
      case 'Wisdom':
        return Colors.indigo;
      case 'Forgiveness':
        return Colors.pink;
      default:
        return Colors.grey;
    }
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