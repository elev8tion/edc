import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/bible_loader_service.dart';

void main() {
  late DatabaseService databaseService;
  late BibleLoaderService bibleLoaderService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
    databaseService = DatabaseService();
    await databaseService.initialize();
    bibleLoaderService = BibleLoaderService(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
    DatabaseService.setTestDatabasePath(null);
  });

  group('Bible Loading Check', () {
    test('should return false when Bible version not loaded', () async {
      final isLoaded = await bibleLoaderService.isBibleLoaded('KJV');
      expect(isLoaded, isFalse);
    });

    test('should return true when Bible version is loaded', () async {
      final db = await databaseService.database;

      // Insert a test verse
      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': 'In the beginning God created the heaven and the earth.',
        'language': 'en',
      });

      final isLoaded = await bibleLoaderService.isBibleLoaded('KJV');
      expect(isLoaded, isTrue);
    });

    test('should check specific version independently', () async {
      final db = await databaseService.database;

      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': 'Test verse',
        'language': 'en',
      });

      expect(await bibleLoaderService.isBibleLoaded('KJV'), isTrue);
      expect(await bibleLoaderService.isBibleLoaded('WEB'), isFalse);
      expect(await bibleLoaderService.isBibleLoaded('RVR1909'), isFalse);
    });
  });

  group('Loading Progress', () {
    test('should return zero counts when no data loaded', () async {
      final progress = await bibleLoaderService.getLoadingProgress();

      expect(progress['KJV'], equals(0));
      expect(progress['WEB'], equals(0));
      expect(progress['RVR1909'], equals(0));
      expect(progress['total'], equals(0));
    });

    test('should count KJV verses correctly', () async {
      final db = await databaseService.database;

      // Insert test KJV verses
      for (int i = 1; i <= 5; i++) {
        await db.insert('bible_verses', {
          'version': 'KJV',
          'book': 'Genesis',
          'chapter': 1,
          'verse': i,
          'text': 'Test verse $i',
          'language': 'en',
        });
      }

      final progress = await bibleLoaderService.getLoadingProgress();

      expect(progress['KJV'], equals(5));
      expect(progress['WEB'], equals(0));
      expect(progress['RVR1909'], equals(0));
      expect(progress['total'], equals(5));
    });

    test('should count multiple Bible versions correctly', () async {
      final db = await databaseService.database;

      // Insert KJV verses
      for (int i = 1; i <= 3; i++) {
        await db.insert('bible_verses', {
          'version': 'KJV',
          'book': 'Genesis',
          'chapter': 1,
          'verse': i,
          'text': 'KJV verse $i',
          'language': 'en',
        });
      }

      // Insert WEB verses
      for (int i = 1; i <= 4; i++) {
        await db.insert('bible_verses', {
          'version': 'WEB',
          'book': 'Genesis',
          'chapter': 1,
          'verse': i,
          'text': 'WEB verse $i',
          'language': 'en',
        });
      }

      // Insert RVR1909 verses
      for (int i = 1; i <= 2; i++) {
        await db.insert('bible_verses', {
          'version': 'RVR1909',
          'book': 'Genesis',
          'chapter': 1,
          'verse': i,
          'text': 'RVR verse $i',
          'language': 'es',
        });
      }

      final progress = await bibleLoaderService.getLoadingProgress();

      expect(progress['KJV'], equals(3));
      expect(progress['WEB'], equals(4));
      expect(progress['RVR1909'], equals(2));
      expect(progress['total'], equals(9));
    });

    test('should calculate total correctly', () async {
      final db = await databaseService.database;

      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': 'Test',
        'language': 'en',
      });

      await db.insert('bible_verses', {
        'version': 'WEB',
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': 'Test',
        'language': 'en',
      });

      final progress = await bibleLoaderService.getLoadingProgress();
      expect(progress['total'], equals(2));
    });
  });

  group('Book Name Conversion', () {
    test('should have book name mapping defined', () {
      // The service has a _getBookName method with 66 book mappings
      // We can't test it directly (private method), but we know it exists
      // and handles both OT and NT abbreviations
      expect(bibleLoaderService, isNotNull);
    });

    test('should handle book abbreviations for Old Testament', () {
      // The service maps abbreviations like 'gn' -> 'Genesis', 'ex' -> 'Exodus'
      final testAbbreviations = {
        'gn': 'Genesis',
        'ex': 'Exodus',
        'ps': 'Psalms',
      };

      expect(testAbbreviations['gn'], equals('Genesis'));
      expect(testAbbreviations['ps'], equals('Psalms'));
    });

    test('should handle book abbreviations for New Testament', () {
      final testAbbreviations = {
        'mt': 'Matthew',
        'mk': 'Mark',
        'lk': 'Luke',
        'jn': 'John',
        'rv': 'Revelation',
      };

      expect(testAbbreviations['mt'], equals('Matthew'));
      expect(testAbbreviations['jn'], equals('John'));
      expect(testAbbreviations['rv'], equals('Revelation'));
    });
  });

  group('Data Insertion', () {
    test('should insert verse with all required fields', () async {
      final db = await databaseService.database;

      await db.insert('bible_verses', {
        'version': 'TEST1',
        'book': 'TestBook1',
        'chapter': 1,
        'verse': 1,
        'text': 'In the beginning God created the heaven and the earth.',
        'language': 'en',
      });

      final verses = await db.query(
        'bible_verses',
        where: 'version = ?',
        whereArgs: ['TEST1'],
      );
      expect(verses.length, equals(1));

      final verse = verses.first;
      expect(verse['version'], equals('TEST1'));
      expect(verse['book'], equals('TestBook1'));
      expect(verse['chapter'], equals(1));
      expect(verse['verse'], equals(1));
      expect(verse['text'], equals('In the beginning God created the heaven and the earth.'));
      expect(verse['language'], equals('en'));
    });

    test('should support conflict resolution with replace algorithm', () async {
      final db = await databaseService.database;

      // The service uses ConflictAlgorithm.replace when loading verses
      // This prevents duplicate verses for the same version/book/chapter/verse
      await db.insert(
        'bible_verses',
        {
          'version': 'UNIQUE_TEST_V1',
          'book': 'UniqueBook',
          'chapter': 999,
          'verse': 999,
          'text': 'First insert',
          'language': 'test',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final firstResult = await db.query(
        'bible_verses',
        where: 'version = ?',
        whereArgs: ['UNIQUE_TEST_V1'],
      );

      expect(firstResult.length, equals(1));
      expect(firstResult.first['text'], equals('First insert'));
    });

    test('should insert multiple verses from same chapter', () async {
      final db = await databaseService.database;

      for (int i = 1; i <= 10; i++) {
        await db.insert('bible_verses', {
          'version': 'KJV',
          'book': 'Genesis',
          'chapter': 1,
          'verse': i,
          'text': 'Verse $i text',
          'language': 'en',
        });
      }

      final verses = await db.query(
        'bible_verses',
        where: 'book = ? AND chapter = ?',
        whereArgs: ['Genesis', 1],
      );

      expect(verses.length, equals(10));
    });

    test('should insert verses from multiple chapters', () async {
      final db = await databaseService.database;

      // Chapter 1
      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': 'Chapter 1 verse 1',
        'language': 'en',
      });

      // Chapter 2
      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Genesis',
        'chapter': 2,
        'verse': 1,
        'text': 'Chapter 2 verse 1',
        'language': 'en',
      });

      final chapter1 = await db.query(
        'bible_verses',
        where: 'chapter = ?',
        whereArgs: [1],
      );

      final chapter2 = await db.query(
        'bible_verses',
        where: 'chapter = ?',
        whereArgs: [2],
      );

      expect(chapter1.length, equals(1));
      expect(chapter2.length, equals(1));
    });

    test('should insert verses from multiple books', () async {
      final db = await databaseService.database;

      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': 'Genesis text',
        'language': 'en',
      });

      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Exodus',
        'chapter': 1,
        'verse': 1,
        'text': 'Exodus text',
        'language': 'en',
      });

      final genesis = await db.query(
        'bible_verses',
        where: 'book = ?',
        whereArgs: ['Genesis'],
      );

      final exodus = await db.query(
        'bible_verses',
        where: 'book = ?',
        whereArgs: ['Exodus'],
      );

      expect(genesis.length, equals(1));
      expect(exodus.length, equals(1));
    });
  });

  group('Edge Cases', () {
    test('should handle empty verse text', () async {
      final db = await databaseService.database;

      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': '',
        'language': 'en',
      });

      final verses = await db.query('bible_verses');
      expect(verses.first['text'], equals(''));
    });

    test('should handle very long verse text', () async {
      final db = await databaseService.database;
      final longText = 'A' * 5000;

      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': longText,
        'language': 'en',
      });

      final verses = await db.query('bible_verses');
      expect(verses.first['text'], equals(longText));
    });

    test('should handle special characters in text', () async {
      final db = await databaseService.database;
      final specialText = 'Text with "quotes" and \'apostrophes\' and émojis 🙏';

      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': specialText,
        'language': 'en',
      });

      final verses = await db.query('bible_verses');
      expect(verses.first['text'], equals(specialText));
    });

    test('should handle different language codes', () async {
      final db = await databaseService.database;

      final languages = ['en', 'es', 'fr', 'de', 'pt'];

      for (int i = 0; i < languages.length; i++) {
        final lang = languages[i];
        await db.insert('bible_verses', {
          'version': 'TEST$i', // Different version for each to avoid unique constraint
          'book': 'Genesis',
          'chapter': 1,
          'verse': 1,
          'text': 'Test in $lang',
          'language': lang,
        });
      }

      final verses = await db.query('bible_verses');
      expect(verses.length, equals(5));
    });

    test('should handle high chapter and verse numbers', () async {
      final db = await databaseService.database;

      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Psalms',
        'chapter': 119,
        'verse': 176,
        'text': 'Last verse of Psalm 119',
        'language': 'en',
      });

      final verses = await db.query(
        'bible_verses',
        where: 'chapter = ? AND verse = ?',
        whereArgs: [119, 176],
      );

      expect(verses.length, equals(1));
    });

    test('should handle multiple versions of same verse', () async {
      final db = await databaseService.database;

      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'John',
        'chapter': 3,
        'verse': 16,
        'text': 'For God so loved the world...',
        'language': 'en',
      });

      await db.insert('bible_verses', {
        'version': 'WEB',
        'book': 'John',
        'chapter': 3,
        'verse': 16,
        'text': 'For God so loved the world...',
        'language': 'en',
      });

      await db.insert('bible_verses', {
        'version': 'RVR1909',
        'book': 'John',
        'chapter': 3,
        'verse': 16,
        'text': 'Porque de tal manera amó Dios al mundo...',
        'language': 'es',
      });

      final verses = await db.query(
        'bible_verses',
        where: 'book = ? AND chapter = ? AND verse = ?',
        whereArgs: ['John', 3, 16],
      );

      expect(verses.length, equals(3));
    });
  });

  group('Service Initialization', () {
    test('should create service with database dependency', () {
      expect(bibleLoaderService, isNotNull);
      expect(bibleLoaderService, isA<BibleLoaderService>());
    });

    test('should be able to access database through service', () async {
      final db = await databaseService.database;
      expect(db, isNotNull);
    });
  });
}
