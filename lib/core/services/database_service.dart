import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/prayer_request.dart';
import '../models/bible_verse.dart';
import '../models/devotional.dart';
import '../models/reading_plan.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'everyday_christian.db';
  static const int _databaseVersion = 3;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);

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

    // Insert sample devotionals
    final devotionals = [
      {
        'id': '1',
        'title': 'Walking in Faith',
        'subtitle': 'Trust in God\'s Plan',
        'content': 'Today, let\'s reflect on what it means to truly trust in the Lord...',
        'verse': 'Trust in the Lord with all your heart and lean not on your own understanding.',
        'verse_reference': 'Proverbs 3:5-6',
        'date': DateTime.now().millisecondsSinceEpoch,
        'reading_time': '5 min read',
        'is_completed': 0,
      },
    ];

    for (final devotional in devotionals) {
      await db.insert('devotionals', devotional);
    }

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
}