import 'dart:convert';

class ChatMessage {
  final int? id;
  final String sessionId;
  final String userInput;
  final String aiResponse;
  final List<int> verseReferences;
  final DateTime timestamp;
  final bool isFavorite;
  final bool shared;

  const ChatMessage({
    this.id,
    required this.sessionId,
    required this.userInput,
    required this.aiResponse,
    this.verseReferences = const [],
    required this.timestamp,
    this.isFavorite = false,
    this.shared = false,
  });

  /// Create ChatMessage from database map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int?,
      sessionId: map['session_id'] as String,
      userInput: map['user_input'] as String,
      aiResponse: map['ai_response'] as String,
      verseReferences: _parseVerseReferences(map['verse_references'] as String?),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      isFavorite: (map['is_favorite'] as int) == 1,
      shared: (map['shared'] as int) == 1,
    );
  }

  /// Convert ChatMessage to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'user_input': userInput,
      'ai_response': aiResponse,
      'verse_references': jsonEncode(verseReferences),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_favorite': isFavorite ? 1 : 0,
      'shared': shared ? 1 : 0,
    };
  }

  /// Parse verse references from JSON string
  static List<int> _parseVerseReferences(String? referencesJson) {
    if (referencesJson == null || referencesJson.isEmpty) return [];
    try {
      final List<dynamic> parsed = jsonDecode(referencesJson);
      return parsed.map((e) => e as int).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get formatted timestamp
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get share text
  String getShareText({bool includeApp = true}) {
    final baseText = '''
Question: $userInput

Response: $aiResponse
''';

    if (includeApp) {
      return '$baseText\nShared from Everyday Christian';
    }
    return baseText;
  }

  /// Check if message has verse references
  bool get hasVerseReferences => verseReferences.isNotEmpty;

  /// Copy with updated fields
  ChatMessage copyWith({
    int? id,
    String? sessionId,
    String? userInput,
    String? aiResponse,
    List<int>? verseReferences,
    DateTime? timestamp,
    bool? isFavorite,
    bool? shared,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userInput: userInput ?? this.userInput,
      aiResponse: aiResponse ?? this.aiResponse,
      verseReferences: verseReferences ?? this.verseReferences,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      shared: shared ?? this.shared,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatMessage &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^ sessionId.hashCode ^ timestamp.hashCode;
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, sessionId: $sessionId, timestamp: $timestamp, favorite: $isFavorite)';
  }
}

class ChatSession {
  final String id;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final int messageCount;

  const ChatSession({
    required this.id,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.messageCount = 0,
  });

  /// Create ChatSession from database map
  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'] as String,
      title: map['title'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isArchived: (map['is_archived'] as int) == 1,
      messageCount: map['message_count'] as int? ?? 0,
    );
  }

  /// Convert ChatSession to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_archived': isArchived ? 1 : 0,
      'message_count': messageCount,
    };
  }

  /// Get display title
  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    return 'Chat from ${_formatDate(createdAt)}';
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Copy with updated fields
  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    int? messageCount,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatSession(id: $id, title: $title, messageCount: $messageCount, archived: $isArchived)';
  }
}