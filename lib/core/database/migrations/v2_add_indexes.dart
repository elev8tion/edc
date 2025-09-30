import 'package:sqflite/sqflite.dart';

class V2AddIndexes {
  static Future<void> up(Database db) async {
    // Add performance indexes for frequently queried columns

    // Verses table indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_verses_book_chapter ON verses(book, chapter)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_verses_translation ON verses(translation)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_verses_themes ON verses(themes)');

    // Chat messages indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_chat_messages_session ON chat_messages(session_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_chat_messages_timestamp ON chat_messages(timestamp DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_chat_messages_favorite ON chat_messages(is_favorite)');

    // Prayer requests indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_prayer_requests_status ON prayer_requests(status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_prayer_requests_category ON prayer_requests(category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_prayer_requests_date ON prayer_requests(date_created DESC)');

    // Daily verses indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_daily_verses_date ON daily_verses(date_delivered DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_daily_verses_opened ON daily_verses(user_opened)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_daily_verses_verse_date ON daily_verses(verse_id, date_delivered)');

    // Chat sessions indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_chat_sessions_updated ON chat_sessions(updated_at DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_chat_sessions_archived ON chat_sessions(is_archived)');

    // Favorite verses indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_favorite_verses_date ON favorite_verses(date_added DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_favorite_verses_verse ON favorite_verses(verse_id)');

    // User settings index
    await db.execute('CREATE INDEX IF NOT EXISTS idx_user_settings_key ON user_settings(key)');

    // Add compound indexes for common query patterns

    // Daily verse streak queries
    await db.execute('CREATE INDEX IF NOT EXISTS idx_daily_verses_streak ON daily_verses(user_opened, date_delivered DESC)');

    // Chat message search by session and timestamp
    await db.execute('CREATE INDEX IF NOT EXISTS idx_chat_session_time ON chat_messages(session_id, timestamp DESC)');

    // Prayer requests by status and date
    await db.execute('CREATE INDEX IF NOT EXISTS idx_prayer_status_date ON prayer_requests(status, date_created DESC)');

    // Verse search optimization (themes + translation)
    await db.execute('CREATE INDEX IF NOT EXISTS idx_verses_themes_translation ON verses(themes, translation)');
  }

  static Future<void> down(Database db) async {
    // Drop all indexes
    await db.execute('DROP INDEX IF EXISTS idx_verses_book_chapter');
    await db.execute('DROP INDEX IF EXISTS idx_verses_translation');
    await db.execute('DROP INDEX IF EXISTS idx_verses_themes');
    await db.execute('DROP INDEX IF EXISTS idx_chat_messages_session');
    await db.execute('DROP INDEX IF EXISTS idx_chat_messages_timestamp');
    await db.execute('DROP INDEX IF EXISTS idx_chat_messages_favorite');
    await db.execute('DROP INDEX IF EXISTS idx_prayer_requests_status');
    await db.execute('DROP INDEX IF EXISTS idx_prayer_requests_category');
    await db.execute('DROP INDEX IF EXISTS idx_prayer_requests_date');
    await db.execute('DROP INDEX IF EXISTS idx_daily_verses_date');
    await db.execute('DROP INDEX IF EXISTS idx_daily_verses_opened');
    await db.execute('DROP INDEX IF EXISTS idx_daily_verses_verse_date');
    await db.execute('DROP INDEX IF EXISTS idx_chat_sessions_updated');
    await db.execute('DROP INDEX IF EXISTS idx_chat_sessions_archived');
    await db.execute('DROP INDEX IF EXISTS idx_favorite_verses_date');
    await db.execute('DROP INDEX IF EXISTS idx_favorite_verses_verse');
    await db.execute('DROP INDEX IF EXISTS idx_user_settings_key');
    await db.execute('DROP INDEX IF EXISTS idx_daily_verses_streak');
    await db.execute('DROP INDEX IF EXISTS idx_chat_session_time');
    await db.execute('DROP INDEX IF EXISTS idx_prayer_status_date');
    await db.execute('DROP INDEX IF EXISTS idx_verses_themes_translation');
  }
}