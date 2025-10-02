import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../services/verse_service.dart';
import '../services/devotional_service.dart';
import '../services/reading_plan_service.dart';
import '../services/bible_loader_service.dart';

// Core Services
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Feature Services
final prayerServiceProvider = Provider<PrayerService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return PrayerService(database);
});

final verseServiceProvider = Provider<VerseService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return VerseService(database);
});

final devotionalServiceProvider = Provider<DevotionalService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return DevotionalService(database);
});

final readingPlanServiceProvider = Provider<ReadingPlanService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return ReadingPlanService(database);
});

final bibleLoaderServiceProvider = Provider<BibleLoaderService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return BibleLoaderService(database);
});

// State Providers
final connectivityStateProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

final appInitializationProvider = FutureProvider<void>((ref) async {
  final database = ref.read(databaseServiceProvider);
  final notifications = ref.read(notificationServiceProvider);
  final bibleLoader = ref.read(bibleLoaderServiceProvider);

  await database.initialize();
  await notifications.initialize();

  // Load Bible on first launch
  final isKJVLoaded = await bibleLoader.isBibleLoaded('KJV');
  if (!isKJVLoaded) {
    print('📖 Loading Bible for first time...');
    await bibleLoader.loadAllBibles();
    print('✅ Bible loaded successfully!');
  } else {
    print('✅ Bible already loaded');
  }
});

// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark); // Default to dark

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}