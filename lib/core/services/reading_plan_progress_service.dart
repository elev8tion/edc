import 'package:uuid/uuid.dart';
import '../models/reading_plan.dart';
import 'database_service.dart';

/// Service for tracking reading plan progress
class ReadingPlanProgressService {
  final DatabaseService _database;
  final _uuid = const Uuid();

  ReadingPlanProgressService(this._database);

  /// Mark a specific day/reading as complete
  Future<void> markDayComplete(String readingId) async {
    try {
      final db = await _database.database;
      final now = DateTime.now();

      // Update the daily reading
      await db.update(
        'daily_readings',
        {
          'is_completed': 1,
          'completed_date': now.millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [readingId],
      );

      // Get the reading to find its plan
      final readings = await db.query(
        'daily_readings',
        where: 'id = ?',
        whereArgs: [readingId],
      );

      if (readings.isNotEmpty) {
        final planId = readings.first['plan_id'] as String;
        await _updatePlanProgress(planId);
      }
    } catch (e) {
      throw Exception('Failed to mark day complete: $e');
    }
  }

  /// Mark a day as incomplete (undo completion)
  Future<void> markDayIncomplete(String readingId) async {
    try {
      final db = await _database.database;

      // Get the reading to find its plan before updating
      final readings = await db.query(
        'daily_readings',
        where: 'id = ?',
        whereArgs: [readingId],
      );

      if (readings.isEmpty) return;

      final planId = readings.first['plan_id'] as String;

      // Update the daily reading
      await db.update(
        'daily_readings',
        {
          'is_completed': 0,
          'completed_date': null,
        },
        where: 'id = ?',
        whereArgs: [readingId],
      );

      await _updatePlanProgress(planId);
    } catch (e) {
      throw Exception('Failed to mark day incomplete: $e');
    }
  }

  /// Get progress percentage for a plan (0-100)
  Future<double> getProgressPercentage(String planId) async {
    try {
      final db = await _database.database;

      // Get plan details
      final plans = await db.query(
        'reading_plans',
        where: 'id = ?',
        whereArgs: [planId],
      );

      if (plans.isEmpty) return 0.0;

      final totalReadings = plans.first['total_readings'] as int;
      if (totalReadings == 0) return 0.0;

      // Get completed readings count
      final completedResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM daily_readings WHERE plan_id = ? AND is_completed = 1',
        [planId],
      );

      final completedCount = completedResult.first['count'] as int;
      return (completedCount / totalReadings) * 100;
    } catch (e) {
      throw Exception('Failed to get progress percentage: $e');
    }
  }

  /// Get current day number in the plan
  Future<int> getCurrentDay(String planId) async {
    try {
      final db = await _database.database;

      // Get plan start date
      final plans = await db.query(
        'reading_plans',
        where: 'id = ?',
        whereArgs: [planId],
      );

      if (plans.isEmpty || plans.first['start_date'] == null) return 1;

      final startDate = DateTime.fromMillisecondsSinceEpoch(
        plans.first['start_date'] as int,
      );
      final today = DateTime.now();
      final daysSinceStart = today.difference(startDate).inDays;

      return daysSinceStart + 1; // Day 1, not Day 0
    } catch (e) {
      throw Exception('Failed to get current day: $e');
    }
  }

  /// Reset a plan (mark all readings as incomplete)
  Future<void> resetPlan(String planId) async {
    try {
      final db = await _database.database;

      // Mark all readings as incomplete
      await db.update(
        'daily_readings',
        {
          'is_completed': 0,
          'completed_date': null,
        },
        where: 'plan_id = ?',
        whereArgs: [planId],
      );

      // Reset plan progress
      await db.update(
        'reading_plans',
        {
          'completed_readings': 0,
          'is_started': 0,
          'start_date': null,
        },
        where: 'id = ?',
        whereArgs: [planId],
      );
    } catch (e) {
      throw Exception('Failed to reset plan: $e');
    }
  }

