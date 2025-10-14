import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../core/services/verse_service.dart';
import '../core/services/database_service.dart';
import '../core/models/bible_verse.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

class DailyVerseScreen extends StatefulWidget {
  const DailyVerseScreen({super.key});

  @override
  State<DailyVerseScreen> createState() => _DailyVerseScreenState();
}

class _DailyVerseScreenState extends State<DailyVerseScreen> {
  late VerseService _verseService;
  BibleVerse? _todayVerse;
  List<Map<String, dynamic>> _verseHistory = [];
  bool _isLoading = true;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final databaseService = DatabaseService();
    await databaseService.initialize();
    _verseService = VerseService(databaseService);
    await _loadTodayVerse();
    await _loadVerseHistory();
  }

  Future<void> _loadTodayVerse() async {
    setState(() => _isLoading = true);
    try {
      final verse = await _verseService.getVerseOfTheDay();
      setState(() {
        _todayVerse = verse;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading today\'s verse: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadVerseHistory() async {
    try {
      final history = await _verseService.getDailyVerseHistory(limit: 30);
      setState(() {
        _verseHistory = history;
      });
    } catch (e) {
      print('Error loading verse history: $e');
    }
  }

  Future<void> _shareVerse() async {
    if (_todayVerse != null) {
      final text = '"${_todayVerse!.text}"\n\n${_todayVerse!.reference}';
      await Share.share(
        text,
        subject: 'Verse of the Day',
      );
    }
  }

  Future<void> _copyVerse() async {
    if (_todayVerse != null) {
      final text = '"${_todayVerse!.text}"\n\n${_todayVerse!.reference}';
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verse copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Daily Verse'),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showHistory ? Icons.today : Icons.history,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.goldColor,
              ),
            )
          : _showHistory
              ? _buildHistoryView()
              : _buildTodayVerseView(),
    );
  }

  Widget _buildTodayVerseView() {
    if (_todayVerse == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: ResponsiveUtils.iconSize(context, 64),
              color: AppTheme.goldColor,
            ),
            const SizedBox(height: 16),
            AutoSizeText(
              'No verse available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTodayVerse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldColor,
                foregroundColor: Colors.black,
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Today's date
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.goldColor.withOpacity(0.2),
                  AppTheme.goldColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.goldColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.goldColor,
                  size: ResponsiveUtils.iconSize(context, 20),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Verse card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.goldColor.withOpacity(0.3),
                        AppTheme.goldColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.goldColor.withOpacity(0.4),
                    ),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppTheme.goldColor,
                    size: ResponsiveUtils.iconSize(context, 28),
                  ),
                ),
                const SizedBox(height: 24),

                // Verse text
                Text(
                  _todayVerse!.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Reference
                Text(
                  _todayVerse!.reference,
                  style: TextStyle(
                    color: AppTheme.goldColor,
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),

                // Category badge
                Wrap(
                  spacing: 8,
                  children: [
                    _buildCategoryBadge(_todayVerse!.category.displayName),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareVerse,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyVerse,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.goldColor,
                    side: const BorderSide(color: AppTheme.goldColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    if (_verseHistory.isEmpty) {
      return Center(
        child: Text(
          'No verse history yet',
          style: TextStyle(
            color: Colors.white70,
            fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _verseHistory.length,
      itemBuilder: (context, index) {
        final item = _verseHistory[index];
        final verse = item['verse'] as BibleVerse;
        final shownDate = item['shownDate'] as DateTime;
        final theme = item['theme'] as String?;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(shownDate),
                    style: TextStyle(
                      color: AppTheme.goldColor.withOpacity(0.8),
                      fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (theme != null)
                    _buildCategoryBadge(theme, small: true),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                verse.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                verse.reference,
                style: TextStyle(
                  color: AppTheme.goldColor,
                  fontSize: ResponsiveUtils.fontSize(context, 13, minSize: 11, maxSize: 15),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryBadge(String text, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.goldColor.withOpacity(0.3),
            AppTheme.goldColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.goldColor.withOpacity(0.4),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.goldColor,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
