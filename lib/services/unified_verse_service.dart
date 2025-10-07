import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/bible_verse.dart';

/// Unified service for managing Bible verses with FTS5 search, bookmarks, and themes
class UnifiedVerseService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============================================================================
  // SEARCH METHODS
  // ============================================================================

  /// Search verses by text content using FTS5 full-text search
  Future<List<BibleVerse>> searchVerses(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];

    try {
      final database = await _db.database;

      // Use FTS5 for full-text search with ranking
      final results = await database.rawQuery('''
        SELECT v.*,
               snippet(verses_fts, 0, '<mark>', '</mark>', '...', 32) as snippet,
               rank
        FROM verses_fts
        JOIN verses v ON verses_fts.rowid = v.id
        WHERE verses_fts MATCH ?
        ORDER BY rank
        LIMIT ?
      ''', [query, limit]);

      // Get favorite verse IDs to mark them
      final favoriteIds = await _getFavoriteVerseIds();

      return results.map((map) {
        final isFavorite = favoriteIds.contains(map['id']);
        return BibleVerse.fromMap(map, isFavorite: isFavorite);
      }).toList();
    } catch (e) {
      // Fallback to LIKE search if FTS fails
      return _fallbackSearch(query, limit);
    }
  }

  /// Fallback search using LIKE operator
  Future<List<BibleVerse>> _fallbackSearch(String query, int limit) async {
    final database = await _db.database;

    final results = await database.rawQuery('''
      SELECT * FROM verses
      WHERE text LIKE ? OR book LIKE ? OR themes LIKE ?
      ORDER BY
        CASE
          WHEN text LIKE ? THEN 1
          WHEN book LIKE ? THEN 2
          ELSE 3
        END
      LIMIT ?
    ''', [
      '%$query%', '%$query%', '%$query%',
      '%$query%', '%$query%',
      limit
    ]);

    final favoriteIds = await _getFavoriteVerseIds();

    return results.map((map) {
      final isFavorite = favoriteIds.contains(map['id']);
      return BibleVerse.fromMap(map, isFavorite: isFavorite);
    }).toList();
  }

  /// Search verses by theme
  Future<List<BibleVerse>> searchByTheme(String theme, {int limit = 20}) async {
    final database = await _db.database;

    final results = await database.rawQuery('''
      SELECT * FROM verses
      WHERE themes LIKE ?
      ORDER BY RANDOM()
      LIMIT ?
    ''', ['%"$theme"%', limit]);

    final favoriteIds = await _getFavoriteVerseIds();

    return results.map((map) {
      final isFavorite = favoriteIds.contains(map['id']);
      return BibleVerse.fromMap(map, isFavorite: isFavorite);
    }).toList();
  }

  /// Get all verses (with pagination)
  Future<List<BibleVerse>> getAllVerses({int? limit, int? offset}) async {
    final database = await _db.database;

    String query = 'SELECT * FROM verses ORDER BY book, chapter, verse_number';
    if (limit != null) {
      query += ' LIMIT $limit';
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }

    final results = await database.rawQuery(query);
    final favoriteIds = await _getFavoriteVerseIds();

    return results.map((map) {
      final isFavorite = favoriteIds.contains(map['id']);
      return BibleVerse.fromMap(map, isFavorite: isFavorite);
    }).toList();
  }

  /// Get verse by exact reference (e.g., "John 3:16")
  Future<BibleVerse?> getVerseByReference(String reference) async {
    final database = await _db.database;

    // Parse reference
    final parts = reference.split(' ');
    if (parts.length < 2) return null;

    final book = parts.sublist(0, parts.length - 1).join(' ');
    final chapterVerse = parts.last.split(':');
    if (chapterVerse.length != 2) return null;

    final chapter = int.tryParse(chapterVerse[0]);
    final verse = int.tryParse(chapterVerse[1]);

    if (chapter == null || verse == null) return null;

    final results = await database.query(
      'verses',
      where: 'book = ? AND chapter = ? AND verse_number = ?',
      whereArgs: [book, chapter, verse],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final favoriteIds = await _getFavoriteVerseIds();
    final isFavorite = favoriteIds.contains(results.first['id']);

    return BibleVerse.fromMap(results.first, isFavorite: isFavorite);
  }

  // ============================================================================
  // FAVORITE/BOOKMARK METHODS
  // ============================================================================

  /// Get all favorite verses
  Future<List<BibleVerse>> getFavoriteVerses() async {
    final database = await _db.database;

    final results = await database.rawQuery('''
      SELECT v.*, fv.date_added, fv.note, fv.tags
      FROM verses v
      JOIN favorite_verses fv ON v.id = fv.verse_id
      ORDER BY fv.date_added DESC
    ''');

    return results.map((map) => BibleVerse.fromMap(map, isFavorite: true)).toList();
  }

  /// Add verse to favorites
  Future<void> addToFavorites(int verseId, {String? note, List<String>? tags}) async {
    final database = await _db.database;

    await database.insert(
      'favorite_verses',
      {
        'verse_id': verseId,
        'note': note,
        'tags': tags != null ? jsonEncode(tags) : null,
        'date_added': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove verse from favorites
  Future<void> removeFromFavorites(int verseId) async {
    final database = await _db.database;

    await database.delete(
      'favorite_verses',
      where: 'verse_id = ?',
      whereArgs: [verseId],
    );
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(int verseId) async {
    final isFavorite = await isVerseFavorite(verseId);

    if (isFavorite) {
      await removeFromFavorites(verseId);
      return false;
    } else {
      await addToFavorites(verseId);
      return true;
    }
  }

  /// Check if verse is in favorites
  Future<bool> isVerseFavorite(int verseId) async {
    final database = await _db.database;

    final results = await database.query(
      'favorite_verses',
      where: 'verse_id = ?',
      whereArgs: [verseId],
      limit: 1,
    );

    return results.isNotEmpty;
  }

  /// Get favorite verse IDs (for efficient lookup)
  Future<Set<int>> _getFavoriteVerseIds() async {
    final database = await _db.database;

    final results = await database.query(
      'favorite_verses',
      columns: ['verse_id'],
    );

    return results.map((row) => row['verse_id'] as int).toSet();
  }

  /// Update favorite note or tags
  Future<void> updateFavorite(int verseId, {String? note, List<String>? tags}) async {
    final database = await _db.database;

    final Map<String, dynamic> updates = {};
    if (note != null) updates['note'] = note;
    if (tags != null) updates['tags'] = jsonEncode(tags);

    if (updates.isNotEmpty) {
      await database.update(
        'favorite_verses',
        updates,
        where: 'verse_id = ?',
        whereArgs: [verseId],
      );
    }
  }

  // ============================================================================
  // THEME AND CATEGORY METHODS
  // ============================================================================

  /// Get all available themes from verses
  Future<List<String>> getAllThemes() async {
    final database = await _db.database;

    final results = await database.rawQuery('''
      SELECT DISTINCT themes FROM verses WHERE themes IS NOT NULL
    ''');

    final Set<String> allThemes = {};

    for (final row in results) {
      final themesJson = row['themes'] as String?;
      if (themesJson != null) {
        try {
          final List<dynamic> themes = jsonDecode(themesJson);
          allThemes.addAll(themes.cast<String>());
        } catch (e) {
          // Handle malformed JSON gracefully
          continue;
        }
      }
    }

    final sortedThemes = allThemes.toList()..sort();
    return sortedThemes;
  }

  /// Get verses for specific situation/emotion
  Future<List<BibleVerse>> getVersesForSituation(String situation, {int limit = 10}) async {
    // Map common situations to themes
    final situationThemes = {
      'anxiety': ['peace', 'comfort', 'trust'],
      'depression': ['hope', 'comfort', 'strength'],
      'fear': ['courage', 'strength', 'protection'],
      'loneliness': ['comfort', 'presence', 'love'],
      'doubt': ['faith', 'trust', 'assurance'],
      'anger': ['peace', 'forgiveness', 'patience'],
      'grief': ['comfort', 'hope', 'healing'],
      'stress': ['peace', 'rest', 'trust'],
      'guilt': ['forgiveness', 'grace', 'redemption'],
      'purpose': ['purpose', 'identity', 'calling'],
      'relationships': ['love', 'forgiveness', 'unity'],
      'finances': ['provision', 'trust', 'contentment'],
      'health': ['healing', 'strength', 'peace'],
      'work': ['purpose', 'diligence', 'integrity'],
      'decisions': ['wisdom', 'guidance', 'discernment'],
    };

    final themes = situationThemes[situation.toLowerCase()] ?? [situation];
    final database = await _db.database;

    // Build WHERE clause for multiple themes
    final themeClauses = themes.map((_) => 'themes LIKE ?').join(' OR ');
    final args = themes.map((theme) => '%"$theme"%').toList();

    final results = await database.rawQuery('''
      SELECT * FROM verses
      WHERE $themeClauses
      ORDER BY RANDOM()
      LIMIT ?
    ''', [...args, limit]);

    final favoriteIds = await _getFavoriteVerseIds();

    return results.map((map) {
      final isFavorite = favoriteIds.contains(map['id']);
      return BibleVerse.fromMap(map, isFavorite: isFavorite);
    }).toList();
  }

  /// Get random daily verse
  Future<BibleVerse?> getDailyVerse({String? preferredTheme}) async {
    final database = await _db.database;

    String query = 'SELECT * FROM verses';
    List<dynamic> args = [];

    if (preferredTheme != null && preferredTheme.isNotEmpty) {
      query += ' WHERE themes LIKE ?';
      args.add('%"$preferredTheme"%');
    }

    query += ' ORDER BY RANDOM() LIMIT 1';

    final results = await database.rawQuery(query, args);
    if (results.isEmpty) return null;

    final favoriteIds = await _getFavoriteVerseIds();
    final isFavorite = favoriteIds.contains(results.first['id']);

    return BibleVerse.fromMap(results.first, isFavorite: isFavorite);
  }

  // ============================================================================
  // STATISTICS METHODS
  // ============================================================================

  /// Get verse statistics
  Future<Map<String, dynamic>> getVerseStats() async {
    final database = await _db.database;

    final totalCount = await database.rawQuery('SELECT COUNT(*) as count FROM verses');
    final favoriteCount = await database.rawQuery('SELECT COUNT(*) as count FROM favorite_verses');

    final themeStats = await database.rawQuery('''
      SELECT themes FROM verses WHERE themes IS NOT NULL
    ''');

    // Count theme occurrences
    final Map<String, int> themeCounts = {};
    for (final row in themeStats) {
      final themesJson = row['themes'] as String?;
      if (themesJson != null) {
        try {
          final List<dynamic> themes = jsonDecode(themesJson);
          for (final theme in themes) {
            themeCounts[theme.toString()] = (themeCounts[theme.toString()] ?? 0) + 1;
          }
        } catch (e) {
          continue;
        }
      }
    }

    // Sort themes by count
    final sortedThemes = themeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'total_verses': totalCount.first['count'],
      'favorite_verses': favoriteCount.first['count'],
      'popular_themes': sortedThemes.take(10).map((e) => {
        'theme': e.key,
        'count': e.value,
      }).toList(),
    };
  }
}
