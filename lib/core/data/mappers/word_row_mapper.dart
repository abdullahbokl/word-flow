import 'dart:convert';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/core/domain/entities/review_schedule.dart';
import 'package:wordflow/core/domain/entities/word_category.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';

extension WordRowMapper on WordRow {
  WordEntity toEntity() {
    return WordEntity(
      id: id,
      text: word,
      frequency: frequency,
      isKnown: isKnown,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isExcluded: isExcluded,
      category: category != null
          ? WordCategory.values.firstWhere((e) => e.name == category)
          : null,
      reviewSchedule: reviewSchedule != null
          ? ReviewSchedule.fromJson(
              json.decode(reviewSchedule!) as Map<String, dynamic>)
          : null,
      meaning: meaning,
      description: description,
      definitions: definitions,
      examples: examples,
      translations: translations,
      synonyms: synonyms,
    );
  }
}

extension WordRowListMapper on List<WordRow> {
  List<WordEntity> toEntities() => map((r) => r.toEntity()).toList();
}
