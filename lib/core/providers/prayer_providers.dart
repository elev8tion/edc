import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prayer_request.dart';
import '../error/error_handler.dart';
import 'app_providers.dart';

// Prayer Lists
final activePrayersProvider = FutureProvider<List<PrayerRequest>>((ref) async {
  try {
    final service = ref.read(prayerServiceProvider);
    return await service.getActivePrayers();
  } catch (error) {
    throw ErrorHandler.handle(error);
  }
});

final answeredPrayersProvider = FutureProvider<List<PrayerRequest>>((ref) async {
  try {
    final service = ref.read(prayerServiceProvider);
    return await service.getAnsweredPrayers();
  } catch (error) {
    throw ErrorHandler.handle(error);
  }
});

// Prayer Statistics
final prayerStatsProvider = FutureProvider<PrayerStats>((ref) async {
  try {
    final service = ref.read(prayerServiceProvider);
    final totalCount = await service.getPrayerCount();
    final answeredCount = await service.getAnsweredPrayerCount();

    return PrayerStats(
      totalPrayers: totalCount,
      answeredPrayers: answeredCount,
      activePrayers: totalCount - answeredCount,
    );
  } catch (error) {
    throw ErrorHandler.handle(error);
  }
});

// Prayer Actions
final prayerActionsProvider = Provider<PrayerActions>((ref) {
  final service = ref.read(prayerServiceProvider);
  final streakService = ref.read(prayerStreakServiceProvider);

  return PrayerActions(
    addPrayer: (title, description, category) async {
      try {
        await service.createPrayer(
          title: title,
          description: description,
          category: category,
        );
        // Record prayer activity for streak tracking
        await streakService.recordPrayerActivity();

        // Invalidate providers to refresh UI
        ref.invalidate(activePrayersProvider);
        ref.invalidate(prayerStatsProvider);
        ref.invalidate(currentPrayerStreakProvider);
        ref.invalidate(longestPrayerStreakProvider);
        ref.invalidate(prayedTodayProvider);
        ref.invalidate(totalDaysPrayedProvider);
      } catch (error) {
        throw ErrorHandler.handle(error);
      }
    },
    markAnswered: (id, answer) async {
      try {
        await service.markPrayerAnswered(id, answer);
        // Record prayer activity for streak tracking
        await streakService.recordPrayerActivity();

        // Invalidate providers to refresh UI
        ref.invalidate(activePrayersProvider);
        ref.invalidate(answeredPrayersProvider);
        ref.invalidate(prayerStatsProvider);
        ref.invalidate(currentPrayerStreakProvider);
        ref.invalidate(longestPrayerStreakProvider);
        ref.invalidate(prayedTodayProvider);
        ref.invalidate(totalDaysPrayedProvider);
      } catch (error) {
        throw ErrorHandler.handle(error);
      }
    },
    deletePrayer: (id) async {
      try {
        await service.deletePrayer(id);
        ref.invalidate(activePrayersProvider);
        ref.invalidate(prayerStatsProvider);
      } catch (error) {
        throw ErrorHandler.handle(error);
      }
    },
  );
});

class PrayerStats {
  final int totalPrayers;
  final int answeredPrayers;
  final int activePrayers;

  PrayerStats({
    required this.totalPrayers,
    required this.answeredPrayers,
    required this.activePrayers,
  });
}

class PrayerActions {
  final Future<void> Function(String title, String description, PrayerCategory category) addPrayer;
  final Future<void> Function(String id, String answer) markAnswered;
  final Future<void> Function(String id) deletePrayer;

  PrayerActions({
    required this.addPrayer,
    required this.markAnswered,
    required this.deletePrayer,
  });
}