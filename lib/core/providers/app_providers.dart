import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../services/verse_service.dart';
import '../services/devotional_service.dart';
import '../services/reading_plan_service.dart';

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

// State Providers
final connectivityStateProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

final appInitializationProvider = FutureProvider<void>((ref) async {
  final database = ref.read(databaseServiceProvider);
  final notifications = ref.read(notificationServiceProvider);

  await database.initialize();
  await notifications.initialize();
});