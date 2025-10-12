import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../core/navigation/navigation_service.dart';
import '../services/bible_chapter_service.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

/// Free Bible Browser - allows users to browse and read any Bible chapter
class BibleBrowserScreen extends ConsumerStatefulWidget {
  const BibleBrowserScreen({super.key});

  @override
  ConsumerState<BibleBrowserScreen> createState() => _BibleBrowserScreenState();
}

class _BibleBrowserScreenState extends ConsumerState<BibleBrowserScreen> {
  final BibleChapterService _bibleService = BibleChapterService();
  final TextEditingController _searchController = TextEditingController();

  List<String> _allBooks = [];
  List<String> _filteredBooks = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Bible structure - maps book names to testament
  static const Map<String, String> _bookTestaments = {
    // Old Testament
    'Genesis': 'Old Testament',
    'Exodus': 'Old Testament',
    'Leviticus': 'Old Testament',
    'Numbers': 'Old Testament',
    'Deuteronomy': 'Old Testament',
    'Joshua': 'Old Testament',
    'Judges': 'Old Testament',
    'Ruth': 'Old Testament',
    '1 Samuel': 'Old Testament',
    '2 Samuel': 'Old Testament',
    '1 Kings': 'Old Testament',
    '2 Kings': 'Old Testament',
    '1 Chronicles': 'Old Testament',
    '2 Chronicles': 'Old Testament',
    'Ezra': 'Old Testament',
    'Nehemiah': 'Old Testament',
    'Esther': 'Old Testament',
    'Job': 'Old Testament',
    'Psalms': 'Old Testament',
    'Proverbs': 'Old Testament',
    'Ecclesiastes': 'Old Testament',
    'Song of Solomon': 'Old Testament',
    'Isaiah': 'Old Testament',
    'Jeremiah': 'Old Testament',
    'Lamentations': 'Old Testament',
    'Ezekiel': 'Old Testament',
    'Daniel': 'Old Testament',
    'Hosea': 'Old Testament',
    'Joel': 'Old Testament',
    'Amos': 'Old Testament',
    'Obadiah': 'Old Testament',
    'Jonah': 'Old Testament',
    'Micah': 'Old Testament',
    'Nahum': 'Old Testament',
    'Habakkuk': 'Old Testament',
    'Zephaniah': 'Old Testament',
    'Haggai': 'Old Testament',
    'Zechariah': 'Old Testament',
    'Malachi': 'Old Testament',
    // New Testament
    'Matthew': 'New Testament',
    'Mark': 'New Testament',
    'Luke': 'New Testament',
    'John': 'New Testament',
    'Acts': 'New Testament',
    'Romans': 'New Testament',
    '1 Corinthians': 'New Testament',
    '2 Corinthians': 'New Testament',
    'Galatians': 'New Testament',
    'Ephesians': 'New Testament',
    'Philippians': 'New Testament',
    'Colossians': 'New Testament',
    '1 Thessalonians': 'New Testament',
    '2 Thessalonians': 'New Testament',
    '1 Timothy': 'New Testament',
    '2 Timothy': 'New Testament',
    'Titus': 'New Testament',
    'Philemon': 'New Testament',
    'Hebrews': 'New Testament',
    'James': 'New Testament',
    '1 Peter': 'New Testament',
    '2 Peter': 'New Testament',
    '1 John': 'New Testament',
    '2 John': 'New Testament',
    '3 John': 'New Testament',
    'Jude': 'New Testament',
    'Revelation': 'New Testament',
  };

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bibleService.getAllBooks();
      if (mounted) {
        setState(() {
          _allBooks = books;
          _filteredBooks = books;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading books: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterBooks(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBooks = _allBooks;
      } else {
        _filteredBooks = _allBooks
            .where((book) => book.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  List<String> _getOldTestamentBooks() {
    return _filteredBooks
        .where((book) => _bookTestaments[book] == 'Old Testament')
        .toList();
  }

  List<String> _getNewTestamentBooks() {
    return _filteredBooks
        .where((book) => _bookTestaments[book] == 'New Testament')
        .toList();
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
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildBibleBrowser(),
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
      padding: const EdgeInsets.all(16.0),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bible Browser',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Read any chapter freely',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterBooks,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Search books...',
                  hintStyle: TextStyle(
                    color: AppColors.tertiaryText,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.clear, color: AppColors.primaryText),
                onPressed: () {
                  _searchController.clear();
                  _filterBooks('');
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBibleBrowser() {
    final oldTestamentBooks = _getOldTestamentBooks();
    final newTestamentBooks = _getNewTestamentBooks();

    if (oldTestamentBooks.isEmpty && newTestamentBooks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No books found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (oldTestamentBooks.isNotEmpty) ...[
            Text(
              'Old Testament',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            ...oldTestamentBooks.map((book) => _buildBookCard(book)),
            const SizedBox(height: 24),
          ],
          if (newTestamentBooks.isNotEmpty) ...[
            Text(
              'New Testament',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            ...newTestamentBooks.map((book) => _buildBookCard(book)),
          ],
        ],
      ),
    );
  }

  Widget _buildBookCard(String book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showChapterSelector(book),
        child: FrostedGlassCard(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  book,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showChapterSelector(String book) async {
    final chapterCount = await _bibleService.getChapterCount(book);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1a1a2e).withValues(alpha: 0.95),
                const Color(0xFF16213e).withValues(alpha: 0.95),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Chapter - $book',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: chapterCount,
                  itemBuilder: (context, index) {
                    final chapterNum = index + 1;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        NavigationService.goToChapterReading(
                          book: book,
                          startChapter: chapterNum,
                          endChapter: chapterNum,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$chapterNum',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
