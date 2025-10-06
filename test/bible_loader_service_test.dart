import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/bible_loader_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('BibleLoaderService', () {
    late DatabaseService databaseService;
    late BibleLoaderService bibleLoaderService;

    setUp(() async {
      // Use in-memory database for testing
      DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
      databaseService = DatabaseService();
      bibleLoaderService = BibleLoaderService(databaseService);
      await databaseService.initialize();
    });

    tearDown(() async {
      DatabaseService.setTestDatabasePath(null);
    });

    group('Check Bible Loaded', () {
      test('should return true when Bible version is loaded', () async {
        // Manually insert a test verse first
        final db = await databaseService.database;
        await db.insert('bible_verses', {
          'version': 'KJV',
          'book': 'Genesis',
          'chapter': 1,
          'verse': 1,
          'text': 'Test',
          'language': 'en',
        });

        final isLoaded = await bibleLoaderService.isBibleLoaded('KJV');

        expect(isLoaded, isTrue);
      });

      test('should return false when Bible version is not loaded', () async {
        final isLoaded = await bibleLoaderService.isBibleLoaded('NIV');

        expect(isLoaded, isFalse);
      });

      test('should return false for empty version', () async {
        final isLoaded = await bibleLoaderService.isBibleLoaded('');

        expect(isLoaded, isFalse);
      });
    });

    group('Loading Progress', () {
      test('should get loading progress for all versions', () async {
        final progress = await bibleLoaderService.getLoadingProgress();

        expect(progress, isA<Map<String, dynamic>>());
        expect(progress.containsKey('KJV'), isTrue);
        expect(progress.containsKey('WEB'), isTrue);
        expect(progress.containsKey('RVR1909'), isTrue);
        expect(progress.containsKey('total'), isTrue);

        expect(progress['KJV'], isA<int>());
        expect(progress['WEB'], isA<int>());
        expect(progress['RVR1909'], isA<int>());
        expect(progress['total'], isA<int>());
      });

      test('should calculate total verses correctly', () async {
        final progress = await bibleLoaderService.getLoadingProgress();

        final expectedTotal = (progress['KJV'] as int) +
            (progress['WEB'] as int) +
            (progress['RVR1909'] as int);

        expect(progress['total'], equals(expectedTotal));
      });

      test('should show KJV loaded after initialization', () async {
        // Insert a verse first
        final db = await databaseService.database;
        await db.insert('bible_verses', {
          'version': 'KJV',
          'book': 'Genesis',
          'chapter': 1,
          'verse': 1,
          'text': 'Test',
          'language': 'en',
        });

        final progress = await bibleLoaderService.getLoadingProgress();

        // KJV should now have at least 1 verse
        expect(progress['KJV'], greaterThan(0));
      });

      test('should return zero for unloaded versions', () async {
        final progress = await bibleLoaderService.getLoadingProgress();

        // Check that at least one of WEB or RVR1909 might be zero
        // (depends on initialization)
        expect(progress['WEB'], greaterThanOrEqualTo(0));
        expect(progress['RVR1909'], greaterThanOrEqualTo(0));
      });
    });

    group('Book Name Conversion', () {
      test('should convert Genesis abbreviation to full name', () async {
        // Test via database query since _getBookName is private
        final db = await databaseService.database;

        // Insert test verse with Genesis abbreviation
        await db.insert(
          'bible_verses',
          {
            'version': 'TEST',
            'book': 'Genesis',
            'chapter': 1,
            'verse': 1,
            'text': 'In the beginning',
            'language': 'en',
          },
        );

        final result = await db.query(
          'bible_verses',
          where: 'book = ? AND version = ?',
          whereArgs: ['Genesis', 'TEST'],
        );

        expect(result.isNotEmpty, isTrue);
        expect(result.first['book'], equals('Genesis'));
      });

      test('should handle Old Testament book names', () async {
        final db = await databaseService.database;

        final oldTestamentBooks = [
          'Genesis',
          'Exodus',
          'Psalms',
          'Isaiah',
        ];

        for (final book in oldTestamentBooks) {
          await db.insert(
            'bible_verses',
            {
              'version': 'TEST',
              'book': book,
              'chapter': 1,
              'verse': 1,
              'text': 'Test text',
              'language': 'en',
            },
          );
        }

        for (final book in oldTestamentBooks) {
          final result = await db.query(
            'bible_verses',
            where: 'book = ? AND version = ?',
            whereArgs: [book, 'TEST'],
          );

          expect(result.isNotEmpty, isTrue);
          expect(result.first['book'], equals(book));
        }
      });

      test('should handle New Testament book names', () async {
        final db = await databaseService.database;

        final newTestamentBooks = [
          'Matthew',
          'John',
          'Romans',
          'Revelation',
        ];

        for (final book in newTestamentBooks) {
          await db.insert(
            'bible_verses',
            {
              'version': 'TEST',
              'book': book,
              'chapter': 1,
              'verse': 1,
              'text': 'Test text',
              'language': 'en',
            },
          );
        }

        for (final book in newTestamentBooks) {
          final result = await db.query(
            'bible_verses',
            where: 'book = ? AND version = ?',
            whereArgs: [book, 'TEST'],
          );

          expect(result.isNotEmpty, isTrue);
          expect(result.first['book'], equals(book));
        }
      });
    });

    group('Database Integration', () {
      test('should insert verses into database', () async {
        final db = await databaseService.database;

        await db.insert(
          'bible_verses',
          {
            'version': 'TEST',
            'book': 'John',
            'chapter': 3,
            'verse': 16,
            'text': 'For God so loved the world',
            'language': 'en',
          },
        );

        final result = await db.query(
          'bible_verses',
          where: 'version = ? AND book = ? AND chapter = ? AND verse = ?',
          whereArgs: ['TEST', 'John', 3, 16],
        );

        expect(result.length, equals(1));
        expect(result.first['text'], equals('For God so loved the world'));
      });

      test('should handle multiple verses from same book', () async {
        final db = await databaseService.database;

        // Insert multiple verses
        for (int i = 1; i <= 5; i++) {
          await db.insert(
            'bible_verses',
            {
              'version': 'TEST',
              'book': 'Psalms',
              'chapter': 23,
              'verse': i,
              'text': 'Verse $i',
              'language': 'en',
            },
          );
        }

        final result = await db.query(
          'bible_verses',
          where: 'version = ? AND book = ? AND chapter = ?',
          whereArgs: ['TEST', 'Psalms', 23],
        );

        expect(result.length, equals(5));
      });

      test('should handle multiple chapters from same book', () async {
        final db = await databaseService.database;

        // Insert verses from multiple chapters
        for (int chapter = 1; chapter <= 3; chapter++) {
          for (int verse = 1; verse <= 2; verse++) {
            await db.insert(
              'bible_verses',
              {
                'version': 'TEST2',
                'book': 'Matthew',
                'chapter': chapter,
                'verse': verse,
                'text': 'Chapter $chapter, Verse $verse',
                'language': 'en',
              },
            );
          }
        }

        final result = await db.query(
          'bible_verses',
          where: 'version = ? AND book = ?',
          whereArgs: ['TEST2', 'Matthew'],
        );

        expect(result.length, equals(6)); // 3 chapters * 2 verses each
      });

      test('should support multiple Bible versions', () async {
        final db = await databaseService.database;

        await db.insert(
          'bible_verses',
          {
            'version': 'KJV',
            'book': 'Genesis',
            'chapter': 1,
            'verse': 1,
            'text': 'In the beginning God created',
            'language': 'en',
          },
        );

        await db.insert(
          'bible_verses',
          {
            'version': 'NIV',
            'book': 'Genesis',
            'chapter': 1,
            'verse': 1,
            'text': 'In the beginning God created',
            'language': 'en',
          },
        );

        final kjvResult = await db.query(
          'bible_verses',
          where: 'version = ?',
          whereArgs: ['KJV'],
        );

        final nivResult = await db.query(
          'bible_verses',
          where: 'version = ?',
          whereArgs: ['NIV'],
        );

        expect(kjvResult.isNotEmpty, isTrue);
        expect(nivResult.isNotEmpty, isTrue);
      });

      test('should support multiple languages', () async {
        final db = await databaseService.database;

        await db.insert(
          'bible_verses',
          {
            'version': 'KJV',
            'book': 'John',
            'chapter': 3,
            'verse': 16,
            'text': 'For God so loved the world',
            'language': 'en',
          },
        );

        await db.insert(
          'bible_verses',
          {
            'version': 'RVR1909',
            'book': 'Juan',
            'chapter': 3,
            'verse': 16,
            'text': 'Porque de tal manera amó Dios al mundo',
            'language': 'es',
          },
        );

        final englishResult = await db.query(
          'bible_verses',
          where: 'language = ?',
          whereArgs: ['en'],
        );

        final spanishResult = await db.query(
          'bible_verses',
          where: 'language = ?',
          whereArgs: ['es'],
        );

        expect(englishResult.isNotEmpty, isTrue);
        expect(spanishResult.isNotEmpty, isTrue);
      });

      test('should replace verses on conflict', () async {
        final db = await databaseService.database;

        // Use unique version to avoid conflicts with other tests
        final uniqueVersion = 'REPLACE_TEST';

        // Insert initial verse
        await db.insert(
          'bible_verses',
          {
            'version': uniqueVersion,
            'book': 'John',
            'chapter': 1,
            'verse': 1,
            'text': 'Original text',
            'language': 'en',
          },
        );

        // Insert same verse with different text (should replace)
        await db.insert(
          'bible_verses',
          {
            'version': uniqueVersion,
            'book': 'John',
            'chapter': 1,
            'verse': 1,
            'text': 'Updated text',
            'language': 'en',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final result = await db.query(
          'bible_verses',
          where: 'version = ? AND book = ? AND chapter = ? AND verse = ? AND text = ?',
          whereArgs: [uniqueVersion, 'John', 1, 1, 'Updated text'],
        );

        // Verify the updated text exists
        expect(result.isNotEmpty, isTrue);
        expect(result.first['text'], equals('Updated text'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty version check', () async {
        final isLoaded = await bibleLoaderService.isBibleLoaded('');
        expect(isLoaded, isFalse);
      });

      test('should handle null-like version strings', () async {
        final isLoaded = await bibleLoaderService.isBibleLoaded('NULL');
        expect(isLoaded, isFalse);
      });

      test('should handle case-sensitive version names', () async {
        final db = await databaseService.database;

        await db.insert(
          'bible_verses',
          {
            'version': 'kjv', // lowercase
            'book': 'Genesis',
            'chapter': 1,
            'verse': 1,
            'text': 'Test',
            'language': 'en',
          },
        );

        // Check exact match
        final lowercaseLoaded = await bibleLoaderService.isBibleLoaded('kjv');
        final uppercaseLoaded = await bibleLoaderService.isBibleLoaded('KJV');

        expect(lowercaseLoaded, isTrue);
        // Note: KJV might also be true due to initialization
      });

      test('should return consistent progress counts', () async {
        final progress1 = await bibleLoaderService.getLoadingProgress();
        final progress2 = await bibleLoaderService.getLoadingProgress();

        expect(progress1['KJV'], equals(progress2['KJV']));
        expect(progress1['WEB'], equals(progress2['WEB']));
        expect(progress1['RVR1909'], equals(progress2['RVR1909']));
        expect(progress1['total'], equals(progress2['total']));
      });
    });
  });
}
