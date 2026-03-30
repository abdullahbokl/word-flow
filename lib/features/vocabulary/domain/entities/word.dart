import 'package:equatable/equatable.dart';

class WordEntity extends Equatable {
  /// Internal/trusted constructor. Prefer [WordEntity.validated] for external input.
  const WordEntity({
    required this.id,
    this.userId,
    required this.wordText,
    this.totalCount = 1,
    this.isKnown = false,
    required this.lastUpdated,
    this.serverTimestamp,
  });

  factory WordEntity.validated({
    required String id,
    String? userId,
    required String wordText,
    int totalCount = 1,
    bool isKnown = false,
    required DateTime lastUpdated,
    DateTime? serverTimestamp,
  }) {
    final normalizedWordText = wordText.trim();
    if (normalizedWordText.isEmpty) {
      throw ArgumentError('wordText cannot be empty');
    }
    if (normalizedWordText.length > 100) {
      throw ArgumentError('wordText cannot exceed 100 characters');
    }
    if (totalCount < 1) {
      throw ArgumentError('totalCount must be at least 1');
    }
    if (lastUpdated.toUtc().isAfter(DateTime.now().toUtc())) {
      throw ArgumentError('lastUpdated cannot be in the future');
    }

    return WordEntity(
      id: id,
      userId: userId,
      wordText: normalizedWordText,
      totalCount: totalCount,
      isKnown: isKnown,
      lastUpdated: lastUpdated,
      serverTimestamp: serverTimestamp,
    );
  }
  final String id;
  final String? userId;
  final String wordText;
  final int totalCount;
  final bool isKnown;
  final DateTime lastUpdated;
  final DateTime? serverTimestamp;

  @override
  List<Object?> get props => [
    id,
    userId,
    wordText,
    totalCount,
    isKnown,
    lastUpdated,
    serverTimestamp,
  ];

  WordEntity copyWith({
    String? id,
    String? userId,
    String? wordText,
    int? totalCount,
    bool? isKnown,
    DateTime? lastUpdated,
    DateTime? serverTimestamp,
  }) {
    return WordEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      wordText: wordText ?? this.wordText,
      totalCount: totalCount ?? this.totalCount,
      isKnown: isKnown ?? this.isKnown,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      serverTimestamp: serverTimestamp ?? this.serverTimestamp,
    );
  }
}
