import '../../domain/entities/word.dart';

class WordModel extends Word {
  const WordModel({
    required super.id,
    super.userId,
    required super.wordText,
    super.totalCount = 1,
    super.isKnown = false,
    required super.lastUpdated,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      wordText: map['word_text'] as String,
      totalCount: map['total_count'] as int,
      isKnown: map['is_known'] is int 
          ? (map['is_known'] as int) == 1 
          : (map['is_known'] as bool),
      lastUpdated: DateTime.parse(map['last_updated'] as String).toUtc(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'word_text': wordText,
      'total_count': totalCount,
      'is_known': isKnown ? 1 : 0, // Store as int for SQLite
      'last_updated': lastUpdated.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toRemoteMap() {
    return {
      'id': id,
      'user_id': userId,
      'word_text': wordText,
      'total_count': totalCount,
      'is_known': isKnown, // PostgREST expects true/false
      'last_updated': lastUpdated.toUtc().toIso8601String(),
    };
  }

  factory WordModel.fromEntity(Word word) {
    return WordModel(
      id: word.id,
      userId: word.userId,
      wordText: word.wordText,
      totalCount: word.totalCount,
      isKnown: word.isKnown,
      lastUpdated: word.lastUpdated,
    );
  }
}
