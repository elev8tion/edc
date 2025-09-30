import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

/// Migration to populate the database with Bible verses from JSON file
class PopulateVersesMigration {
  static const int version = 2;

  /// Execute the migration to populate verses
  static Future<void> migrate(Database db) async {
    print('Running migration v2: Populating Bible verses...');

    try {
      // Load verses from JSON file
      final String versesJson = await rootBundle.loadString('assets/data/bible_verses.json');
      final List<dynamic> versesData = jsonDecode(versesJson);

      // Insert verses into database
      await _insertVerses(db, versesData);

      // Update verse search index
      await _updateSearchIndex(db);

      print('✅ Migration v2 completed: ${versesData.length} verses inserted');
    } catch (e) {
      print('❌ Migration v2 failed: $e');
      rethrow;
    }
  }

  /// Insert verses into the database
  static Future<void> _insertVerses(Database db, List<dynamic> versesData) async {
    final batch = db.batch();

    for (final verseData in versesData) {
      final verse = verseData as Map<String, dynamic>;

      // Create verse reference
      final String reference = '${verse['book']} ${verse['chapter']}:${verse['verse']}';

      // Convert themes list to JSON string
      final String themesJson = jsonEncode(verse['themes'] ?? []);

      batch.insert('verses', {
        'book': verse['book'],
        'chapter': verse['chapter'],
        'verse_number': verse['verse'],
        'text': verse['text'],
        'translation': verse['translation'] ?? 'ESV',
        'reference': reference,
        'themes': themesJson,
        'category': verse['category'] ?? 'general',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }

    await batch.commit(noResult: true);
  }

  /// Update the full-text search index with new verses
  static Future<void> _updateSearchIndex(Database db) async {
    // The FTS table will automatically update through triggers
    // But we can optimize it manually if needed
    await db.execute('INSERT INTO verses_fts(verses_fts) VALUES("optimize")');
  }

  /// Add additional verse batches for comprehensive coverage
  static Future<void> addMoreVerses(Database db) async {
    final List<Map<String, dynamic>> additionalVerses = [
      {
        'book': 'Psalm',
        'chapter': 91,
        'verse': 1,
        'text': 'He who dwells in the shelter of the Most High will abide in the shadow of the Almighty.',
        'translation': 'ESV',
        'themes': ['protection', 'shelter', 'refuge', 'security'],
        'category': 'protection'
      },
      {
        'book': 'Isaiah',
        'chapter': 40,
        'verse': 31,
        'text': 'But they who wait for the Lord shall renew their strength; they shall mount up with wings like eagles; they shall run and not be weary; they shall walk and not faint.',
        'translation': 'ESV',
        'themes': ['strength', 'waiting', 'renewal', 'endurance'],
        'category': 'strength'
      },
      {
        'book': 'Matthew',
        'chapter': 6,
        'verse': 26,
        'text': 'Look at the birds of the air: they neither sow nor reap nor gather into barns, and yet your heavenly Father feeds them. Are you not of more value than they?',
        'translation': 'ESV',
        'themes': ['provision', 'value', 'worry', 'care'],
        'category': 'provision'
      },
      {
        'book': 'Revelation',
        'chapter': 21,
        'verse': 4,
        'text': 'He will wipe away every tear from their eyes, and death shall be no more, neither shall there be mourning, nor crying, nor pain anymore, for the former things have passed away.',
        'translation': 'ESV',
        'themes': ['comfort', 'eternal', 'healing', 'restoration'],
        'category': 'comfort'
      },
      {
        'book': 'Ecclesiastes',
        'chapter': 3,
        'verse': 1,
        'text': 'For everything there is a season, and a time for every matter under heaven.',
        'translation': 'ESV',
        'themes': ['timing', 'seasons', 'wisdom', 'patience'],
        'category': 'wisdom'
      },
      {
        'book': 'Romans',
        'chapter': 12,
        'verse': 2,
        'text': 'Do not be conformed to this world, but be transformed by the renewal of your mind, that by testing you may discern what is the will of God, what is good and acceptable and perfect.',
        'translation': 'ESV',
        'themes': ['transformation', 'mind', 'will', 'discernment'],
        'category': 'transformation'
      },
      {
        'book': '1 Thessalonians',
        'chapter': 5,
        'verse': 16,
        'text': 'Rejoice always, pray without ceasing, give thanks in all circumstances; for this is the will of God in Christ Jesus for you.',
        'translation': 'ESV',
        'themes': ['joy', 'prayer', 'gratitude', 'circumstances'],
        'category': 'gratitude'
      },
      {
        'book': 'Psalm',
        'chapter': 139,
        'verse': 14,
        'text': 'I praise you, for I am fearfully and wonderfully made. Wonderful are your works; my soul knows it very well.',
        'translation': 'ESV',
        'themes': ['identity', 'creation', 'worth', 'uniqueness'],
        'category': 'identity'
      },
      {
        'book': 'John',
        'chapter': 3,
        'verse': 16,
        'text': 'For God so loved the world, that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
        'translation': 'ESV',
        'themes': ['love', 'salvation', 'eternal', 'sacrifice'],
        'category': 'salvation'
      },
      {
        'book': 'Psalm',
        'chapter': 119,
        'verse': 105,
        'text': 'Your word is a lamp to my feet and a light to my path.',
        'translation': 'ESV',
        'themes': ['guidance', 'word', 'direction', 'light'],
        'category': 'guidance'
      }
    ];

    await _insertVerses(db, additionalVerses);
    await _updateSearchIndex(db);
  }

  /// Create thematic verse collections for quick access
  static Future<void> createThematicCollections(Database db) async {
    // Create common theme collections
    final themes = [
      'comfort',
      'strength',
      'hope',
      'guidance',
      'peace',
      'love',
      'faith',
      'courage',
      'purpose',
      'perseverance',
      'protection',
      'provision',
      'wisdom',
      'gratitude',
      'identity',
      'salvation'
    ];

    for (final theme in themes) {
      // Count verses for each theme
      final result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM verses WHERE themes LIKE '%$theme%'"
      );
      final count = result.first['count'] as int;

      print('Theme "$theme": $count verses available');
    }
  }

  /// Verify migration success
  static Future<bool> verify(Database db) async {
    try {
      // Check total verse count
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM verses');
      final count = result.first['count'] as int;

      if (count < 20) {
        print('❌ Verification failed: Expected at least 20 verses, found $count');
        return false;
      }

      // Test FTS search
      final searchResult = await db.rawQuery(
        "SELECT * FROM verses_fts WHERE verses_fts MATCH 'strength' LIMIT 5"
      );

      if (searchResult.isEmpty) {
        print('❌ Verification failed: FTS search not working');
        return false;
      }

      // Test theme filtering
      final themeResult = await db.rawQuery(
        "SELECT * FROM verses WHERE themes LIKE '%hope%' LIMIT 3"
      );

      if (themeResult.isEmpty) {
        print('❌ Verification failed: Theme filtering not working');
        return false;
      }

      print('✅ Migration v2 verification passed: $count verses, FTS working, themes working');
      return true;
    } catch (e) {
      print('❌ Verification failed with error: $e');
      return false;
    }
  }
}