import 'package:equatable/equatable.dart';
import 'package:wordflow/core/domain/entities/review_schedule.dart';
import 'package:wordflow/core/domain/entities/word_category.dart';
import 'package:wordflow/features/lexicon/domain/entities/tag_entity.dart';

class WordEntity extends Equatable {
  const WordEntity({
    required this.id,
    required this.text,
    required this.frequency,
    required this.isKnown,
    required this.createdAt,
    required this.updatedAt,
    required this.isExcluded,
    this.category,
    this.reviewSchedule,
    this.meaning,
    this.description,
    this.definitions,
    this.examples,
    this.translations,
    this.synonyms,
    this.tags = const [],
  });

  final int id;
  final String text;
  final int frequency;
  final bool isKnown;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isExcluded;
  final WordCategory? category;
  final ReviewSchedule? reviewSchedule;
  final String? meaning;
  final String? description;
  final List<String>? definitions;
  final List<String>? examples;
  final List<String>? translations;
  final List<String>? synonyms;
  final List<TagEntity> tags;

  WordEntity copyWith({
    int? id,
    String? text,
    int? frequency,
    bool? isKnown,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isExcluded,
    WordCategory? category,
    ReviewSchedule? reviewSchedule,
    String? meaning,
    String? description,
    List<String>? definitions,
    List<String>? examples,
    List<String>? translations,
    List<String>? synonyms,
    List<TagEntity>? tags,
  }) {
    return WordEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      frequency: frequency ?? this.frequency,
      isKnown: isKnown ?? this.isKnown,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isExcluded: isExcluded ?? this.isExcluded,
      category: category ?? this.category,
      reviewSchedule: reviewSchedule ?? this.reviewSchedule,
      meaning: meaning ?? this.meaning,
      description: description ?? this.description,
      definitions: definitions ?? this.definitions,
      examples: examples ?? this.examples,
      translations: translations ?? this.translations,
      synonyms: synonyms ?? this.synonyms,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        frequency,
        isKnown,
        createdAt,
        updatedAt,
        isExcluded,
        category,
        reviewSchedule,
        meaning,
        description,
        definitions,
        examples,
        translations,
        synonyms,
        tags,
      ];
}
