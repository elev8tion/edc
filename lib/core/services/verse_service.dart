import '../models/bible_verse.dart';
import 'database_service.dart';

class VerseService {
  final DatabaseService _database;

  VerseService(this._database);

  Future<List<BibleVerse>> getAllVerses() async {
    final db = await _database.database;
    final maps = await db.query('bible_verses');
    return maps.map((map) => _verseFromMap(map)).toList();
  }

  Future<List<BibleVerse>> getFavoriteVerses() async {
    final db = await _database.database;
    final maps = await db.query('favorite_verses');
    return maps.map((map) => _verseFromMap(map)).toList();
  }

  Future<List<BibleVerse>> getVersesByCategory(VerseCategory category) async {
    final db = await _database.database;
    final maps = await db.query(
      'favorite_verses',
      where: 'category = ?',
      whereArgs: [category.name],
    );
    return maps.map((map) => _verseFromMap(map)).toList();
  }

  Future<List<BibleVerse>> searchVerses(String query) async {
    final db = await _database.database;
    final maps = await db.query(
      'bible_verses',
      where: 'text LIKE ? OR reference LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => _verseFromMap(map)).toList();
  }

  Future<void> toggleFavorite(String verseId) async {
    final db = await _database.database;
    final verse = await db.query(
      'bible_verses',
      where: 'id = ?',
      whereArgs: [verseId],
    );

    if (verse.isNotEmpty) {
      final isFavorite = verse.first['is_favorite'] == 1;
      await db.update(
        'bible_verses',
        {'is_favorite': isFavorite ? 0 : 1},
        where: 'id = ?',
        whereArgs: [verseId],
      );
    }
  }

  Future<BibleVerse?> getVerseOfTheDay() async {
    final db = await _database.database;
    // Get random verse from actual Bible
    final maps = await db.query(
      'bible_verses',
      where: 'version = ?',
      whereArgs: ['KJV'],
      orderBy: 'RANDOM()',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final verse = maps.first;
      return BibleVerse(
        id: verse['id'].toString(),
        text: verse['text'] as String,
        reference: '${verse['book']} ${verse['chapter']}:${verse['verse']}',
        category: VerseCategory.faith,
        isFavorite: false,
      );
    }
    return null;
  }

  /// Get a specific verse by reference (e.g., "John 3:16")
  Future<BibleVerse?> getVerseByReference({
    required String book,
    required int chapter,
    required int verse,
    String version = 'KJV',
  }) async {
    final db = await _database.database;
    final maps = await db.query(
      'bible_verses',
      where: 'version = ? AND book = ? AND chapter = ? AND verse = ?',
      whereArgs: [version, book, chapter, verse],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final result = maps.first;
      return BibleVerse(
        id: result['id'].toString(),
        text: result['text'] as String,
        reference: '$book $chapter:$verse',
        category: VerseCategory.faith,
        isFavorite: false,
      );
    }
    return null;
  }

  /// Search Bible verses by text content
  Future<List<BibleVerse>> searchBibleText(String query, {String version = 'KJV'}) async {
    final db = await _database.database;
    final maps = await db.query(
      'bible_verses',
      where: 'version = ? AND text LIKE ?',
      whereArgs: [version, '%$query%'],
      limit: 50,
    );

    return maps.map((map) {
      return BibleVerse(
        id: map['id'].toString(),
        text: map['text'] as String,
        reference: '${map['book']} ${map['chapter']}:${map['verse']}',
        category: VerseCategory.faith,
        isFavorite: false,
      );
    }).toList();
  }

  /// Get all verses from a chapter
  Future<List<BibleVerse>> getChapter({
    required String book,
    required int chapter,
    String version = 'KJV',
  }) async {
    final db = await _database.database;
    final maps = await db.query(
      'bible_verses',
      where: 'version = ? AND book = ? AND chapter = ?',
      whereArgs: [version, book, chapter],
      orderBy: 'verse ASC',
    );

    return maps.map((map) {
      return BibleVerse(
        id: map['id'].toString(),
        text: map['text'] as String,
        reference: '$book $chapter:${map['verse']}',
        category: VerseCategory.faith,
        isFavorite: false,
      );
    }).toList();
  }

  Future<List<BibleVerse>> getVersesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final db = await _database.database;
    final placeholders = ids.map((_) => '?').join(',');
    final maps = await db.query(
      'bible_verses',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return maps.map((map) => _verseFromMap(map)).toList();
  }

  Future<int> getFavoriteCount() async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bible_verses WHERE is_favorite = 1',
    );
    return result.first['count'] as int;
  }

  BibleVerse _verseFromMap(Map<String, dynamic> map) {
    return BibleVerse(
      id: map['id'],
      text: map['text'],
      reference: map['reference'],
      category: VerseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => VerseCategory.faith,
      ),
      isFavorite: map['is_favorite'] == 1,
      dateAdded: map['date_added'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date_added'])
          : null,
    );
  }

  Map<String, dynamic> _verseToMap(BibleVerse verse) {
    return {
      'id': verse.id,
      'text': verse.text,
      'reference': verse.reference,
      'category': verse.category.name,
      'is_favorite': verse.isFavorite ? 1 : 0,
      'date_added': verse.dateAdded?.millisecondsSinceEpoch,
    };
  }
}