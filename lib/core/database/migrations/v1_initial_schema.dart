import 'package:sqflite/sqflite.dart';

class V1InitialSchema {
  static Future<void> up(Database db) async {
    // Create verses table
    await db.execute('''
      CREATE TABLE verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse_number INTEGER NOT NULL,
        text TEXT NOT NULL,
        translation TEXT NOT NULL DEFAULT 'ESV',
        themes TEXT, -- JSON array of theme tags
        created_at INTEGER DEFAULT (strftime('%s', 'now') * 1000),
        UNIQUE(book, chapter, verse_number, translation)
      )
    ''');

    // Create FTS5 virtual table for verse search
    await db.execute('''
      CREATE VIRTUAL TABLE verses_fts USING fts5(
        text,
        book,
        themes,
        content='verses',
        content_rowid='id'
      )
    ''');

    // Create trigger to maintain FTS index
    await db.execute('''
      CREATE TRIGGER verses_fts_insert AFTER INSERT ON verses BEGIN
        INSERT INTO verses_fts(rowid, text, book, themes)
        VALUES (new.id, new.text, new.book, new.themes);
      END
    ''');

    await db.execute('''
      CREATE TRIGGER verses_fts_delete AFTER DELETE ON verses BEGIN
        INSERT INTO verses_fts(verses_fts, rowid, text, book, themes)
        VALUES ('delete', old.id, old.text, old.book, old.themes);
      END
    ''');

    await db.execute('''
      CREATE TRIGGER verses_fts_update AFTER UPDATE ON verses BEGIN
        INSERT INTO verses_fts(verses_fts, rowid, text, book, themes)
        VALUES ('delete', old.id, old.text, old.book, old.themes);
        INSERT INTO verses_fts(rowid, text, book, themes)
        VALUES (new.id, new.text, new.book, new.themes);
      END
    ''');

    // Create chat_messages table
    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        user_input TEXT NOT NULL,
        ai_response TEXT NOT NULL,
        verse_references TEXT, -- JSON array of verse IDs
        timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
        is_favorite INTEGER DEFAULT 0,
        shared INTEGER DEFAULT 0
      )
    ''');

    // Create prayer_requests table
    await db.execute('''
      CREATE TABLE prayer_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT, -- personal, family, work, health, etc.
        status TEXT DEFAULT 'active', -- active, answered, archived
        date_created INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
        date_answered INTEGER,
        testimony TEXT, -- testimony of answered prayer
        is_private INTEGER DEFAULT 1,
        reminder_frequency TEXT -- daily, weekly, none
      )
    ''');

    // Create user_settings table
    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        type TEXT NOT NULL, -- bool, int, double, String
        updated_at INTEGER DEFAULT (strftime('%s', 'now') * 1000)
      )
    ''');

    // Create daily_verses table
    await db.execute('''
      CREATE TABLE daily_verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id INTEGER NOT NULL,
        date_delivered INTEGER NOT NULL, -- timestamp of delivery date
        user_opened INTEGER DEFAULT 0, -- 1 if user opened, 0 if not
        notification_sent INTEGER DEFAULT 0,
        FOREIGN KEY (verse_id) REFERENCES verses (id) ON DELETE CASCADE,
        UNIQUE(verse_id, date_delivered)
      )
    ''');

    // Create chat_sessions table for organizing conversations
    await db.execute('''
      CREATE TABLE chat_sessions (
        id TEXT PRIMARY KEY,
        title TEXT,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
        is_archived INTEGER DEFAULT 0,
        message_count INTEGER DEFAULT 0
      )
    ''');

    // Create favorite_verses table for bookmarked verses
    await db.execute('''
      CREATE TABLE favorite_verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id INTEGER NOT NULL,
        note TEXT, -- personal note about the verse
        tags TEXT, -- personal tags JSON array
        date_added INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
        FOREIGN KEY (verse_id) REFERENCES verses (id) ON DELETE CASCADE,
        UNIQUE(verse_id)
      )
    ''');

    // Insert default settings
    await _insertDefaultSettings(db);

    // Insert sample verses
    await _insertSampleVerses(db);
  }

  static Future<void> _insertDefaultSettings(Database db) async {
    final defaultSettings = [
      {'key': 'daily_verse_time', 'value': '09:30', 'type': 'String'},
      {'key': 'daily_verse_enabled', 'value': 'true', 'type': 'bool'},
      {'key': 'preferred_translation', 'value': 'ESV', 'type': 'String'},
      {'key': 'theme_mode', 'value': 'system', 'type': 'String'}, // light, dark, system
      {'key': 'notifications_enabled', 'value': 'true', 'type': 'bool'},
      {'key': 'biometric_enabled', 'value': 'false', 'type': 'bool'},
      {'key': 'onboarding_completed', 'value': 'false', 'type': 'bool'},
      {'key': 'first_launch', 'value': 'true', 'type': 'bool'},
      {'key': 'verse_streak_count', 'value': '0', 'type': 'int'},
      {'key': 'last_verse_date', 'value': '0', 'type': 'int'},
      {'key': 'preferred_verse_themes', 'value': '["hope", "strength", "comfort"]', 'type': 'String'},
      {'key': 'chat_history_days', 'value': '30', 'type': 'int'},
      {'key': 'prayer_reminder_enabled', 'value': 'true', 'type': 'bool'},
      {'key': 'font_size_scale', 'value': '1.0', 'type': 'double'},
    ];

    for (final setting in defaultSettings) {
      await db.insert('user_settings', setting);
    }
  }

  static Future<void> _insertSampleVerses(Database db) async {
    final sampleVerses = [
      {
        'book': 'Jeremiah',
        'chapter': 29,
        'verse_number': 11,
        'text': 'For I know the plans I have for you, declares the Lord, plans for welfare and not for evil, to give you a future and a hope.',
        'translation': 'ESV',
        'themes': '["hope", "future", "guidance", "trust"]'
      },
      {
        'book': 'Philippians',
        'chapter': 4,
        'verse_number': 13,
        'text': 'I can do all things through him who strengthens me.',
        'translation': 'ESV',
        'themes': '["strength", "perseverance", "faith", "encouragement"]'
      },
      {
        'book': 'Isaiah',
        'chapter': 41,
        'verse_number': 10,
        'text': 'Fear not, for I am with you; be not dismayed, for I am your God; I will strengthen you, I will help you, I will uphold you with my righteous right hand.',
        'translation': 'ESV',
        'themes': '["comfort", "fear", "strength", "presence"]'
      },
      {
        'book': 'Psalm',
        'chapter': 23,
        'verse_number': 1,
        'text': 'The Lord is my shepherd; I shall not want.',
        'translation': 'ESV',
        'themes': '["comfort", "provision", "trust", "peace"]'
      },
      {
        'book': 'Romans',
        'chapter': 8,
        'verse_number': 28,
        'text': 'And we know that for those who love God all things work together for good, for those who are called according to his purpose.',
        'translation': 'ESV',
        'themes': '["hope", "purpose", "trust", "guidance"]'
      },
      {
        'book': 'Proverbs',
        'chapter': 3,
        'verse_number': 5,
        'text': 'Trust in the Lord with all your heart, and do not lean on your own understanding.',
        'translation': 'ESV',
        'themes': '["trust", "wisdom", "guidance", "surrender"]'
      },
      {
        'book': 'Matthew',
        'chapter': 11,
        'verse_number': 28,
        'text': 'Come to me, all who labor and are heavy laden, and I will give you rest.',
        'translation': 'ESV',
        'themes': '["rest", "comfort", "burden", "invitation"]'
      },
      {
        'book': '2 Corinthians',
        'chapter': 12,
        'verse_number': 9,
        'text': 'But he said to me, "My grace is sufficient for you, for my power is made perfect in weakness." Therefore I will boast all the more gladly of my weaknesses, so that the power of Christ may rest upon me.',
        'translation': 'ESV',
        'themes': '["grace", "weakness", "strength", "sufficiency"]'
      },
      {
        'book': 'Joshua',
        'chapter': 1,
        'verse_number': 9,
        'text': 'Have I not commanded you? Be strong and courageous. Do not be frightened, and do not be dismayed, for the Lord your God is with you wherever you go.',
        'translation': 'ESV',
        'themes': '["courage", "strength", "presence", "fear"]'
      },
      {
        'book': '1 Peter',
        'chapter': 5,
        'verse_number': 7,
        'text': 'Casting all your anxieties on him, because he cares for you.',
        'translation': 'ESV',
        'themes': '["anxiety", "care", "worry", "trust"]'
      },
      {
        'book': 'Psalm',
        'chapter': 46,
        'verse_number': 10,
        'text': 'Be still, and know that I am God. I will be exalted among the nations, I will be exalted in the earth!',
        'translation': 'ESV',
        'themes': '["peace", "stillness", "trust", "sovereignty"]'
      },
      {
        'book': 'Matthew',
        'chapter': 6,
        'verse_number': 26,
        'text': 'Look at the birds of the air: they neither sow nor reap nor gather into barns, and yet your heavenly Father feeds them. Are you not of more value than they?',
        'translation': 'ESV',
        'themes': '["provision", "worry", "value", "trust"]'
      },
      {
        'book': 'Ephesians',
        'chapter': 2,
        'verse_number': 8,
        'text': 'For by grace you have been saved through faith. And this is not your own doing; it is the gift of God.',
        'translation': 'ESV',
        'themes': '["grace", "salvation", "faith", "gift"]'
      },
      {
        'book': 'Psalm',
        'chapter': 119,
        'verse_number': 105,
        'text': 'Your word is a lamp to my feet and a light to my path.',
        'translation': 'ESV',
        'themes': '["guidance", "wisdom", "scripture", "path"]'
      },
      {
        'book': '1 Corinthians',
        'chapter': 13,
        'verse_number': 4,
        'text': 'Love is patient and kind; love does not envy or boast; it is not arrogant.',
        'translation': 'ESV',
        'themes': '["love", "patience", "kindness", "character"]'
      }
    ];

    for (final verse in sampleVerses) {
      await db.insert('verses', verse);
    }
  }

  static Future<void> down(Database db) async {
    // Drop all tables in reverse order
    await db.execute('DROP TABLE IF EXISTS favorite_verses');
    await db.execute('DROP TABLE IF EXISTS chat_sessions');
    await db.execute('DROP TABLE IF EXISTS daily_verses');
    await db.execute('DROP TABLE IF EXISTS user_settings');
    await db.execute('DROP TABLE IF EXISTS prayer_requests');
    await db.execute('DROP TABLE IF EXISTS chat_messages');
    await db.execute('DROP TABLE IF EXISTS verses_fts');
    await db.execute('DROP TABLE IF EXISTS verses');
  }
}