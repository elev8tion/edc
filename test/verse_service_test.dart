import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/database/database_helper.dart';
import 'package:everyday_christian/services/verse_service.dart';
import 'package:everyday_christian/models/bible_verse.dart';

void main() {
  late VerseService verseService;
  late DatabaseHelper dbHelper;

  setUpAll(() async {
    // Initialize Flutter bindings for asset loading (rootBundle) and platform channels
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize sqflite for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Use in-memory database for testing (no file system, no path_provider needed)
    DatabaseHelper.setTestDatabasePath(inMemoryDatabasePath);
  });

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    verseService = VerseService();

    // Reset database for clean test start
    DatabaseHelper.setTestDatabasePath(inMemoryDatabasePath);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('Verse Service Tests', () {
    test('Database populates with verses on first access', () async {
      // Access database to trigger migrations
      await dbHelper.database;

      // Verify verses were populated
      final stats = await verseService.getVerseStats();
      expect(stats['total_verses'], greaterThan(20)); // Should have 30+ verses after population
    });

    test('Search verses returns relevant results', () async {
      await dbHelper.database; // Trigger population

      final results = await verseService.searchVerses('strength');
      expect(results, isNotEmpty);

      // Check that results contain strength-related verses
      final hasStrengthVerse = results.any((verse) =>
        verse['text'].toString().toLowerCase().contains('strength') ||
        verse['themes'].toString().toLowerCase().contains('strength')
      );
      expect(hasStrengthVerse, isTrue);
    });

    test('Get verses by theme works correctly', () async {
      await dbHelper.database; // Trigger population

      final comfortVerses = await verseService.getVersesByTheme('comfort');
      expect(comfortVerses, isNotEmpty);

      // Convert to BibleVerse objects and check themes
      final verses = comfortVerses.map((v) => BibleVerse.fromMap(v)).toList();
      final hasComfortTheme = verses.any((verse) => verse.hasTheme('comfort'));
      expect(hasComfortTheme, isTrue);
    });

    test('Get daily verse returns a random verse', () async {
      await dbHelper.database; // Trigger population

      final dailyVerse = await verseService.getDailyVerse();
      expect(dailyVerse, isNotNull);
      expect(dailyVerse!['text'], isNotEmpty);
      expect(dailyVerse['reference'], isNotEmpty);
    });

    test('Get verses for specific situations', () async {
      await dbHelper.database; // Trigger population

      final anxietyVerses = await verseService.getVersesForSituation('anxiety');
      expect(anxietyVerses, isNotEmpty);

      // Should return peace/comfort themed verses for anxiety
      final verses = anxietyVerses.map((v) => BibleVerse.fromMap(v)).toList();
      final hasRelevantTheme = verses.any((verse) =>
        verse.hasTheme('peace') ||
        verse.hasTheme('comfort') ||
        verse.hasTheme('trust')
      );
      expect(hasRelevantTheme, isTrue);
    });

    test('Get all themes returns expected themes', () async {
      await dbHelper.database; // Trigger population

      final themes = await verseService.getAllThemes();
      expect(themes, contains('hope'));
      expect(themes, contains('strength'));
      expect(themes, contains('comfort'));
      expect(themes, contains('peace'));
    });

    test('Get all categories returns expected categories', () async {
      await dbHelper.database; // Trigger population

      final categories = await verseService.getAllCategories();
      expect(categories, contains('comfort'));
      expect(categories, contains('strength'));
      expect(categories, contains('hope'));
    });

    test('Verse search with empty query returns empty results', () async {
      await dbHelper.database; // Trigger population

      final results = await verseService.searchVerses('');
      expect(results, isEmpty);

      final results2 = await verseService.searchVerses('   ');
      expect(results2, isEmpty);
    });

    test('Get verse by reference works correctly', () async {
      await dbHelper.database; // Trigger population

      final verse = await verseService.getVerseByReference('John 3:16');
      if (verse != null) {
        expect(verse['reference'], equals('John 3:16'));
        expect(verse['text'], isNotEmpty);
      }
    });

    test('BibleVerse model handles JSON conversion correctly', () {
      const verse = BibleVerse(
        id: 1,
        book: 'John',
        chapter: 3,
        verseNumber: 16,
        text: 'For God so loved the world...',
        translation: 'ESV',
        reference: 'John 3:16',
        themes: ['love', 'salvation'],
        category: 'salvation',
      );

      final json = verse.toJson();
      final reconstructed = BibleVerse.fromJson(json);

      expect(reconstructed.book, equals(verse.book));
      expect(reconstructed.chapter, equals(verse.chapter));
      expect(reconstructed.verseNumber, equals(verse.verseNumber));
      expect(reconstructed.themes, equals(verse.themes));
    });

    test('BibleVerse model properties work correctly', () {
      const verse = BibleVerse(
        book: 'Psalm',
        chapter: 23,
        verseNumber: 1,
        text: 'The Lord is my shepherd; I shall not want.',
        translation: 'ESV',
        reference: 'Psalm 23:1',
        themes: ['comfort', 'trust'],
        category: 'comfort',
      );

      expect(verse.displayReference, equals('Psalm 23:1'));
      expect(verse.shortReference, equals('23:1'));
      expect(verse.hasTheme('comfort'), isTrue);
      expect(verse.hasTheme('nonexistent'), isFalse);
      expect(verse.primaryTheme, equals('comfort'));
      expect(verse.length, equals(VerseLength.short));
    });
  });
}