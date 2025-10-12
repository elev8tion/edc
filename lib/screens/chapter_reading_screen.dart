import 'package:flutter/material.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../theme/app_theme.dart';
import '../core/navigation/navigation_service.dart';

/// Placeholder for Chapter Reading Screen
/// This will be fully implemented by Agent 4
class ChapterReadingScreen extends StatelessWidget {
  final String book;
  final int startChapter;
  final int endChapter;
  final String? readingId;

  const ChapterReadingScreen({
    super.key,
    required this.book,
    required this.startChapter,
    required this.endChapter,
    this.readingId,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiChapter = endChapter > startChapter;
    final chapterRange = isMultiChapter
        ? '$book $startChapter-$endChapter'
        : '$book $startChapter';

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
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
                              chapterRange,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isMultiChapter
                                  ? '${endChapter - startChapter + 1} chapters'
                                  : '1 chapter',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FrostedGlassCard(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.construction,
                              size: 64,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Chapter Reader Coming Soon',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Agent 4 is building the full chapter reading experience',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Reading: $chapterRange',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (readingId != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Reading ID: $readingId',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
}
