import 'package:equatable/equatable.dart';

class WordModel extends Equatable {
  final String id;
  final String? userId;
  final String wordText;
  final int totalCount;
  final bool isKnown;
  final DateTime lastUpdated;

  const WordModel({
    required this.id,
    this.userId,
    required this.wordText,
    this.totalCount = 1,
    this.isKnown = false,
    required this.lastUpdated,
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
      'is_known': isKnown ? 1 : 0,
      'last_updated': lastUpdated.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toRemoteMap() {
    return {
      'id': id,
      'user_id': userId,
      'word_text': wordText,
      'total_count': totalCount,
      'is_known': isKnown,
      'last_updated': lastUpdated.toUtc().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        wordText,
        totalCount,
        isKnown,
        lastUpdated,
      ];
}