  /// Get all completed readings for a plan
  Future<List<DailyReading>> getCompletedReadings(String planId) async {
    try {
      final db = await _database.database;
      final maps = await db.query(
        'daily_readings',
        where: 'plan_id = ? AND is_completed = 1',
        whereArgs: [planId],
        orderBy: 'completed_date DESC',
      );

      return maps.map((map) => _readingFromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get completed readings: $e');
    }
  }

  /// Get all incomplete readings for a plan
  Future<List<DailyReading>> getIncompleteReadings(String planId) async {
    try {
      final db = await _database.database;
      final maps = await db.query(
        'daily_readings',
        where: 'plan_id = ? AND is_completed = 0',
        whereArgs: [planId],
        orderBy: 'date ASC',
      );

      return maps.map((map) => _readingFromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get incomplete readings: $e');
    }
  }

  /// Get today's readings for a plan
  Future<List<DailyReading>> getTodaysReadings(String planId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final db = await _database.database;
      final maps = await db.query(
        'daily_readings',
        where: 'plan_id = ? AND date >= ? AND date < ?',
        whereArgs: [
          planId,
          startOfDay.millisecondsSinceEpoch,
          endOfDay.millisecondsSinceEpoch,
        ],
      );

      return maps.map((map) => _readingFromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get today\'s readings: $e');
    }
  }

  /// Create sample daily readings for a plan
  Future<void> createSampleReadings(String planId, int totalDays) async {
    try {
      final db = await _database.database;
      final startDate = DateTime.now();

      // Sample Bible books and chapters
      final sampleReadings = [
        {'book': 'Genesis', 'chapters': '1-3', 'title': 'The Beginning'},
        {'book': 'Matthew', 'chapters': '1-2', 'title': 'The Birth of Jesus'},
        {'book': 'Psalms', 'chapters': '1', 'title': 'Blessed is the One'},
        {'book': 'John', 'chapters': '1', 'title': 'The Word Became Flesh'},
        {'book': 'Romans', 'chapters': '8', 'title': 'Life in the Spirit'},
      ];

      for (int i = 0; i < totalDays; i++) {
        final sample = sampleReadings[i % sampleReadings.length];
        final reading = {
          'id': _uuid.v4(),
          'plan_id': planId,
          'title': '${sample['book']} ${sample['chapters']}',
          'description': sample['title']!,
          'book': sample['book']!,
          'chapters': sample['chapters']!,
          'estimated_time': '${5 + (i % 10)} minutes',
          'date': startDate.add(Duration(days: i)).millisecondsSinceEpoch,
          'is_completed': 0,
          'completed_date': null,
        };

        await db.insert('daily_readings', reading);
      }
    } catch (e) {
      throw Exception('Failed to create sample readings: $e');
    }
  }

  /// Get reading streak (consecutive days completed)
  Future<int> getStreak(String planId) async {
    try {
      final db = await _database.database;
      final readings = await db.query(
        'daily_readings',
        where: 'plan_id = ? AND is_completed = 1',
        whereArgs: [planId],
        orderBy: 'completed_date DESC',
      );

      if (readings.isEmpty) return 0;

      int streak = 0;
      DateTime? lastDate;

      for (final reading in readings) {
        final completedDate = DateTime.fromMillisecondsSinceEpoch(
          reading['completed_date'] as int,
        );

        if (lastDate == null) {
          // First completed reading
          streak = 1;
          lastDate = completedDate;
        } else {
          // Check if consecutive
          final daysDifference = lastDate.difference(completedDate).inDays;
          if (daysDifference == 1) {
            streak++;
            lastDate = completedDate;
          } else {
            // Streak broken
            break;
          }
        }
      }

      return streak;
    } catch (e) {
      throw Exception('Failed to get streak: $e');
    }
  }

  /// Internal method to update plan progress
  Future<void> _updatePlanProgress(String planId) async {
    final db = await _database.database;

    // Count completed readings
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM daily_readings WHERE plan_id = ? AND is_completed = 1',
      [planId],
    );

    final completedCount = result.first['count'] as int;

    // Update plan
    await db.update(
      'reading_plans',
      {'completed_readings': completedCount},
      where: 'id = ?',
      whereArgs: [planId],
    );
  }

  /// Helper method to convert map to DailyReading
  DailyReading _readingFromMap(Map<String, dynamic> map) {
    return DailyReading(
      id: map['id'],
      planId: map['plan_id'],
      title: map['title'],
      description: map['description'],
      book: map['book'],
      chapters: map['chapters'],
      estimatedTime: map['estimated_time'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isCompleted: map['is_completed'] == 1,
      completedDate: map['completed_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_date'])
          : null,
    );
  }
}
