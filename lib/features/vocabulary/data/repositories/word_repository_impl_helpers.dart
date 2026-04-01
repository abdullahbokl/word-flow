import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_local_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';
import 'package:word_flow/features/vocabulary/data/mappers/word_mapper.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word_entity.dart';
import 'package:word_flow/features/vocabulary/data/sync/sync_operation.dart';
import 'package:word_flow/core/utils/uuid_generator.dart';
import 'package:word_flow/core/database/write_queue.dart';
import 'package:word_flow/core/database/constants.dart';

mixin WordRepositoryImplHelpers {
  WordLocalSource get localSource;
  SyncLocalSource get syncSource;
  AppLogger get logger;
  LocalWriteQueue get writeQueue;

  Future<Either<Failure, void>> handleSaveWords(List<WordEntity> words) async {
    try {
      await writeQueue.enqueue(() async {
        final now = DateTime.now().toUtc();

        // Group words by userId to perform targeted fetches per user
        final userIds = words.map((w) => w.userId).toSet();
        final existingMap = <String, WordRow>{};

        for (final uId in userIds) {
          final wordTexts = words
              .where((w) => w.userId == uId)
              .map((w) => w.wordText)
              .toList();

          final rows = await localSource.getWordsByTexts(
            wordTexts,
            userId: uId,
          );
          for (final row in rows) {
            // Key by (userId, wordText) to handle multi-user scenarios if words list mixed
            existingMap['${uId}_${row.wordText}'] = row;
          }
        }

        final List<WordsCompanion> companions = [];
        final List<String> syncIds = [];

        for (final word in words) {
          final key = '${word.userId}_${word.wordText}';
          final existing = existingMap[key];

          if (existing == null) {
            companions.add(
              WordMapper.toCompanion(word.copyWith(lastUpdated: now)),
            );
            if (word.userId != guestUserId) syncIds.add(word.id);
          } else {
            final existingEntity = WordMapper.fromRow(
              existing,
            ).getOrElse((failure) => throw StateError(failure.message));
            final merged = existingEntity.copyWith(
              totalCount: existingEntity.totalCount + word.totalCount,
              isKnown: existingEntity.isKnown || word.isKnown,
              lastUpdated: now,
            );
            companions.add(WordMapper.toCompanion(merged));
            if (merged.userId != guestUserId) syncIds.add(merged.id);
          }
        }

        await localSource.saveWords(companions);
        for (final id in syncIds) {
          await syncSource.enqueueSyncOperation(id, SyncOperation.upsert.value);
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> handleToggleKnown(
    String text, {
    String userId = guestUserId,
  }) async {
    try {
      await writeQueue.enqueue(() async {
        final row = await localSource.getWordByText(text, userId: userId);
        final WordEntity entity;

        if (row != null) {
          final existing = WordMapper.fromRow(
            row,
          ).getOrElse((failure) => throw StateError(failure.message));
          entity = existing.copyWith(
            isKnown: !existing.isKnown,
            lastUpdated: DateTime.now().toUtc(),
          );
        } else {
          entity = WordEntity(
            id: UuidGenerator.generate(),
            userId: userId,
            wordText: text,
            totalCount: 1,
            isKnown: true,
            lastUpdated: DateTime.now().toUtc(),
          );
        }

        await localSource.saveWord(WordMapper.toCompanion(entity));
        if (entity.userId != guestUserId) {
          await syncSource.enqueueSyncOperation(
            entity.id,
            SyncOperation.upsert.value,
          );
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, int>> handleAdoptGuestWords(String userId) async {
    logger.info('Starting guest data migration for user: $userId');
    try {
      final count = await localSource.adoptGuestWords(userId);
      logger.syncEvent(
        'Successfully adopted $count guest words for user: $userId',
      );
      return Right(count);
    } catch (e, stackTrace) {
      logger.error(
        'Guest data migration failed',
        error: e,
        stackTrace: stackTrace,
        category: LogCategory.database,
      );
      try {
        await Sentry.captureException(e, stackTrace: stackTrace);
      } catch (_) {}
      return Left(
        MigrationFailure('Guest data migration failed: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, void>> handleClearLocalWords(String userId) async {
    try {
      await localSource.clearLocalWords(userId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> handleClearGuestWords() async {
    try {
      await localSource.clearGuestWords();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, int>> handleGetGuestWordsCount() async {
    try {
      final count = await localSource.getGuestWordsCount();
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
