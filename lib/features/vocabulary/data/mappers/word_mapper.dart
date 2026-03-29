import 'package:drift/drift.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/vocabulary/data/models/word_remote_dto.dart';
import 'package:word_flow/core/database/app_database.dart';

class WordMapper {
  static WordEntity fromRemoteDto(WordRemoteDto dto) {
    return WordEntity(
      id: dto.id,
      userId: dto.userId,
      wordText: dto.wordText,
      totalCount: dto.totalCount,
      isKnown: dto.isKnown,
      lastUpdated: dto.lastUpdated,
    );
  }

  static WordRemoteDto toRemoteDto(WordEntity entity) {
    return WordRemoteDto(
      id: entity.id,
      userId: entity.userId,
      wordText: entity.wordText,
      totalCount: entity.totalCount,
      isKnown: entity.isKnown,
      lastUpdated: entity.lastUpdated,
    );
  }

  static WordEntity fromRow(WordRow row) {
    return WordEntity(
      id: row.id,
      userId: row.userId,
      wordText: row.wordText,
      totalCount: row.totalCount,
      isKnown: row.isKnown,
      lastUpdated: row.lastUpdated,
    );
  }

  // To convert entity to companions for insertion
  static WordsCompanion toCompanion(WordEntity entity) {
    return WordsCompanion.insert(
      id: entity.id,
      userId: Value(entity.userId),
      wordText: entity.wordText,
      totalCount: Value(entity.totalCount),
      isKnown: Value(entity.isKnown),
      lastUpdated: entity.lastUpdated,
    );
  }
}
