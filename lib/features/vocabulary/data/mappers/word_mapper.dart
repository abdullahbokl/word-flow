import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/vocabulary/data/models/word_remote_dto.dart';
import 'package:word_flow/core/database/app_database.dart';

class WordMapper {
  static Either<Failure, WordEntity> fromRemoteDto(WordRemoteDto dto) {
    try {
      return Right(
        WordEntity.validated(
          id: dto.id,
          userId: dto.userId,
          wordText: dto.wordText,
          totalCount: dto.totalCount,
          isKnown: dto.isKnown,
          lastUpdated: dto.lastUpdated,
          serverTimestamp: dto.serverTimestamp,
        ),
      );
    } on ArgumentError catch (e) {
      return Left(
        ProcessingFailure('Invalid remote word entity: ${e.message}'),
      );
    }
  }

  static WordRemoteDto toRemoteDto(WordEntity entity) {
    return WordRemoteDto(
      id: entity.id,
      userId: entity.userId,
      wordText: entity.wordText,
      totalCount: entity.totalCount,
      isKnown: entity.isKnown,
      lastUpdated: entity.lastUpdated,
      serverTimestamp: entity.serverTimestamp,
    );
  }

  static Either<Failure, WordEntity> fromRow(WordRow row) {
    try {
      return Right(
        WordEntity.validated(
          id: row.id,
          userId: row.userId,
          wordText: row.wordText,
          totalCount: row.totalCount,
          isKnown: row.isKnown,
          lastUpdated: row.lastUpdated,
          serverTimestamp: row.serverTimestamp,
        ),
      );
    } on ArgumentError catch (e) {
      return Left(
        ProcessingFailure('Invalid stored word entity: ${e.message}'),
      );
    }
  }

  // To convert entity to companions for insertion
  static WordsCompanion toCompanion(
    WordEntity entity, {
    bool includeServerTimestamp = false,
  }) {
    return WordsCompanion.insert(
      id: entity.id,
      userId: Value(entity.userId),
      wordText: entity.wordText,
      totalCount: Value(entity.totalCount),
      isKnown: Value(entity.isKnown),
      lastUpdated: entity.lastUpdated,
      serverTimestamp: includeServerTimestamp
          ? Value(entity.serverTimestamp)
          : const Value.absent(),
    );
  }
}
