import 'package:equatable/equatable.dart';

class WordEntity extends Equatable {
  const WordEntity({
    required this.id,
    required this.text,
    required this.frequency,
    required this.isKnown,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String text;
  final int frequency;
  final bool isKnown;
  final DateTime createdAt;
  final DateTime updatedAt;

  WordEntity copyWith({
    int? id,
    String? text,
    int? frequency,
    bool? isKnown,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WordEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      frequency: frequency ?? this.frequency,
      isKnown: isKnown ?? this.isKnown,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, text, frequency, isKnown];
}
