import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/prayer_request.dart';
import '../models/bible_verse.dart';
import '../models/devotional.dart';
import '../models/reading_plan.dart';
import '../database/migrations/v6_add_prayer_categories.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'everyday_christian.db';
  static const int _databaseVersion = 6;

  /// Optional test database path (for in-memory testing)
  static String? _testDatabasePath;

  /// Set test database path for testing with in-memory DB
  static void setTestDatabasePath(String? path) {
    _testDatabasePath = path;
    _database = null; // Reset database when changing path
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;

    if (_testDatabasePath != null) {
      // Use test path (e.g., inMemoryDatabasePath)
      path = _testDatabasePath!;
    } else {
      // Use production path
      final documentsDirectory = await getDatabasesPath();
      path = join(documentsDirectory, _databaseName);
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add missing columns for reading plan progress
      await db.execute('ALTER TABLE reading_plans ADD COLUMN start_date INTEGER');
      await db.execute('ALTER TABLE daily_readings ADD COLUMN completed_date INTEGER');
    }

    if (oldVersion < 3) {
      // Add completed_date column for devotional progress tracking
      await db.execute('ALTER TABLE devotionals ADD COLUMN completed_date INTEGER');

      // Add prayer streak activity table
      await db.execute('''
        CREATE TABLE prayer_streak_activity (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          activity_date INTEGER NOT NULL UNIQUE,
          created_at INTEGER NOT NULL
        )
      ''');

      // Create index for fast date lookups
      await db.execute('''
        CREATE INDEX idx_prayer_activity_date ON prayer_streak_activity(activity_date)
      ''');
    }

    if (oldVersion < 4) {
      // Create FTS5 virtual table for full-text search
      await db.execute('''
        CREATE VIRTUAL TABLE bible_verses_fts USING fts5(
          book,
          chapter,
          verse,
          text,
          content=bible_verses,
          content_rowid=id
        )
      ''');

      // Populate FTS table with existing data
      await db.execute('''
        INSERT INTO bible_verses_fts(rowid, book, chapter, verse, text)
        SELECT id, book, chapter, verse, text FROM bible_verses
      ''');

      // Create triggers to keep FTS in sync with main table
      await db.execute('''
        CREATE TRIGGER bible_verses_ai AFTER INSERT ON bible_verses BEGIN
          INSERT INTO bible_verses_fts(rowid, book, chapter, verse, text)
          VALUES (new.id, new.book, new.chapter, new.verse, new.text);
        END
      ''');

      await db.execute('''
        CREATE TRIGGER bible_verses_ad AFTER DELETE ON bible_verses BEGIN
          DELETE FROM bible_verses_fts WHERE rowid = old.id;
        END
      ''');

      await db.execute('''
        CREATE TRIGGER bible_verses_au AFTER UPDATE ON bible_verses BEGIN
          DELETE FROM bible_verses_fts WHERE rowid = old.id;
          INSERT INTO bible_verses_fts(rowid, book, chapter, verse, text)
          VALUES (new.id, new.book, new.chapter, new.verse, new.text);
        END
      ''');

      // Create bookmarks table for user-saved verses
      await db.execute('''
        CREATE TABLE verse_bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          verse_id INTEGER NOT NULL,
          note TEXT,
          tags TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY (verse_id) REFERENCES bible_verses (id),
          UNIQUE(verse_id)
        )
      ''');

      // Create index for fast bookmark lookups
      await db.execute('''
        CREATE INDEX idx_bookmarks_created ON verse_bookmarks(created_at DESC)
      ''');

      // Create search history table
      await db.execute('''
        CREATE TABLE search_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          query TEXT NOT NULL,
          search_type TEXT NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');

      // Create index for recent searches
      await db.execute('''
        CREATE INDEX idx_search_history ON search_history(created_at DESC)
      ''');
    }

    if (oldVersion < 5) {
      // Daily verse history tracking
      await db.execute('''
        CREATE TABLE daily_verse_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          verse_id INTEGER NOT NULL,
          shown_date INTEGER NOT NULL,
          theme TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (verse_id) REFERENCES bible_verses (id),
          UNIQUE(verse_id, shown_date)
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_daily_verse_date ON daily_verse_history(shown_date DESC)
      ''');

      // User verse preferences
      await db.execute('''
        CREATE TABLE verse_preferences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          preference_key TEXT NOT NULL UNIQUE,
          preference_value TEXT NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // Insert default preferences
      await db.insert('verse_preferences', {
        'preference_key': 'preferred_themes',
        'preference_value': 'faith,hope,love,peace,strength',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('verse_preferences', {
        'preference_key': 'avoid_recent_days',
        'preference_value': '30',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('verse_preferences', {
        'preference_key': 'preferred_version',
        'preference_value': 'WEB',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    }

    if (oldVersion < 6) {
      // Add prayer categories
      await V6AddPrayerCategories.up(db);
    }
  }

  Future<void> _createTables(Database db) async {
    // Prayer Requests table
    await db.execute('''
      CREATE TABLE prayer_requests (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        date_created INTEGER NOT NULL,
        is_answered INTEGER NOT NULL DEFAULT 0,
        date_answered INTEGER,
        answer_description TEXT
      )
    ''');

    // Bible Verses table - Full Bible storage
    await db.execute('''
      CREATE TABLE bible_verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        version TEXT NOT NULL,
        book TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        text TEXT NOT NULL,
        language TEXT NOT NULL
      )
    ''');

    // Create indexes for fast Bible searches
    await db.execute('''
      CREATE INDEX idx_bible_version ON bible_verses(version)
    ''');

    await db.execute('''
      CREATE INDEX idx_bible_book_chapter ON bible_verses(book, chapter)
    ''');

    await db.execute('''
      CREATE INDEX idx_bible_search ON bible_verses(book, chapter, verse)
    ''');

    // Favorite Verses table (separate from main Bible)
    await db.execute('''
      CREATE TABLE favorite_verses (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        reference TEXT NOT NULL,
        category TEXT NOT NULL,
        date_added INTEGER NOT NULL
      )
    ''');

    // Devotionals table
    await db.execute('''
      CREATE TABLE devotionals (
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

    // Reading Plans table
    await db.execute('''
      CREATE TABLE reading_plans (
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

    // Daily Readings table
    await db.execute('''
      CREATE TABLE daily_readings (
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

    // Prayer Streak Activity table
    await db.execute('''
      CREATE TABLE prayer_streak_activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_date INTEGER NOT NULL UNIQUE,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create index for fast date lookups
    await db.execute('''
      CREATE INDEX idx_prayer_activity_date ON prayer_streak_activity(activity_date)
    ''');

    // FTS5 virtual table for full-text search (v4)
    await db.execute('''
      CREATE VIRTUAL TABLE bible_verses_fts USING fts5(
        book,
        chapter,
        verse,
        text,
        content=bible_verses,
        content_rowid=id
      )
    ''');

    // Bookmarks table (v4)
    await db.execute('''
      CREATE TABLE verse_bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id INTEGER NOT NULL,
        note TEXT,
        tags TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (verse_id) REFERENCES bible_verses (id),
        UNIQUE(verse_id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_bookmarks_created ON verse_bookmarks(created_at DESC)
    ''');

    // Search history table (v4)
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        search_type TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_search_history ON search_history(created_at DESC)
    ''');

    // Create triggers to keep FTS in sync (v4)
    await db.execute('''
      CREATE TRIGGER bible_verses_ai AFTER INSERT ON bible_verses BEGIN
        INSERT INTO bible_verses_fts(rowid, book, chapter, verse, text)
        VALUES (new.id, new.book, new.chapter, new.verse, new.text);
      END
    ''');

    await db.execute('''
      CREATE TRIGGER bible_verses_ad AFTER DELETE ON bible_verses BEGIN
        DELETE FROM bible_verses_fts WHERE rowid = old.id;
      END
    ''');

    await db.execute('''
      CREATE TRIGGER bible_verses_au AFTER UPDATE ON bible_verses BEGIN
        DELETE FROM bible_verses_fts WHERE rowid = old.id;
        INSERT INTO bible_verses_fts(rowid, book, chapter, verse, text)
        VALUES (new.id, new.book, new.chapter, new.verse, new.text);
      END
    ''');

    // Daily verse history table (v5)
    await db.execute('''
      CREATE TABLE daily_verse_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id INTEGER NOT NULL,
        shown_date INTEGER NOT NULL,
        theme TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (verse_id) REFERENCES bible_verses (id),
        UNIQUE(verse_id, shown_date)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_daily_verse_date ON daily_verse_history(shown_date DESC)
    ''');

    // Verse preferences table (v5)
    await db.execute('''
      CREATE TABLE verse_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preference_key TEXT NOT NULL UNIQUE,
        preference_value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Prayer categories table (v6)
    await V6AddPrayerCategories.up(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Insert sample favorite verses
    final favorites = [
      {
        'id': '1',
        'text': 'For I know the plans I have for you, declares the Lord, plans for welfare and not for evil, to give you a future and a hope.',
        'reference': 'Jeremiah 29:11',
        'category': 'Hope',
        'date_added': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': '2',
        'text': 'Trust in the Lord with all your heart, and do not lean on your own understanding.',
        'reference': 'Proverbs 3:5',
        'category': 'Faith',
        'date_added': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    for (final verse in favorites) {
      await db.insert('favorite_verses', verse);
    }

    // Devotionals are loaded separately by DevotionalContentLoader

    // Insert sample reading plans
    final readingPlans = [
      {
        'id': '1',
        'title': 'Bible in a Year',
        'description': 'Read the entire Bible in 365 days with daily readings',
        'duration': '365 days',
        'category': 'completeBible',
        'difficulty': 'intermediate',
        'estimated_time_per_day': '15-20 minutes',
        'total_readings': 365,
        'completed_readings': 0,
        'is_started': 0,
      },
    ];

    for (final plan in readingPlans) {
      await db.insert('reading_plans', plan);
    }

    // Insert default verse preferences (v5)
    final versePreferences = [
      {
        'preference_key': 'preferred_themes',
        'preference_value': 'faith,hope,love,peace,strength',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'preference_key': 'avoid_recent_days',
        'preference_value': '30',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'preference_key': 'preferred_version',
        'preference_value': 'WEB',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    for (final pref in versePreferences) {
      await db.insert('verse_preferences', pref);
    }
  }

  Future<void> initialize() async {
    await database;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Reset database - delete and recreate with latest schema
  Future<void> resetDatabase() async {
    // Close existing connection
    await close();

    if (_testDatabasePath != null) {
      // For in-memory databases, just closing and nulling is enough
      // The next access will create a fresh in-memory database
      _database = null;
    } else {
      // For file-based databases, delete the file
      final documentsDirectory = await getDatabasesPath();
      final path = join(documentsDirectory, _databaseName);
      await deleteDatabase(path);
    }

    // Reinitialize with latest schema
    await database;

    print('✅ Database reset complete - all tables recreated with latest schema');
  }
}