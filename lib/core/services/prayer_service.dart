import 'package:uuid/uuid.dart';
import '../models/prayer_request.dart';
import 'database_service.dart';

class PrayerService {
  final DatabaseService _database;
  final Uuid _uuid = const Uuid();

  PrayerService(this._database);

  Future<List<PrayerRequest>> getActivePrayers() async {
    final db = await _database.database;
    final maps = await db.query(
      'prayer_requests',
      where: 'is_answered = ?',
      whereArgs: [0],
      orderBy: 'date_created DESC',
    );

    return maps.map((map) => _prayerRequestFromMap(map)).toList();
  }

  Future<List<PrayerRequest>> getAnsweredPrayers() async {
    final db = await _database.database;
    final maps = await db.query(
      'prayer_requests',
      where: 'is_answered = ?',
      whereArgs: [1],
      orderBy: 'date_answered DESC',
    );

    return maps.map((map) => _prayerRequestFromMap(map)).toList();
  }

  Future<List<PrayerRequest>> getAllPrayers() async {
    final db = await _database.database;
    final maps = await db.query(
      'prayer_requests',
      orderBy: 'date_created DESC',
    );

    return maps.map((map) => _prayerRequestFromMap(map)).toList();
  }

  Future<void> addPrayer(PrayerRequest prayer) async {
    final db = await _database.database;
    await db.insert('prayer_requests', _prayerRequestToMap(prayer));
  }

  Future<void> updatePrayer(PrayerRequest prayer) async {
    final db = await _database.database;
    await db.update(
      'prayer_requests',
      _prayerRequestToMap(prayer),
      where: 'id = ?',
      whereArgs: [prayer.id],
    );
  }

  Future<void> deletePrayer(String id) async {
    final db = await _database.database;
    await db.delete(
      'prayer_requests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markPrayerAnswered(
    String id,
    String answerDescription,
  ) async {
    final db = await _database.database;
    await db.update(
      'prayer_requests',
      {
        'is_answered': 1,
        'date_answered': DateTime.now().millisecondsSinceEpoch,
        'answer_description': answerDescription,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<PrayerRequest> createPrayer({
    required String title,
    required String description,
    required PrayerCategory category,
  }) async {
    final prayer = PrayerRequest(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      dateCreated: DateTime.now(),
    );

    await addPrayer(prayer);
    return prayer;
  }

  Future<int> getPrayerCount() async {
    final db = await _database.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM prayer_requests');
    return result.first['count'] as int;
  }

  Future<int> getAnsweredPrayerCount() async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM prayer_requests WHERE is_answered = 1',
    );
    return result.first['count'] as int;
  }

  PrayerRequest _prayerRequestFromMap(Map<String, dynamic> map) {
    return PrayerRequest(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: PrayerCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => PrayerCategory.general,
      ),
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['date_created']),
      isAnswered: map['is_answered'] == 1,
      dateAnswered: map['date_answered'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date_answered'])
          : null,
      answerDescription: map['answer_description'],
    );
  }

  Map<String, dynamic> _prayerRequestToMap(PrayerRequest prayer) {
    return {
      'id': prayer.id,
      'title': prayer.title,
      'description': prayer.description,
      'category': prayer.category.name,
      'date_created': prayer.dateCreated.millisecondsSinceEpoch,
      'is_answered': prayer.isAnswered ? 1 : 0,
      'date_answered': prayer.dateAnswered?.millisecondsSinceEpoch,
      'answer_description': prayer.answerDescription,
    };
  }
}