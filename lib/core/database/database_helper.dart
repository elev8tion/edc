import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'migrations/v1_initial_schema.dart';
import 'migrations/v1_5_add_verse_columns.dart';
import 'migrations/v2_add_indexes.dart';
import 'migrations/v2_populate_verses.dart';

class DatabaseHelper {
  static const String _databaseName = 'everyday_christian.db';
  static const int _databaseVersion = 4;

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  /// Optional test database path (for in-memory testing)
  static String? _testDatabasePath;

  /// Set test database path for testing with in-memory DB
  static void setTestDatabasePath(String? path) {
    _testDatabasePath = path;
    _database = null; // Reset database when changing path
  }

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    String path;

    if (_testDatabasePath != null) {
      // Use test path (e.g., inMemoryDatabasePath)
      path = _testDatabasePath!;
    } else {
      // Use production path
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, _databaseName);
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create all tables using migration scripts
    await V1InitialSchema.up(db);

    if (version >= 2) {
      await V15AddVerseColumns.migrate(db);
      await V2AddIndexes.up(db);
    }

    if (version >= 3) {
      await PopulateVersesMigration.migrate(db);
    }
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2 && newVersion >= 2) {
      await V15AddVerseColumns.migrate(db);
      await V2AddIndexes.up(db);
    }

    if (oldVersion < 3 && newVersion >= 3) {
      await PopulateVersesMigration.migrate(db);
    }
  }

  /// Handle database open
  Future<void> _onOpen(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Delete database (for testing)
  Future<void> deleteDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    if (await File(path).exists()) {
      await File(path).delete();
    }
    _database = null;
  }

  // CRUD Operations for Verses

  /// Insert verse
  Future<int> insertVerse(Map<String, dynamic> verse) async {
    final db = await database;
    return await db.insert('verses', verse, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get verse by ID
  Future<Map<String, dynamic>?> getVerse(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'verses',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Search verses by text or themes
  Future<List<Map<String, dynamic>>> searchVerses({
    String? query,
    List<String>? themes,
    String? translation,
    int? limit,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereClause += 'verses_fts MATCH ?';
      whereArgs.add(query);
    }

    if (themes != null && themes.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += themes.map((theme) => 'themes LIKE ?').join(' OR ');
      whereArgs.addAll(themes.map((theme) => '%"$theme"%'));
    }

    if (translation != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'translation = ?';
      whereArgs.add(translation);
    }

    return await db.query(
      'verses',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'RANDOM()',
      limit: limit,
    );
  }

  /// Get verses by theme
  Future<List<Map<String, dynamic>>> getVersesByTheme(String theme, {int? limit}) async {
    return await searchVerses(themes: [theme], limit: limit);
  }

  /// Get random verse
  Future<Map<String, dynamic>?> getRandomVerse({List<String>? themes}) async {
    final verses = await searchVerses(themes: themes, limit: 1);
    return verses.isNotEmpty ? verses.first : null;
  }

  // CRUD Operations for Chat Messages

  /// Insert chat message
  Future<int> insertChatMessage(Map<String, dynamic> message) async {
    final db = await database;
    return await db.insert('chat_messages', message);
  }

  /// Get chat messages for a session
  Future<List<Map<String, dynamic>>> getChatMessages({
    String? sessionId,
    int? limit,
    int? offset,
  }) async {
    final db = await database;

    return await db.query(
      'chat_messages',
      where: sessionId != null ? 'session_id = ?' : null,
      whereArgs: sessionId != null ? [sessionId] : null,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Delete chat messages older than days
  Future<int> deleteOldChatMessages(int days) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;

    return await db.delete(
      'chat_messages',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate],
    );
  }

  // CRUD Operations for Prayer Requests

  /// Insert prayer request
  Future<int> insertPrayerRequest(Map<String, dynamic> prayer) async {
    final db = await database;
    return await db.insert('prayer_requests', prayer);
  }

  /// Update prayer request
  Future<int> updatePrayerRequest(int id, Map<String, dynamic> prayer) async {
    final db = await database;
    return await db.update(
      'prayer_requests',
      prayer,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get prayer requests
  Future<List<Map<String, dynamic>>> getPrayerRequests({
    String? status,
    String? category,
  }) async {
    final db = await database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (status != null || category != null) {
      List<String> conditions = [];
      whereArgs = [];

      if (status != null) {
        conditions.add('status = ?');
        whereArgs.add(status);
      }

      if (category != null) {
        conditions.add('category = ?');
        whereArgs.add(category);
      }

      whereClause = conditions.join(' AND ');
    }

    return await db.query(
      'prayer_requests',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date_created DESC',
    );
  }

  /// Mark prayer as answered
  Future<int> markPrayerAnswered(int id, String testimony) async {
    final db = await database;
    return await db.update(
      'prayer_requests',
      {
        'status': 'answered',
        'date_answered': DateTime.now().millisecondsSinceEpoch,
        'testimony': testimony,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for User Settings

  /// Set user setting
  Future<void> setSetting(String key, dynamic value) async {
    final db = await database;

    await db.insert(
      'user_settings',
      {
        'key': key,
        'value': value.toString(),
        'type': value.runtimeType.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user setting
  Future<T?> getSetting<T>(String key, {T? defaultValue}) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) return defaultValue;

    final setting = result.first;
    final String value = setting['value'];
    final String type = setting['type'];

    // Convert string back to original type
    switch (type) {
      case 'bool':
        return (value.toLowerCase() == 'true') as T?;
      case 'int':
        return int.tryParse(value) as T?;
      case 'double':
        return double.tryParse(value) as T?;
      case 'String':
      default:
        return value as T?;
    }
  }

  /// Delete setting
  Future<int> deleteSetting(String key) async {
    final db = await database;
    return await db.delete(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // CRUD Operations for Daily Verses

  /// Record daily verse delivery
  Future<int> recordDailyVerse(int verseId, DateTime date, {bool opened = false}) async {
    final db = await database;

    return await db.insert(
      'daily_verses',
      {
        'verse_id': verseId,
        'date_delivered': date.millisecondsSinceEpoch,
        'user_opened': opened ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Mark daily verse as opened
  Future<int> markDailyVerseOpened(int verseId, DateTime date) async {
    final db = await database;

    return await db.update(
      'daily_verses',
      {'user_opened': 1},
      where: 'verse_id = ? AND date_delivered = ?',
      whereArgs: [verseId, date.millisecondsSinceEpoch],
    );
  }

  /// Get daily verse history
  Future<List<Map<String, dynamic>>> getDailyVerseHistory({int? limit}) async {
    final db = await database;

    return await db.rawQuery('''
      SELECT dv.*, v.book, v.chapter, v.verse_number, v.text, v.translation
      FROM daily_verses dv
      JOIN verses v ON dv.verse_id = v.id
      ORDER BY dv.date_delivered DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''');
  }

  /// Get verse streak count
  Future<int> getVerseStreak() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as streak
      FROM daily_verses
      WHERE user_opened = 1
      AND date_delivered >= ?
      ORDER BY date_delivered DESC
    ''', [DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch]);

    return result.first['streak'] as int;
  }

  // Utility Methods

  /// Get database file size
  Future<int> getDatabaseSize() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    File file = File(path);

    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Export database for backup
  Future<String> exportDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String sourcePath = join(documentsDirectory.path, _databaseName);
    String backupPath = join(documentsDirectory.path, 'backup_$_databaseName');

    await File(sourcePath).copy(backupPath);
    return backupPath;
  }
}