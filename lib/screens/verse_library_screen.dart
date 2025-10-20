import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/clear_glass_card.dart';
import '../components/glass_card.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../components/category_badge.dart';
import '../components/base_bottom_sheet.dart';
import '../theme/app_theme.dart';
import '../theme/app_gradients.dart';
import '../core/navigation/navigation_service.dart';
import '../models/bible_verse.dart';
import '../core/providers/app_providers.dart';
import '../utils/responsive_utils.dart';

// Provider for all saved verses
final filteredVersesProvider = FutureProvider.autoDispose<List<BibleVerse>>((ref) async {
  final service = ref.watch(unifiedVerseServiceProvider);
  return await service.getAllVerses(limit: 100);
});

class VerseLibraryScreen extends ConsumerStatefulWidget {
  const VerseLibraryScreen({super.key});

  @override
  ConsumerState<VerseLibraryScreen> createState() => _VerseLibraryScreenState();
}

class _VerseLibraryScreenState extends ConsumerState<VerseLibraryScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: AppTheme.primaryColor,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSavedVerses(),
                      _buildSharedVerses(),
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
          const GlassmorphicFABMenu(),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Verse Library',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: AppAnimations.slow).slideX(begin: -0.3),
                const SizedBox(height: 4),
                AutoSizeText(
                  'Everyday Verses',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.glassStrong,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white, size: ResponsiveUtils.iconSize(context, 24)),
              onPressed: _showVerseOptions,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTabBar() {
    final favorites = ref.watch(favoriteVersesProvider);
    final favoriteCount = favorites.when(
      data: (verses) => verses.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final allVerses = ref.watch(filteredVersesProvider);
    final allCount = allVerses.when(
      data: (verses) => verses.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Container(
      margin: AppSpacing.horizontalXl,
      child: FrostedGlassCard(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 1,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
          ),
          tabs: [
            Tab(text: 'Saved Verses ($favoriteCount)'),
            Tab(text: 'Shared (0)'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppAnimations.slow, delay: 800.ms);
  }

  Widget _buildSharedVerses() {
    // Placeholder for shared verses feature (to be implemented)
    return _buildEmptyState(
      icon: Icons.share_outlined,
      title: 'No shared verses yet',
      subtitle: 'Verses you share via Messages, Mail, etc. will appear here',
    );
  }

  // Deprecated: Removed pre-populated "All Verses" tab
  // Widget _buildAllVerses() { ... }

  Widget _buildSavedVerses() {
    final favoritesAsync = ref.watch(favoriteVersesProvider);

    return favoritesAsync.when(
      data: (verses) {
        if (verses.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_outline,
            title: 'No saved verses yet',
            subtitle: '💡 Save verses while reading to build your collection',
          );
        }

        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            return _buildVerseCard(verse, index).animate()
                .fadeIn(duration: AppAnimations.slow, delay: (100 + index * 50).ms)
                .slideY(begin: 0.3);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
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
                size: ResponsiveUtils.iconSize(context, 48),
                color: AppColors.tertiaryText,
              ),
            ).animate().fadeIn(duration: AppAnimations.slow).scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast),
            const SizedBox(height: AppSpacing.md),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.iconSize(context, 48),
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                color: AppColors.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
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
                const Spacer(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleFavorite(verse),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Icon(
                          verse.isFavorite ? Icons.favorite : Icons.favorite_outline,
                          size: ResponsiveUtils.iconSize(context, 20),
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
                          size: ResponsiveUtils.iconSize(context, 20),
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
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
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
                  size: ResponsiveUtils.iconSize(context, 16),
                  color: AppTheme.goldColor.withValues(alpha: 0.8),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  verse.reference,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '(${verse.translation})',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (verse.themes.length > 1) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: verse.themes.skip(1).take(3).map((theme) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: AppRadius.smallRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      theme.substring(0, 1).toUpperCase() + theme.substring(1),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 11, minSize: 9, maxSize: 13),
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(BibleVerse verse) async {
    if (verse.id == null) return;

    final service = ref.read(unifiedVerseServiceProvider);

    try {
      final newStatus = await service.toggleFavorite(verse.id!);

      // Refresh both tabs
      ref.invalidate(filteredVersesProvider);
      ref.invalidate(favoriteVersesProvider);

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? 'Added to favorites' : 'Removed from favorites',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating favorite: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
                final text = '"${verse.text}"\n\n${verse.reference} (${verse.translation})';
                Clipboard.setData(ClipboardData(text: text));
                NavigationService.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Verse copied to clipboard'),
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.9),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share with Friends', style: TextStyle(color: Colors.white)),
              onTap: () async {
                NavigationService.pop();
                // Share verse with friends using share_plus
                final shareText = '"${verse.text}"\n\n— ${verse.reference}';
                await Share.share(
                  shareText,
                  subject: 'Bible Verse - ${verse.reference}',
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showVerseOptions() {
    showCustomBottomSheet(
      context: context,
      title: 'Verse Library Options',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.customColored(AppTheme.primaryColor),
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Icon(Icons.info_outline, color: AppTheme.primaryColor),
            ),
            title: const Text(
              'About Verse Library',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            subtitle: Text(
              'Browse your saved Bible verses',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                color: AppColors.secondaryText,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
