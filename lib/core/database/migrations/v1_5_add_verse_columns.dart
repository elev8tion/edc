import 'package:sqflite/sqflite.dart';

/// Migration to add missing columns to verses table
class V15AddVerseColumns {
  static const int version = 15; // Version 1.5 (between 1 and 2)

  /// Execute the migration to add missing columns
  static Future<void> migrate(Database db) async {
    print('Running migration v1.5: Adding missing verse columns...');

    try {
      // Add reference column to verses table
      await db.execute('ALTER TABLE verses ADD COLUMN reference TEXT');

      // Add category column to verses table
      await db.execute('ALTER TABLE verses ADD COLUMN category TEXT DEFAULT "general"');

      // Update existing verses to populate reference column
      await _populateReferences(db);

      print('✅ Migration v1.5 completed: Added reference and category columns');
    } catch (e) {
      print('❌ Migration v1.5 failed: $e');
      rethrow;
    }
  }

  /// Populate reference column for existing verses
  static Future<void> _populateReferences(Database db) async {
    // Get all existing verses
    final List<Map<String, dynamic>> verses = await db.query('verses');

    // Update each verse with its reference
    for (final verse in verses) {
      final reference = '${verse['book']} ${verse['chapter']}:${verse['verse_number']}';
      await db.update(
        'verses',
        {'reference': reference},
        where: 'id = ?',
        whereArgs: [verse['id']],
      );
    }

    print('Updated ${verses.length} verses with reference column');
  }

  /// Verify migration success
  static Future<bool> verify(Database db) async {
    try {
      // Check if reference column exists
      final List<Map<String, dynamic>> columns = await db.rawQuery(
        "PRAGMA table_info(verses)"
      );

      bool hasReference = columns.any((col) => col['name'] == 'reference');
      bool hasCategory = columns.any((col) => col['name'] == 'category');

      if (!hasReference || !hasCategory) {
        print('❌ Verification failed: Missing columns - reference: $hasReference, category: $hasCategory');
        return false;
      }

      // Check that existing verses have reference populated
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM verses WHERE reference IS NOT NULL'
      );
      final count = result.first['count'] as int;

      if (count == 0) {
        print('❌ Verification failed: No verses have reference populated');
        return false;
      }

      print('✅ Migration v1.5 verification passed: $count verses with references');
      return true;
    } catch (e) {
      print('❌ Verification failed with error: $e');
      return false;
    }
  }
}