import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/chat_message.dart';

/// Service for managing chat conversations and messages
class ConversationService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Save a message to the database
  Future<void> saveMessage(ChatMessage message) async {
    try {
      final db = await _dbHelper.database;
      final map = message.toMap();

      await db.insert(
        'chat_messages',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Update session's last message
      if (message.sessionId != null) {
        await _updateSessionLastMessage(message);
      }

      debugPrint('✅ Message saved: ${message.id}');
    } catch (e) {
      debugPrint('❌ Failed to save message: $e');
      rethrow;
    }
  }

  /// Save multiple messages in a transaction
  Future<void> saveMessages(List<ChatMessage> messages) async {
    if (messages.isEmpty) return;

    try {
      final db = await _dbHelper.database;

      await db.transaction((txn) async {
        for (final message in messages) {
          await txn.insert(
            'chat_messages',
            message.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      // Update session last message
      if (messages.isNotEmpty && messages.last.sessionId != null) {
        await _updateSessionLastMessage(messages.last);
      }

      debugPrint('✅ Saved ${messages.length} messages');
    } catch (e) {
      debugPrint('❌ Failed to save messages: $e');
      rethrow;
    }
  }

  /// Get all messages for a session
  Future<List<ChatMessage>> getMessages(String sessionId) async {
    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'chat_messages',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'timestamp ASC',
      );

      return maps.map((map) => ChatMessage.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Failed to get messages: $e');
      return [];
    }
  }

  /// Get recent messages for a session (limit)
  Future<List<ChatMessage>> getRecentMessages(
    String sessionId, {
    int limit = 50,
  }) async {
    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'chat_messages',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      // Reverse to get chronological order
      return maps.reversed.map((map) => ChatMessage.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Failed to get recent messages: $e');
      return [];
    }
  }

  /// Create a new chat session
  Future<String> createSession({String? title}) async {
    try {
      final db = await _dbHelper.database;
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

      await db.insert('chat_sessions', {
        'id': sessionId,
        'title': title ?? 'New Conversation',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_archived': 0,
        'message_count': 0,
      });

      debugPrint('✅ Session created: $sessionId');
      return sessionId;
    } catch (e) {
      debugPrint('❌ Failed to create session: $e');
      rethrow;
    }
  }

  /// Get all chat sessions
  Future<List<Map<String, dynamic>>> getSessions({bool includeArchived = false}) async {
    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'chat_sessions',
        where: includeArchived ? null : 'is_archived = ?',
        whereArgs: includeArchived ? null : [0],
        orderBy: 'updated_at DESC',
      );

      return maps;
    } catch (e) {
      debugPrint('❌ Failed to get sessions: $e');
      return [];
    }
  }

  /// Update session title
  Future<void> updateSessionTitle(String sessionId, String title) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        'chat_sessions',
        {
          'title': title,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [sessionId],
      );

      debugPrint('✅ Session title updated: $sessionId');
    } catch (e) {
      debugPrint('❌ Failed to update session title: $e');
    }
  }

  /// Archive a session
  Future<void> archiveSession(String sessionId) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        'chat_sessions',
        {
          'is_archived': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [sessionId],
      );

      debugPrint('✅ Session archived: $sessionId');
    } catch (e) {
      debugPrint('❌ Failed to archive session: $e');
    }
  }

  /// Delete a session and all its messages
  Future<void> deleteSession(String sessionId) async {
    try {
      final db = await _dbHelper.database;

      await db.transaction((txn) async {
        // Delete all messages in the session
        await txn.delete(
          'chat_messages',
          where: 'session_id = ?',
          whereArgs: [sessionId],
        );

        // Delete the session
        await txn.delete(
          'chat_sessions',
          where: 'id = ?',
          whereArgs: [sessionId],
        );
      });

      debugPrint('✅ Session deleted: $sessionId');
    } catch (e) {
      debugPrint('❌ Failed to delete session: $e');
    }
  }

  /// Delete a specific message
  Future<void> deleteMessage(String messageId) async {
    try {
      final db = await _dbHelper.database;

      await db.delete(
        'chat_messages',
        where: 'id = ?',
        whereArgs: [messageId],
      );

      debugPrint('✅ Message deleted: $messageId');
    } catch (e) {
      debugPrint('❌ Failed to delete message: $e');
    }
  }

  /// Get message count for a session
  Future<int> getMessageCount(String sessionId) async {
    try {
      final db = await _dbHelper.database;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM chat_messages WHERE session_id = ?',
        [sessionId],
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('❌ Failed to get message count: $e');
      return 0;
    }
  }

  /// Update session's last message info
  Future<void> _updateSessionLastMessage(ChatMessage message) async {
    if (message.sessionId == null) return;

    try {
      final db = await _dbHelper.database;

      await db.update(
        'chat_sessions',
        {
          'updated_at': message.timestamp.millisecondsSinceEpoch,
          'last_message_at': message.timestamp.millisecondsSinceEpoch,
          'last_message_preview': message.preview,
          'message_count': await getMessageCount(message.sessionId!),
        },
        where: 'id = ?',
        whereArgs: [message.sessionId],
      );
    } catch (e) {
      debugPrint('⚠️ Failed to update session last message: $e');
      // Don't rethrow - this is not critical
    }
  }

  /// Search messages by content
  Future<List<ChatMessage>> searchMessages(String query) async {
    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'chat_messages',
        where: 'content LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'timestamp DESC',
        limit: 50,
      );

      return maps.map((map) => ChatMessage.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Failed to search messages: $e');
      return [];
    }
  }

  /// Export conversation as text
  Future<String> exportConversation(String sessionId) async {
    try {
      final messages = await getMessages(sessionId);
      final buffer = StringBuffer();

      buffer.writeln('Conversation Export');
      buffer.writeln('Date: ${DateTime.now().toString()}');
      buffer.writeln('Total Messages: ${messages.length}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      for (final message in messages) {
        buffer.writeln('[${message.type.displayName}] - ${message.formattedTime}');
        buffer.writeln(message.content);

        if (message.hasVerses) {
          buffer.writeln('\nRelevant Verses:');
          for (final verse in message.verses) {
            buffer.writeln('  ${verse.reference}: ${verse.text}');
          }
        }

        buffer.writeln();
        buffer.writeln('-' * 50);
        buffer.writeln();
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('❌ Failed to export conversation: $e');
      return '';
    }
  }

  /// Clear old conversations (older than specified days)
  Future<int> clearOldConversations(int daysOld) async {
    try {
      final db = await _dbHelper.database;
      final cutoffTime = DateTime.now()
          .subtract(Duration(days: daysOld))
          .millisecondsSinceEpoch;

      // Get sessions to delete
      final sessionsToDelete = await db.query(
        'chat_sessions',
        columns: ['id'],
        where: 'updated_at < ?',
        whereArgs: [cutoffTime],
      );

      int deletedCount = 0;

      for (final session in sessionsToDelete) {
        await deleteSession(session['id'] as String);
        deletedCount++;
      }

      debugPrint('✅ Cleared $deletedCount old conversations');
      return deletedCount;
    } catch (e) {
      debugPrint('❌ Failed to clear old conversations: $e');
      return 0;
    }
  }
}
