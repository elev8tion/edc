import 'package:sqflite/sqflite.dart';

class V10RenamePrayerContent {
  static Future<void> migrate(Database db) async {
    // Rename 'content' column to 'description' in prayer_requests table
    // SQLite doesn't support RENAME COLUMN directly, so we need to recreate the table

    // Step 1: Create new table with correct schema
    await db.execute('''
      CREATE TABLE prayer_requests_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT,
        status TEXT DEFAULT 'active',
        date_created INTEGER NOT NULL,
        date_answered INTEGER,
        testimony TEXT,
        is_private INTEGER DEFAULT 1,
        reminder_frequency TEXT,
        is_answered INTEGER DEFAULT 0,
        answer_description TEXT,
        grace TEXT,
        need_help TEXT
      )
    ''');

    // Step 2: Copy data from old table to new table
    await db.execute('''
      INSERT INTO prayer_requests_new
      (id, title, description, category, status, date_created, date_answered, testimony, is_private, reminder_frequency)
      SELECT id, title, content, category, status, date_created, date_answered, testimony, is_private, reminder_frequency
      FROM prayer_requests
    ''');

    // Step 3: Drop old table
    await db.execute('DROP TABLE prayer_requests');

    // Step 4: Rename new table to original name
    await db.execute('ALTER TABLE prayer_requests_new RENAME TO prayer_requests');
  }
}
