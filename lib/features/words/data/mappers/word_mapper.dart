import 'package:word_flow/features/words/domain/entities/word.dart';
import 'package:word_flow/features/words/data/models/word_model.dart';
import 'package:word_flow/core/database/app_database.dart';

class WordMapper {
  static WordEntity toEntityFromModel(WordModel model) {
    return WordEntity(
      id: model.id,
      userId: model.userId,
      wordText: model.wordText,
      totalCount: model.totalCount,
      isKnown: model.isKnown,
      lastUpdated: model.lastUpdated,
    );
  }

  static WordModel fromEntityToModel(WordEntity entity) {
    return WordModel(
      id: entity.id,
      userId: entity.userId,
      wordText: entity.wordText,
      totalCount: entity.totalCount,
      isKnown: entity.isKnown,
      lastUpdated: entity.lastUpdated,
    );
  }

  static WordEntity toEntityFromRow(WordRow row) {
    return WordEntity(
      id: row.id,
      userId: row.userId,
      wordText: row.wordText,
      totalCount: row.totalCount,
      isKnown: row.isKnown,
      lastUpdated: row.lastUpdated,
    );
  }

  static WordModel toModelFromRow(WordRow row) {
    return WordModel(
      id: row.id,
      userId: row.userId,
      wordText: row.wordText,
      totalCount: row.totalCount,
      isKnown: row.isKnown,
      lastUpdated: row.lastUpdated,
    );
  }
}
