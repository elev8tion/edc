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
    final maps = await db.query(
      'bible_verses',
      where: 'is_favorite = ?',
      whereArgs: [1],
    );
    return maps.map((map) => _verseFromMap(map)).toList();
  }

  Future<List<BibleVerse>> getVersesByCategory(VerseCategory category) async {
    final db = await _database.database;
    final maps = await db.query(
      'bible_verses',
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
    final maps = await db.query(
      'bible_verses',
      orderBy: 'RANDOM()',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _verseFromMap(maps.first);
    }
    return null;
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