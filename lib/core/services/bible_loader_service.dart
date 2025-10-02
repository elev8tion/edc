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
    await loadBible('RVR1909', 'assets/bible/rvr1909.json', 'es');
  }

  /// Load a single Bible version from JSON asset
  Future<void> loadBible(String version, String assetPath, String language) async {
    try {
      // Load JSON from assets
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> books = json.decode(jsonString);

      final db = await _database.database;

      // Process each book
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

            // Insert verse into database
            await db.insert(
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
          }
        }
      }

      print('✅ Loaded $version Bible ($language)');
    } catch (e) {
      print('❌ Error loading $version: $e');
      rethrow;
    }
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

    final rvrCount = await db.query(
      'bible_verses',
      where: 'version = ?',
      whereArgs: ['RVR1909'],
    );

    return {
      'KJV': kjvCount.length,
      'RVR1909': rvrCount.length,
      'total': kjvCount.length + rvrCount.length,
    };
  }
}
