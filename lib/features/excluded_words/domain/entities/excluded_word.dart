import 'package:equatable/equatable.dart';

class ExcludedWord extends Equatable {
  const ExcludedWord({
    required this.word,
    required this.createdAt,
    this.id,
  });
  final int? id;
  final String word;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, word, createdAt];

  ExcludedWord copyWith({
    int? id,
    String? word,
    DateTime? createdAt,
  }) {
    return ExcludedWord(
      id: id ?? this.id,
      word: word ?? this.word,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
