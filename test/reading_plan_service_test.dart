import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/reading_plan_service.dart';
import 'package:everyday_christian/core/models/reading_plan.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ReadingPlanService', () {
    late DatabaseService databaseService;
    late ReadingPlanService readingPlanService;

    setUp(() async {
      // Use in-memory database for testing
      DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
      databaseService = DatabaseService();
      readingPlanService = ReadingPlanService(databaseService);
      await databaseService.initialize();
    });

    tearDown(() async {
      DatabaseService.setTestDatabasePath(null);
    });

    group('Get Plans', () {
      test('should get all reading plans', () async {
        final plans = await readingPlanService.getAllPlans();

        expect(plans, isA<List<ReadingPlan>>());
        expect(plans.length, greaterThan(0));
      });

      test('should get active plans only', () async {
        // Start a plan first
        final allPlans = await readingPlanService.getAllPlans();
        if (allPlans.isNotEmpty) {
          await readingPlanService.startPlan(allPlans.first.id);

          final activePlans = await readingPlanService.getActivePlans();

          expect(activePlans, isA<List<ReadingPlan>>());
          expect(activePlans.length, equals(1));
          expect(activePlans.first.isStarted, isTrue);
        }
      });

      test('should get current plan', () async {
        final allPlans = await readingPlanService.getAllPlans();
        if (allPlans.isNotEmpty) {
          await readingPlanService.startPlan(allPlans.first.id);

          final currentPlan = await readingPlanService.getCurrentPlan();

          expect(currentPlan, isNotNull);
          expect(currentPlan!.id, equals(allPlans.first.id));
          expect(currentPlan.isStarted, isTrue);
        }
      });

      test('should return null when no plan is active', () async {
        // Stop all plans first
        final allPlans = await readingPlanService.getAllPlans();
        for (final plan in allPlans) {
          await readingPlanService.stopPlan(plan.id);
        }

        final currentPlan = await readingPlanService.getCurrentPlan();

        expect(currentPlan, isNull);
      });
    });

    group('Start and Stop Plans', () {
      test('should start a reading plan', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final planToStart = plans.first;

          await readingPlanService.startPlan(planToStart.id);

          final activePlans = await readingPlanService.getActivePlans();
          expect(activePlans.length, equals(1));
          expect(activePlans.first.id, equals(planToStart.id));
          expect(activePlans.first.startDate, isNotNull);
        }
      });

      test('should stop all other plans when starting a new one', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.length >= 2) {
          // Start first plan
          await readingPlanService.startPlan(plans[0].id);

          // Start second plan (should stop first)
          await readingPlanService.startPlan(plans[1].id);

          final activePlans = await readingPlanService.getActivePlans();
          expect(activePlans.length, equals(1));
          expect(activePlans.first.id, equals(plans[1].id));
        }
      });

      test('should stop a reading plan', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;

          // Start the plan
          await readingPlanService.startPlan(plan.id);
          expect((await readingPlanService.getActivePlans()).length, equals(1));

          // Stop the plan
          await readingPlanService.stopPlan(plan.id);

          final activePlans = await readingPlanService.getActivePlans();
          expect(activePlans.length, equals(0));
        }
      });
    });

    group('Update Progress', () {
      test('should update plan progress', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;

          await readingPlanService.updateProgress(plan.id, 5);

          final updatedPlans = await readingPlanService.getAllPlans();
          final updatedPlan = updatedPlans.firstWhere((p) => p.id == plan.id);

          expect(updatedPlan.completedReadings, equals(5));
        }
      });

      test('should increment progress correctly', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;

          await readingPlanService.updateProgress(plan.id, 3);
          await readingPlanService.updateProgress(plan.id, 7);

          final updatedPlans = await readingPlanService.getAllPlans();
          final updatedPlan = updatedPlans.firstWhere((p) => p.id == plan.id);

          expect(updatedPlan.completedReadings, equals(7));
        }
      });
    });

    group('Daily Readings', () {
      test('should get todays readings for a plan', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;
          await readingPlanService.startPlan(plan.id);

          final todaysReadings = await readingPlanService.getTodaysReadings(plan.id);

          expect(todaysReadings, isA<List<DailyReading>>());
          // May be empty if no readings scheduled for today
        }
      });

      test('should get all readings for a plan', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;

          final readings = await readingPlanService.getReadingsForPlan(plan.id);

          expect(readings, isA<List<DailyReading>>());
          // May be zero if daily_readings table is empty
          if (readings.isNotEmpty) {
            // Verify readings are ordered by date
            for (int i = 0; i < readings.length - 1; i++) {
              expect(
                readings[i].date.isBefore(readings[i + 1].date) ||
                    readings[i].date.isAtSameMomentAs(readings[i + 1].date),
                isTrue,
              );
            }
          }
        }
      });

      test('should mark reading as completed', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;
          final readings = await readingPlanService.getReadingsForPlan(plan.id);

          if (readings.isNotEmpty) {
            final reading = readings.first;

            await readingPlanService.markReadingCompleted(reading.id);

            final updatedReadings = await readingPlanService.getReadingsForPlan(plan.id);
            final completedReading = updatedReadings.firstWhere((r) => r.id == reading.id);

            expect(completedReading.isCompleted, isTrue);
            expect(completedReading.completedDate, isNotNull);
          }
        }
      });

      test('should update plan progress when marking reading complete', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;
          final readings = await readingPlanService.getReadingsForPlan(plan.id);

          if (readings.isNotEmpty) {
            final initialProgress = plan.completedReadings;

            await readingPlanService.markReadingCompleted(readings.first.id);

            final updatedPlans = await readingPlanService.getAllPlans();
            final updatedPlan = updatedPlans.firstWhere((p) => p.id == plan.id);

            expect(updatedPlan.completedReadings, greaterThan(initialProgress));
          }
        }
      });

      test('should get completed readings count', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;
          final readings = await readingPlanService.getReadingsForPlan(plan.id);

          if (readings.length >= 2) {
            // Mark two readings as complete
            await readingPlanService.markReadingCompleted(readings[0].id);
            await readingPlanService.markReadingCompleted(readings[1].id);

            final count = await readingPlanService.getCompletedReadingsCount(plan.id);

            expect(count, greaterThanOrEqualTo(2));
          }
        }
      });
    });

    group('Plan Model Conversion', () {
      test('should correctly convert database map to ReadingPlan', () async {
        final plans = await readingPlanService.getAllPlans();

        if (plans.isNotEmpty) {
          final plan = plans.first;

          expect(plan.id, isNotEmpty);
          expect(plan.title, isNotEmpty);
          expect(plan.description, isNotEmpty);
          expect(plan.duration, isNotEmpty);
          expect(plan.category, isA<PlanCategory>());
          expect(plan.difficulty, isA<PlanDifficulty>());
          expect(plan.estimatedTimePerDay, isNotEmpty);
          expect(plan.totalReadings, greaterThan(0));
          expect(plan.completedReadings, greaterThanOrEqualTo(0));
          expect(plan.isStarted, isA<bool>());
        }
      });

      test('should correctly convert database map to DailyReading', () async {
        final plans = await readingPlanService.getAllPlans();

        if (plans.isNotEmpty) {
          final readings = await readingPlanService.getReadingsForPlan(plans.first.id);

          if (readings.isNotEmpty) {
            final reading = readings.first;

            expect(reading.id, isNotEmpty);
            expect(reading.planId, equals(plans.first.id));
            expect(reading.title, isNotEmpty);
            expect(reading.description, isNotEmpty);
            expect(reading.book, isNotEmpty);
            expect(reading.chapters, isNotEmpty);
            expect(reading.estimatedTime, isNotEmpty);
            expect(reading.date, isA<DateTime>());
            expect(reading.isCompleted, isA<bool>());
          }
        }
      });
    });

    group('Edge Cases', () {
      test('should handle multiple readings completed on same day', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;
          final readings = await readingPlanService.getReadingsForPlan(plan.id);

          if (readings.length >= 3) {
            // Mark multiple readings as complete
            await readingPlanService.markReadingCompleted(readings[0].id);
            await readingPlanService.markReadingCompleted(readings[1].id);
            await readingPlanService.markReadingCompleted(readings[2].id);

            final count = await readingPlanService.getCompletedReadingsCount(plan.id);
            expect(count, greaterThanOrEqualTo(3));
          }
        }
      });

      test('should handle starting same plan multiple times', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;

          await readingPlanService.startPlan(plan.id);
          final firstStartDate = (await readingPlanService.getCurrentPlan())!.startDate;

          // Wait a moment
          await Future.delayed(Duration(milliseconds: 10));

          await readingPlanService.startPlan(plan.id);
          final secondStartDate = (await readingPlanService.getCurrentPlan())!.startDate;

          // Start date should be updated
          expect(secondStartDate!.isAfter(firstStartDate!), isTrue);
        }
      });

      test('should return empty list for non-existent plan readings', () async {
        final readings = await readingPlanService.getReadingsForPlan('non_existent_id');

        expect(readings, isEmpty);
      });
    });
  });
}
