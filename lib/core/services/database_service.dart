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
  static const int _databaseVersion = 1;

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
    // Handle database upgrades here
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

    // Bible Verses table
    await db.execute('''
      CREATE TABLE bible_verses (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        reference TEXT NOT NULL,
        category TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
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
        is_completed INTEGER NOT NULL DEFAULT 0
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
        is_started INTEGER NOT NULL DEFAULT 0
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
        FOREIGN KEY (plan_id) REFERENCES reading_plans (id)
      )
    ''');
  }

  Future<void> _insertInitialData(Database db) async {
    // Insert sample Bible verses
    final verses = [
      {
        'id': '1',
        'text': 'For I know the plans I have for you, declares the Lord, plans for welfare and not for evil, to give you a future and a hope.',
        'reference': 'Jeremiah 29:11',
        'category': 'Hope',
        'is_favorite': 1,
      },
      {
        'id': '2',
        'text': 'Trust in the Lord with all your heart, and do not lean on your own understanding.',
        'reference': 'Proverbs 3:5',
        'category': 'Faith',
        'is_favorite': 0,
      },
      // Add more verses...
    ];

    for (final verse in verses) {
      await db.insert('bible_verses', verse);
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
        'category': 'Complete Bible',
        'difficulty': 'Intermediate',
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