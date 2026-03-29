import 'package:equatable/equatable.dart';

class WordEntity extends Equatable {
  final String id;
  final String? userId;
  final String wordText;
  final int totalCount;
  final bool isKnown;
  final DateTime lastUpdated;

  const WordEntity({
    required this.id,
    this.userId,
    required this.wordText,
    this.totalCount = 1,
    this.isKnown = false,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        wordText,
        totalCount,
        isKnown,
        lastUpdated,
      ];

  WordEntity copyWith({
    String? id,
    String? userId,
    String? wordText,
    int? totalCount,
    bool? isKnown,
    DateTime? lastUpdated,
  }) {
    return WordEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      wordText: wordText ?? this.wordText,
      totalCount: totalCount ?? this.totalCount,
      isKnown: isKnown ?? this.isKnown,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
