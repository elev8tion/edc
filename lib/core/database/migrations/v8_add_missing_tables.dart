import 'package:sqflite/sqflite.dart';

/// Migration v8: Add missing tables for Prayer Categories, Devotionals, and Reading Plans
///
/// This migration adds:
/// - prayer_categories table with 11 default categories
/// - devotionals table for daily devotional content
/// - reading_plans table for Bible reading plans
/// - daily_readings table for reading plan details
/// - is_answered column to prayer_requests (if not exists)
class V8AddMissingTables {
  static Future<void> up(Database db) async {
    // 1. Add is_answered column to prayer_requests if it doesn't exist
    final hasIsAnswered = await _checkColumnExists(db, 'prayer_requests', 'is_answered');
    if (!hasIsAnswered) {
      await db.execute('ALTER TABLE prayer_requests ADD COLUMN is_answered INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE prayer_requests ADD COLUMN date_answered INTEGER');
      await db.execute('ALTER TABLE prayer_requests ADD COLUMN answer_description TEXT');
    }

    // 2. Create prayer_categories table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS prayer_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        display_order INTEGER NOT NULL DEFAULT 0,
        date_created INTEGER NOT NULL,
        date_modified INTEGER
      )
    ''');

    // Insert default prayer categories
    await _insertDefaultCategories(db);

    // 3. Create devotionals table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS devotionals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        content TEXT NOT NULL,
        verse TEXT NOT NULL,
        verse_reference TEXT NOT NULL,
        date INTEGER NOT NULL,
        reading_time TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_date INTEGER
      )
    ''');

    // 4. Create reading_plans table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reading_plans (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        duration TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        estimated_time_per_day TEXT NOT NULL,
        total_readings INTEGER NOT NULL,
        completed_readings INTEGER NOT NULL DEFAULT 0,
        is_started INTEGER NOT NULL DEFAULT 0,
        start_date INTEGER
      )
    ''');

    // 5. Create daily_readings table (required by reading_plans)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_readings (
        id TEXT PRIMARY KEY,
        plan_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        book TEXT NOT NULL,
        chapters TEXT NOT NULL,
        estimated_time TEXT NOT NULL,
        date INTEGER NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_date INTEGER,
        FOREIGN KEY (plan_id) REFERENCES reading_plans (id)
      )
    ''');

    // Create indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_prayer_categories_active
      ON prayer_categories(is_active, display_order)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_prayer_requests_category
      ON prayer_requests(category)
    ''');

    print('✅ v8 migration: Added missing tables (prayer_categories, devotionals, reading_plans)');
  }

  static Future<bool> _checkColumnExists(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((column) => column['name'] == columnName);
  }

  static Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final defaultCategories = [
      {
        'id': 'cat_family',
        'name': 'Family',
        'icon': '0xe491', // Icons.family_restroom
        'color': '0xFFE91E63', // Colors.pink
        'is_default': 1,
        'is_active': 1,
        'display_order': 1,
        'date_created': now,
      },
      {
        'id': 'cat_health',
        'name': 'Health',
        'icon': '0xe3d0', // Icons.favorite
        'color': '0xFFE53935', // Colors.red
        'is_default': 1,
        'is_active': 1,
        'display_order': 2,
        'date_created': now,
      },
      {
        'id': 'cat_work',
        'name': 'Work',
        'icon': '0xe156', // Icons.work
        'color': '0xFF1976D2', // Colors.blue
        'is_default': 1,
        'is_active': 1,
        'display_order': 3,
        'date_created': now,
      },
      {
        'id': 'cat_ministry',
        'name': 'Ministry',
        'icon': '0xe1a7', // Icons.church
        'color': '0xFF7B1FA2', // Colors.purple
        'is_default': 1,
        'is_active': 1,
        'display_order': 4,
        'date_created': now,
      },
      {
        'id': 'cat_thanksgiving',
        'name': 'Thanksgiving',
        'icon': '0xe8dc', // Icons.celebration
        'color': '0xFFFFA000', // Colors.amber
        'is_default': 1,
        'is_active': 1,
        'display_order': 5,
        'date_created': now,
      },
      {
        'id': 'cat_intercession',
        'name': 'Intercession',
        'icon': '0xe7f4', // Icons.people
        'color': '0xFF00897B', // Colors.teal
        'is_default': 1,
        'is_active': 1,
        'display_order': 6,
        'date_created': now,
      },
      {
        'id': 'cat_finances',
        'name': 'Finances',
        'icon': '0xe227', // Icons.attach_money
        'color': '0xFF388E3C', // Colors.green
        'is_default': 1,
        'is_active': 1,
        'display_order': 7,
        'date_created': now,
      },
      {
        'id': 'cat_relationships',
        'name': 'Relationships',
        'icon': '0xe87d', // Icons.favorite_border
        'color': '0xFFD81B60', // Colors.pinkAccent
        'is_default': 1,
        'is_active': 1,
        'display_order': 8,
        'date_created': now,
      },
      {
        'id': 'cat_guidance',
        'name': 'Guidance',
        'icon': '0xe1a3', // Icons.explore
        'color': '0xFF5E35B1', // Colors.deepPurple
        'is_default': 1,
        'is_active': 1,
        'display_order': 9,
        'date_created': now,
      },
      {
        'id': 'cat_protection',
        'name': 'Protection',
        'icon': '0xe32a', // Icons.shield
        'color': '0xFF6D4C41', // Colors.brown
        'is_default': 1,
        'is_active': 1,
        'display_order': 10,
        'date_created': now,
      },
      {
        'id': 'cat_general',
        'name': 'General',
        'icon': '0xe7ef', // Icons.more_horiz
        'color': '0xFF757575', // Colors.grey
        'is_default': 1,
        'is_active': 1,
        'display_order': 11,
        'date_created': now,
      },
    ];

    for (final category in defaultCategories) {
      await db.insert(
        'prayer_categories',
        category,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<void> down(Database db) async {
    await db.execute('DROP INDEX IF EXISTS idx_prayer_categories_active');
    await db.execute('DROP INDEX IF EXISTS idx_prayer_requests_category');
    await db.execute('DROP TABLE IF EXISTS daily_readings');
    await db.execute('DROP TABLE IF EXISTS reading_plans');
    await db.execute('DROP TABLE IF EXISTS devotionals');
    await db.execute('DROP TABLE IF EXISTS prayer_categories');

    print('✅ v8 migration rolled back');
  }
}
