import 'package:lexitrack/core/database/app_database.dart';
import 'package:lexitrack/core/domain/entities/word_entity.dart';

extension WordRowMapper on WordRow {
  WordEntity toEntity() {
    return WordEntity(
      id: id,
      text: word,
      frequency: frequency,
      isKnown: isKnown,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
