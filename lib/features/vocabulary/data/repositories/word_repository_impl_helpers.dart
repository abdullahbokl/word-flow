import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_local_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/vocabulary/data/models/word_model.dart';
import 'package:word_flow/features/vocabulary/data/mappers/word_mapper.dart';
import 'package:word_flow/core/sync/sync_operation.dart';
import 'package:word_flow/core/utils/uuid_generator.dart';
import 'package:word_flow/core/database/write_queue.dart';

mixin WordRepositoryImplHelpers {
  WordLocalSource get localSource;
  SyncLocalSource get syncSource;
  AppLogger get logger;
  LocalWriteQueue get writeQueue;

  Future<Either<Failure, void>> handleSaveWords(List<WordEntity> words) async {
    try {
      await writeQueue.enqueue(() async {
        final now = DateTime.now().toUtc();
        final candidates = words.map(WordMapper.fromEntityToModel).toList(growable: false);
        final existingMaps = <String?, Map<String, WordModel>>{};
        for (final uId in candidates.map((w) => w.userId).toSet()) {
          existingMaps[uId] = await localSource.getWordTextMap(userId: uId);
        }

        final List<WordModel> models = [];
        for (final candidate in candidates) {
          final existing = existingMaps[candidate.userId]?[candidate.wordText];
          models.add(existing == null
              ? WordModel(
                  id: candidate.id,
                  userId: candidate.userId,
                  wordText: candidate.wordText,
                  totalCount: candidate.totalCount,
                  isKnown: candidate.isKnown,
                  lastUpdated: now,
                )
              : WordModel(
                  id: existing.id,
                  userId: existing.userId,
                  wordText: existing.wordText,
                  totalCount: existing.totalCount + candidate.totalCount,
                  isKnown: existing.isKnown || candidate.isKnown,
                  lastUpdated: now,
                ));
        }
        await localSource.saveWords(models);
        for (final m in models.where((m) => m.userId != null)) {
          await syncSource.enqueueSyncOperation(m.id, SyncOperation.upsert.value);
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> handleToggleKnown(String text, {String? userId}) async {
    try {
      await writeQueue.enqueue(() async {
        final wordModel = await localSource.getWordByText(text, userId: userId);
        final model = wordModel != null
            ? WordMapper.fromEntityToModel(
                WordMapper.toEntityFromModel(wordModel).copyWith(
                  isKnown: !wordModel.isKnown,
                  lastUpdated: DateTime.now().toUtc(),
                ),
              )
            : WordModel(
                id: UuidGenerator.generate(),
                userId: userId,
                wordText: text,
                totalCount: 1,
                isKnown: true,
                lastUpdated: DateTime.now().toUtc(),
              );
        await localSource.saveWord(model);
        if (model.userId != null) {
          await syncSource.enqueueSyncOperation(model.id, SyncOperation.upsert.value);
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
      logger.syncEvent('Successfully adopted $count guest words for user: $userId');
      return Right(count);
    } catch (e, stackTrace) {
      logger.error('Guest data migration failed', e, stackTrace);
      try {
        await Sentry.captureException(e, stackTrace: stackTrace);
      } catch (_) {}
      return Left(MigrationFailure('Guest data migration failed: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> handleClearLocalWords({String? userId}) async {
    try {
      await localSource.clearLocalWords(userId: userId);
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
