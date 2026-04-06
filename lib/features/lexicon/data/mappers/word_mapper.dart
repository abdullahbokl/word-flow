import '../../../../core/database/app_database.dart';
import '../../../../core/domain/entities/word_entity.dart';

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
    );
  }
}
