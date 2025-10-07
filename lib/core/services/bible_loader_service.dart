import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

/// Service for loading Bible JSON files into the local SQLite database
class BibleLoaderService {
  final DatabaseService _database;

  BibleLoaderService(this._database);

  /// Load all Bible versions into the database
  Future<void> loadAllBibles() async {
    await loadBible('KJV', 'assets/bible/kjv.json', 'en');
    await loadBible('WEB', 'assets/bible/web.json', 'en');
  }

  /// Load a single Bible version from JSON asset
  Future<void> loadBible(String version, String assetPath, String language) async {
    try {
      // Load JSON from assets
      final jsonString = await rootBundle.loadString(assetPath);
      final dynamic jsonData = json.decode(jsonString);

      final db = await _database.database;

      // Handle different JSON structures
      if (jsonData is Map && jsonData.containsKey('verses')) {
        // WEB format: flat list of verses with metadata
        await _loadFlatVerses(db, version, language, jsonData['verses']);
      } else if (jsonData is List) {
        // KJV/RVR1909 format: nested books/chapters/verses
        await _loadNestedBooks(db, version, language, jsonData);
      } else {
        throw Exception('Unknown Bible JSON format for $version');
      }

      print('✅ Loaded $version Bible ($language)');
    } catch (e) {
      print('❌ Error loading $version: $e');
      rethrow;
    }
  }

  /// Load WEB-style flat verses format (optimized with batch insert)
  Future<void> _loadFlatVerses(Database db, String version, String language, List<dynamic> verses) async {
    const batchSize = 500; // Insert 500 verses at a time for optimal performance

    for (int i = 0; i < verses.length; i += batchSize) {
      final batch = db.batch();
      final end = (i + batchSize < verses.length) ? i + batchSize : verses.length;

      for (int j = i; j < end; j++) {
        final verseData = verses[j];
        batch.insert(
          'bible_verses',
          {
            'version': version,
            'book': verseData['book_name'],
            'chapter': verseData['chapter'],
            'verse': verseData['verse'],
            'text': verseData['text'],
            'language': language,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);

      // Optional: Report progress for large datasets
      if ((i + batchSize) % 5000 == 0) {
        print('📖 Loaded ${i + batchSize}/${verses.length} verses...');
      }
    }
  }

  /// Load KJV/RVR1909-style nested books format (optimized with batch insert)
  Future<void> _loadNestedBooks(Database db, String version, String language, List<dynamic> books) async {
    const batchSize = 500; // Insert 500 verses at a time for optimal performance
    final batch = db.batch();
    int batchCount = 0;
    int totalVerses = 0;

    for (var bookData in books) {
      final String abbrev = bookData['abbrev'] ?? '';
      final String bookName = _getBookName(abbrev);
      final List<dynamic> chapters = bookData['chapters'] ?? [];

      // Insert verses for each chapter
      for (int chapterIndex = 0; chapterIndex < chapters.length; chapterIndex++) {
        final List<dynamic> verses = chapters[chapterIndex];
        final int chapterNum = chapterIndex + 1;

        for (int verseIndex = 0; verseIndex < verses.length; verseIndex++) {
          final int verseNum = verseIndex + 1;
          final String verseText = verses[verseIndex];

          // Add verse to batch
          batch.insert(
            'bible_verses',
            {
              'version': version,
              'book': bookName,
              'chapter': chapterNum,
              'verse': verseNum,
              'text': verseText,
              'language': language,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          batchCount++;
          totalVerses++;

          // Commit batch when it reaches the batch size
          if (batchCount >= batchSize) {
            await batch.commit(noResult: true);
            batchCount = 0;

            // Report progress for large datasets
            if (totalVerses % 5000 == 0) {
              print('📖 Loaded $totalVerses verses...');
            }
          }
        }
      }
    }

    // Commit any remaining verses in the batch
    if (batchCount > 0) {
      await batch.commit(noResult: true);
    }

    print('📖 Total verses loaded: $totalVerses');
  }

  /// Convert book abbreviation to full name
  String _getBookName(String abbrev) {
    final Map<String, String> bookNames = {
      // Old Testament
      'gn': 'Genesis',
      'ex': 'Exodus',
      'lv': 'Leviticus',
      'nm': 'Numbers',
      'dt': 'Deuteronomy',
      'js': 'Joshua',
      'jg': 'Judges',
      'rt': 'Ruth',
      '1sm': '1 Samuel',
      '2sm': '2 Samuel',
      '1ki': '1 Kings',
      '2ki': '2 Kings',
      '1ch': '1 Chronicles',
      '2ch': '2 Chronicles',
      'ezr': 'Ezra',
      'ne': 'Nehemiah',
      'et': 'Esther',
      'jb': 'Job',
      'ps': 'Psalms',
      'pr': 'Proverbs',
      'ec': 'Ecclesiastes',
      'sg': 'Song of Solomon',
      'is': 'Isaiah',
      'jr': 'Jeremiah',
      'lm': 'Lamentations',
      'ezk': 'Ezekiel',
      'dn': 'Daniel',
      'ho': 'Hosea',
      'jl': 'Joel',
      'am': 'Amos',
      'ob': 'Obadiah',
      'jnh': 'Jonah',
      'mc': 'Micah',
      'na': 'Nahum',
      'hk': 'Habakkuk',
      'zp': 'Zephaniah',
      'hg': 'Haggai',
      'zc': 'Zechariah',
      'ml': 'Malachi',
      // New Testament
      'mt': 'Matthew',
      'mk': 'Mark',
      'lk': 'Luke',
      'jn': 'John',
      'ac': 'Acts',
      'ro': 'Romans',
      '1co': '1 Corinthians',
      '2co': '2 Corinthians',
      'gl': 'Galatians',
      'ep': 'Ephesians',
      'ph': 'Philippians',
      'cl': 'Colossians',
      '1th': '1 Thessalonians',
      '2th': '2 Thessalonians',
      '1tm': '1 Timothy',
      '2tm': '2 Timothy',
      'tt': 'Titus',
      'phm': 'Philemon',
      'hb': 'Hebrews',
      'jm': 'James',
      '1pt': '1 Peter',
      '2pt': '2 Peter',
      '1jn': '1 John',
      '2jn': '2 John',
      '3jn': '3 John',
      'jd': 'Jude',
      'rv': 'Revelation',
    };

    return bookNames[abbrev] ?? abbrev.toUpperCase();
  }

  /// Check if Bible data is already loaded
  Future<bool> isBibleLoaded(String version) async {
    final db = await _database.database;
    final result = await db.query(
      'bible_verses',
      where: 'version = ?',
      whereArgs: [version],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Get loading progress (for UI feedback)
  Future<Map<String, dynamic>> getLoadingProgress() async {
    final db = await _database.database;

    final kjvCount = await db.query(
      'bible_verses',
      where: 'version = ?',
      whereArgs: ['KJV'],
    );

    final webCount = await db.query(
      'bible_verses',
      where: 'version = ?',
      whereArgs: ['WEB'],
    );

    final rvrCount = await db.query(
      'bible_verses',
      where: 'version = ?',
      whereArgs: ['RVR1909'],
    );

    return {
      'KJV': kjvCount.length,
      'WEB': webCount.length,
      'RVR1909': rvrCount.length,
      'total': kjvCount.length + webCount.length + rvrCount.length,
    };
  }
}
