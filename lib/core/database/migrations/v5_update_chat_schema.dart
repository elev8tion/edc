import 'package:sqflite/sqflite.dart';

/// Migration to update chat_messages table to support new ChatMessage model
class V5UpdateChatSchema {
  static Future<void> up(Database db) async {
    // Drop old chat_messages table
    await db.execute('DROP TABLE IF EXISTS chat_messages');

    // Create new chat_messages table with improved schema
    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        status TEXT DEFAULT 'sent',
        verse_references TEXT,
        metadata TEXT,
        user_id TEXT,
        FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for performance
    await db.execute('''
      CREATE INDEX idx_chat_messages_session
      ON chat_messages(session_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_chat_messages_timestamp
      ON chat_messages(timestamp DESC)
    ''');

    // Update chat_sessions table if it exists
    // Add last_message_at and last_message_preview columns
    try {
      await db.execute('''
        ALTER TABLE chat_sessions
        ADD COLUMN last_message_at INTEGER
      ''');
    } catch (e) {
      // Column might already exist
    }

    try {
      await db.execute('''
        ALTER TABLE chat_sessions
        ADD COLUMN last_message_preview TEXT
      ''');
    } catch (e) {
      // Column might already exist
    }
  }

  static Future<void> down(Database db) async {
    // Drop new tables
    await db.execute('DROP TABLE IF EXISTS chat_messages');

    // Recreate old schema
    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        user_input TEXT NOT NULL,
        ai_response TEXT NOT NULL,
        verse_references TEXT,
        timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
        is_favorite INTEGER DEFAULT 0,
        shared INTEGER DEFAULT 0
      )
    ''');
  }
}
