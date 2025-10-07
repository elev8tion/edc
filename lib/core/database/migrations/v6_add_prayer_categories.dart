import 'package:sqflite/sqflite.dart';

class V6AddPrayerCategories {
  static Future<void> up(Database db) async {
    // Create prayer_categories table for custom user categories
    await db.execute('''
      CREATE TABLE IF NOT EXISTS prayer_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        display_order INTEGER NOT NULL DEFAULT 0,
        date_created INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
        date_modified INTEGER,
        UNIQUE(name)
      )
    ''');

    // Insert default prayer categories
    await _insertDefaultCategories(db);

    // Create index for quick category lookups
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_prayer_categories_active
      ON prayer_categories(is_active, display_order)
    ''');

    // Check if status column exists in prayer_requests before creating index
    final hasStatusColumn = await _checkColumnExists(db, 'prayer_requests', 'status');

    // Only create the index if status column exists
    if (hasStatusColumn) {
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_prayer_requests_category
        ON prayer_requests(category, status)
      ''');
    } else {
      // Create index without status column
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_prayer_requests_category
        ON prayer_requests(category)
      ''');
    }
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
    final defaultCategories = [
      {
        'id': 'cat_family',
        'name': 'Family',
        'icon': '0xe491', // Icons.family_restroom
        'color': '0xFFE91E63', // Colors.pink
        'is_default': 1,
        'is_active': 1,
        'display_order': 1,
      },
      {
        'id': 'cat_health',
        'name': 'Health',
        'icon': '0xe3d0', // Icons.favorite
        'color': '0xFFE53935', // Colors.red
        'is_default': 1,
        'is_active': 1,
        'display_order': 2,
      },
      {
        'id': 'cat_work',
        'name': 'Work',
        'icon': '0xe156', // Icons.work
        'color': '0xFF1976D2', // Colors.blue
        'is_default': 1,
        'is_active': 1,
        'display_order': 3,
      },
      {
        'id': 'cat_ministry',
        'name': 'Ministry',
        'icon': '0xe1a7', // Icons.church
        'color': '0xFF7B1FA2', // Colors.purple
        'is_default': 1,
        'is_active': 1,
        'display_order': 4,
      },
      {
        'id': 'cat_thanksgiving',
        'name': 'Thanksgiving',
        'icon': '0xe8dc', // Icons.celebration
        'color': '0xFFFFA000', // Colors.amber
        'is_default': 1,
        'is_active': 1,
        'display_order': 5,
      },
      {
        'id': 'cat_intercession',
        'name': 'Intercession',
        'icon': '0xe7f4', // Icons.people
        'color': '0xFF00897B', // Colors.teal
        'is_default': 1,
        'is_active': 1,
        'display_order': 6,
      },
      {
        'id': 'cat_finances',
        'name': 'Finances',
        'icon': '0xe227', // Icons.attach_money
        'color': '0xFF388E3C', // Colors.green
        'is_default': 1,
        'is_active': 1,
        'display_order': 7,
      },
      {
        'id': 'cat_relationships',
        'name': 'Relationships',
        'icon': '0xe87d', // Icons.favorite_border
        'color': '0xFFD81B60', // Colors.pinkAccent
        'is_default': 1,
        'is_active': 1,
        'display_order': 8,
      },
      {
        'id': 'cat_guidance',
        'name': 'Guidance',
        'icon': '0xe1a3', // Icons.explore
        'color': '0xFF5E35B1', // Colors.deepPurple
        'is_default': 1,
        'is_active': 1,
        'display_order': 9,
      },
      {
        'id': 'cat_protection',
        'name': 'Protection',
        'icon': '0xe32a', // Icons.shield
        'color': '0xFF6D4C41', // Colors.brown
        'is_default': 1,
        'is_active': 1,
        'display_order': 10,
      },
      {
        'id': 'cat_general',
        'name': 'General',
        'icon': '0xe7ef', // Icons.more_horiz
        'color': '0xFF757575', // Colors.grey
        'is_default': 1,
        'is_active': 1,
        'display_order': 11,
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
    await db.execute('DROP TABLE IF EXISTS prayer_categories');
  }
}
