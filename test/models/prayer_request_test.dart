import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/models/prayer_request.dart';

void main() {
  group('PrayerRequest Model', () {
    test('should create PrayerRequest with required fields', () {
      final now = DateTime.now();
      final prayer = PrayerRequest(
        id: '1',
        title: 'Test Prayer',
        description: 'Please pray for...',
        category: PrayerCategory.general,
        dateCreated: now,
      );

      expect(prayer.id, equals('1'));
      expect(prayer.title, equals('Test Prayer'));
      expect(prayer.description, equals('Please pray for...'));
      expect(prayer.category, equals(PrayerCategory.general));
      expect(prayer.dateCreated, equals(now));
      expect(prayer.isAnswered, isFalse);
      expect(prayer.dateAnswered, isNull);
      expect(prayer.answerDescription, isNull);
    });

    test('should create PrayerRequest with all fields', () {
      final created = DateTime.now();
      final answered = created.add(Duration(days: 7));

      final prayer = PrayerRequest(
        id: '1',
        title: 'Test',
        description: 'Test description',
        category: PrayerCategory.health,
        dateCreated: created,
        isAnswered: true,
        dateAnswered: answered,
        answerDescription: 'Prayer answered!',
      );

      expect(prayer.isAnswered, isTrue);
      expect(prayer.dateAnswered, equals(answered));
      expect(prayer.answerDescription, equals('Prayer answered!'));
    });

    test('should serialize to JSON', () {
      final now = DateTime.now();
      final prayer = PrayerRequest(
        id: '1',
        title: 'Test',
        description: 'Description',
        category: PrayerCategory.family,
        dateCreated: now,
        isAnswered: true,
      );

      final json = prayer.toJson();

      expect(json['id'], equals('1'));
      expect(json['title'], equals('Test'));
      expect(json['category'], equals('family'));
      expect(json['isAnswered'], isTrue);
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': '1',
        'title': 'Test Prayer',
        'description': 'Test',
        'category': 'work',
        'dateCreated': DateTime.now().toIso8601String(),
        'isAnswered': false,
      };

      final prayer = PrayerRequest.fromJson(json);

      expect(prayer.id, equals('1'));
      expect(prayer.title, equals('Test Prayer'));
      expect(prayer.category, equals(PrayerCategory.work));
      expect(prayer.isAnswered, isFalse);
    });

    test('should handle copyWith', () {
      final now = DateTime.now();
      final prayer = PrayerRequest(
        id: '1',
        title: 'Original',
        description: 'Original description',
        category: PrayerCategory.general,
        dateCreated: now,
      );

      final updated = prayer.copyWith(
        isAnswered: true,
        answerDescription: 'Answered!',
      );

      expect(updated.id, equals('1'));
      expect(updated.title, equals('Original'));
      expect(updated.isAnswered, isTrue);
      expect(updated.answerDescription, equals('Answered!'));
    });

    test('should support equality', () {
      final now = DateTime.now();
      final prayer1 = PrayerRequest(
        id: '1',
        title: 'Test',
        description: 'Test',
        category: PrayerCategory.general,
        dateCreated: now,
      );

      final prayer2 = PrayerRequest(
        id: '1',
        title: 'Test',
        description: 'Test',
        category: PrayerCategory.general,
        dateCreated: now,
      );

      expect(prayer1, equals(prayer2));
    });
  });

  group('PrayerCategory Enum', () {
    test('should have all categories', () {
      expect(PrayerCategory.values.length, equals(7));
      expect(PrayerCategory.values, contains(PrayerCategory.general));
      expect(PrayerCategory.values, contains(PrayerCategory.health));
      expect(PrayerCategory.values, contains(PrayerCategory.family));
      expect(PrayerCategory.values, contains(PrayerCategory.work));
      expect(PrayerCategory.values, contains(PrayerCategory.protection));
      expect(PrayerCategory.values, contains(PrayerCategory.guidance));
      expect(PrayerCategory.values, contains(PrayerCategory.gratitude));
    });
  });

  group('PrayerCategoryExtension', () {
    test('should return correct display names', () {
      expect(PrayerCategory.general.displayName, equals('General'));
      expect(PrayerCategory.health.displayName, equals('Health'));
      expect(PrayerCategory.family.displayName, equals('Family'));
      expect(PrayerCategory.work.displayName, equals('Work/Career'));
      expect(PrayerCategory.protection.displayName, equals('Protection'));
      expect(PrayerCategory.guidance.displayName, equals('Guidance'));
      expect(PrayerCategory.gratitude.displayName, equals('Gratitude'));
    });
  });
}
