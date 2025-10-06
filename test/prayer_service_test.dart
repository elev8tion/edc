import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/prayer_service.dart';
import 'package:everyday_christian/core/models/prayer_request.dart';

void main() {
  late DatabaseService databaseService;
  late PrayerService prayerService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
    databaseService = DatabaseService();
    await databaseService.initialize();
    prayerService = PrayerService(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
    DatabaseService.setTestDatabasePath(null);
  });

  group('Prayer CRUD Operations', () {
    test('should create prayer with all fields', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Test Prayer',
        description: 'Please help me with this test',
        category: PrayerCategory.general,
      );

      expect(prayer.id, isNotEmpty);
      expect(prayer.title, equals('Test Prayer'));
      expect(prayer.description, equals('Please help me with this test'));
      expect(prayer.category, equals(PrayerCategory.general));
      expect(prayer.isAnswered, isFalse);
      expect(prayer.dateAnswered, isNull);
    });

    test('should create prayers with different categories', () async {
      final categories = [
        PrayerCategory.health,
        PrayerCategory.family,
        PrayerCategory.work,
        PrayerCategory.protection,
        PrayerCategory.guidance,
        PrayerCategory.gratitude,
      ];

      for (final category in categories) {
        final prayer = await prayerService.createPrayer(
          title: 'Prayer for ${category.name}',
          description: 'Test prayer',
          category: category,
        );
        expect(prayer.category, equals(category));
      }
    });

    test('should add prayer manually', () async {
      final prayer = PrayerRequest(
        id: 'test-id',
        title: 'Manual Prayer',
        description: 'Added manually',
        category: PrayerCategory.family,
        dateCreated: DateTime.now(),
      );

      await prayerService.addPrayer(prayer);
      final prayers = await prayerService.getAllPrayers();
      expect(prayers.any((p) => p.id == 'test-id'), isTrue);
    });

    test('should update prayer', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Original Title',
        description: 'Original description',
        category: PrayerCategory.general,
      );

      final updated = prayer.copyWith(
        title: 'Updated Title',
        description: 'Updated description',
      );

      await prayerService.updatePrayer(updated);
      final prayers = await prayerService.getAllPrayers();
      final found = prayers.firstWhere((p) => p.id == prayer.id);

      expect(found.title, equals('Updated Title'));
      expect(found.description, equals('Updated description'));
    });

    test('should delete prayer', () async {
      final prayer = await prayerService.createPrayer(
        title: 'To Delete',
        description: 'This will be deleted',
        category: PrayerCategory.general,
      );

      await prayerService.deletePrayer(prayer.id);
      final prayers = await prayerService.getAllPrayers();
      expect(prayers.any((p) => p.id == prayer.id), isFalse);
    });
  });

  group('Prayer Answered Operations', () {
    test('should mark prayer as answered', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Prayer to Answer',
        description: 'Waiting for answer',
        category: PrayerCategory.health,
      );

      await prayerService.markPrayerAnswered(
        prayer.id,
        'God answered with healing',
      );

      final answered = await prayerService.getAnsweredPrayers();
      final found = answered.firstWhere((p) => p.id == prayer.id);

      expect(found.isAnswered, isTrue);
      expect(found.answerDescription, equals('God answered with healing'));
      expect(found.dateAnswered, isNotNull);
    });

    test('should get only answered prayers', () async {
      await prayerService.createPrayer(
        title: 'Active Prayer',
        description: 'Still waiting',
        category: PrayerCategory.general,
      );

      final answered = await prayerService.createPrayer(
        title: 'Will be answered',
        description: 'Answer coming',
        category: PrayerCategory.guidance,
      );

      await prayerService.markPrayerAnswered(
        answered.id,
        'Answered!',
      );

      final answeredPrayers = await prayerService.getAnsweredPrayers();
      expect(answeredPrayers.length, equals(1));
      expect(answeredPrayers.first.id, equals(answered.id));
    });

    test('should get only active prayers', () async {
      final active = await prayerService.createPrayer(
        title: 'Active Prayer',
        description: 'Still praying',
        category: PrayerCategory.protection,
      );

      final toAnswer = await prayerService.createPrayer(
        title: 'To Answer',
        description: 'Will be answered',
        category: PrayerCategory.general,
      );

      await prayerService.markPrayerAnswered(toAnswer.id, 'Done');

      final activePrayers = await prayerService.getActivePrayers();
      expect(activePrayers.length, equals(1));
      expect(activePrayers.first.id, equals(active.id));
    });

    test('should order answered prayers by date answered', () async {
      final prayer1 = await prayerService.createPrayer(
        title: 'First',
        description: 'First prayer',
        category: PrayerCategory.general,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      final prayer2 = await prayerService.createPrayer(
        title: 'Second',
        description: 'Second prayer',
        category: PrayerCategory.general,
      );

      await prayerService.markPrayerAnswered(prayer1.id, 'First answer');
      await Future.delayed(const Duration(milliseconds: 10));
      await prayerService.markPrayerAnswered(prayer2.id, 'Second answer');

      final answered = await prayerService.getAnsweredPrayers();
      expect(answered.first.id, equals(prayer2.id)); // Most recent first
    });
  });

  group('Prayer Queries', () {
    test('should get all prayers', () async {
      await prayerService.createPrayer(
        title: 'Prayer 1',
        description: 'First prayer',
        category: PrayerCategory.general,
      );

      await prayerService.createPrayer(
        title: 'Prayer 2',
        description: 'Second prayer',
        category: PrayerCategory.family,
      );

      final all = await prayerService.getAllPrayers();
      expect(all.length, greaterThanOrEqualTo(2));
    });

    test('should order all prayers by creation date descending', () async {
      final prayer1 = await prayerService.createPrayer(
        title: 'Old Prayer',
        description: 'Created first',
        category: PrayerCategory.general,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      final prayer2 = await prayerService.createPrayer(
        title: 'New Prayer',
        description: 'Created second',
        category: PrayerCategory.general,
      );

      final all = await prayerService.getAllPrayers();
      expect(all.first.id, equals(prayer2.id)); // Most recent first
      expect(all.last.id, equals(prayer1.id));
    });

    test('should get prayer count', () async {
      final initialCount = await prayerService.getPrayerCount();

      await prayerService.createPrayer(
        title: 'Test',
        description: 'Count test',
        category: PrayerCategory.general,
      );

      final newCount = await prayerService.getPrayerCount();
      expect(newCount, equals(initialCount + 1));
    });

    test('should get answered prayer count', () async {
      final prayer1 = await prayerService.createPrayer(
        title: 'Prayer 1',
        description: 'First',
        category: PrayerCategory.general,
      );

      final prayer2 = await prayerService.createPrayer(
        title: 'Prayer 2',
        description: 'Second',
        category: PrayerCategory.general,
      );

      await prayerService.markPrayerAnswered(prayer1.id, 'Answered');

      final count = await prayerService.getAnsweredPrayerCount();
      expect(count, equals(1));
    });

    test('should return empty list when no prayers exist', () async {
      final active = await prayerService.getActivePrayers();
      final answered = await prayerService.getAnsweredPrayers();

      expect(active, isEmpty);
      expect(answered, isEmpty);
    });
  });

  group('Prayer Categories', () {
    test('should handle all prayer categories', () async {
      final categories = PrayerCategory.values;

      for (final category in categories) {
        final prayer = await prayerService.createPrayer(
          title: 'Test ${category.name}',
          description: 'Testing category',
          category: category,
        );

        expect(prayer.category, equals(category));
      }

      final all = await prayerService.getAllPrayers();
      expect(all.length, equals(categories.length));
    });

    test('should preserve category through update', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Test',
        description: 'Test',
        category: PrayerCategory.health,
      );

      final updated = prayer.copyWith(description: 'Updated');
      await prayerService.updatePrayer(updated);

      final prayers = await prayerService.getAllPrayers();
      final found = prayers.firstWhere((p) => p.id == prayer.id);
      expect(found.category, equals(PrayerCategory.health));
    });

    test('should display correct category names', () {
      expect(PrayerCategory.general.displayName, equals('General'));
      expect(PrayerCategory.health.displayName, equals('Health'));
      expect(PrayerCategory.family.displayName, equals('Family'));
      expect(PrayerCategory.work.displayName, equals('Work/Career'));
      expect(PrayerCategory.protection.displayName, equals('Protection'));
      expect(PrayerCategory.guidance.displayName, equals('Guidance'));
      expect(PrayerCategory.gratitude.displayName, equals('Gratitude'));
    });
  });

  group('Prayer Model Serialization', () {
    test('should serialize and deserialize prayer correctly', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Serialization Test',
        description: 'Testing serialization',
        category: PrayerCategory.guidance,
      );

      await prayerService.markPrayerAnswered(prayer.id, 'Test answer');

      final retrieved = await prayerService.getAllPrayers();
      final found = retrieved.firstWhere((p) => p.id == prayer.id);

      expect(found.title, equals(prayer.title));
      expect(found.description, equals(prayer.description));
      expect(found.category, equals(prayer.category));
      expect(found.isAnswered, isTrue);
      expect(found.answerDescription, equals('Test answer'));
    });

    test('should handle null optional fields', () async {
      final prayer = PrayerRequest(
        id: 'null-test',
        title: 'Null Test',
        description: 'Testing nulls',
        category: PrayerCategory.general,
        dateCreated: DateTime.now(),
        isAnswered: false,
        dateAnswered: null,
        answerDescription: null,
      );

      await prayerService.addPrayer(prayer);
      final retrieved = await prayerService.getAllPrayers();
      final found = retrieved.firstWhere((p) => p.id == 'null-test');

      expect(found.dateAnswered, isNull);
      expect(found.answerDescription, isNull);
    });
  });

  group('Edge Cases and Error Handling', () {
    test('should handle empty title and description', () async {
      final prayer = await prayerService.createPrayer(
        title: '',
        description: '',
        category: PrayerCategory.general,
      );

      expect(prayer.title, equals(''));
      expect(prayer.description, equals(''));
    });

    test('should handle very long title and description', () async {
      final longText = 'A' * 1000;
      final prayer = await prayerService.createPrayer(
        title: longText,
        description: longText,
        category: PrayerCategory.general,
      );

      expect(prayer.title, equals(longText));
      expect(prayer.description, equals(longText));
    });

    test('should handle special characters', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Prayer with "quotes" and \'apostrophes\'',
        description: 'Special chars: @#\$%^&*()',
        category: PrayerCategory.general,
      );

      final retrieved = await prayerService.getAllPrayers();
      final found = retrieved.firstWhere((p) => p.id == prayer.id);
      expect(found.title, contains('quotes'));
      expect(found.description, contains('@#\$%'));
    });

    test('should handle multiple updates to same prayer', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Original',
        description: 'Original',
        category: PrayerCategory.general,
      );

      for (int i = 1; i <= 5; i++) {
        final updated = prayer.copyWith(
          title: 'Update $i',
          description: 'Description $i',
        );
        await prayerService.updatePrayer(updated);
      }

      final prayers = await prayerService.getAllPrayers();
      final found = prayers.firstWhere((p) => p.id == prayer.id);
      expect(found.title, equals('Update 5'));
    });

    test('should handle marking already answered prayer as answered again', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Test',
        description: 'Test',
        category: PrayerCategory.general,
      );

      await prayerService.markPrayerAnswered(prayer.id, 'First answer');
      await prayerService.markPrayerAnswered(prayer.id, 'Second answer');

      final answered = await prayerService.getAnsweredPrayers();
      final found = answered.firstWhere((p) => p.id == prayer.id);
      expect(found.answerDescription, equals('Second answer'));
    });

    test('should handle concurrent prayer creation', () async {
      final futures = List.generate(
        10,
        (i) => prayerService.createPrayer(
          title: 'Prayer $i',
          description: 'Description $i',
          category: PrayerCategory.general,
        ),
      );

      final prayers = await Future.wait(futures);
      expect(prayers.length, equals(10));
      
      final allIds = prayers.map((p) => p.id).toSet();
      expect(allIds.length, equals(10)); // All unique IDs
    });
  });

  group('Prayer Statistics', () {
    test('should calculate prayer statistics correctly', () async {
      // Create 5 prayers
      for (int i = 1; i <= 5; i++) {
        await prayerService.createPrayer(
          title: 'Prayer $i',
          description: 'Test prayer',
          category: PrayerCategory.general,
        );
      }

      // Answer 2 of them
      final all = await prayerService.getAllPrayers();
      await prayerService.markPrayerAnswered(all[0].id, 'Answered 1');
      await prayerService.markPrayerAnswered(all[1].id, 'Answered 2');

      expect(await prayerService.getPrayerCount(), equals(5));
      expect(await prayerService.getAnsweredPrayerCount(), equals(2));
      expect((await prayerService.getActivePrayers()).length, equals(3));
    });

    test('should track prayer lifecycle', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Lifecycle Test',
        description: 'Testing full lifecycle',
        category: PrayerCategory.guidance,
      );

      // Initially active
      var active = await prayerService.getActivePrayers();
      expect(active.any((p) => p.id == prayer.id), isTrue);

      // Mark as answered
      await prayerService.markPrayerAnswered(prayer.id, 'Guidance received');

      // Now in answered
      var answered = await prayerService.getAnsweredPrayers();
      expect(answered.any((p) => p.id == prayer.id), isTrue);

      // Not in active anymore
      active = await prayerService.getActivePrayers();
      expect(active.any((p) => p.id == prayer.id), isFalse);
    });
  });
}
