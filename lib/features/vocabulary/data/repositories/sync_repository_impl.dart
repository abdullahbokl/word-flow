import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/sync/sync_operation.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/sync_repository.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_local_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_remote_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

@LazySingleton(as: SyncRepository)
class SyncRepositoryImpl implements SyncRepository {

  SyncRepositoryImpl(this._localSource, this._syncSource, this._remoteSource, this._logger);
  final WordLocalSource _localSource;
  final SyncLocalSource _syncSource;
  final WordRemoteSource _remoteSource;
  final AppLogger _logger;

  @override
  Future<Either<Failure, int>> getPendingCount() async {
    try {
      final count = await _syncSource.getSyncQueueCount();
      return Right(count);
    } catch (e) {
      return Left(SyncFailure(e.toString()));
    }
  }

  @override
  Stream<int> watchPendingCount() => _syncSource.watchSyncQueueCount();

  @override
  Future<Either<Failure, int>> syncPendingWords() async {
    try {
      _logger.syncEvent('Starting sync of pending words');
      final queueItems = await _syncSource.getSyncQueue(20);
      _logger.syncEvent('Found ${queueItems.length} items in sync queue limit query');
      int successCount = 0;
      final now = DateTime.now().toUtc();

      for (final item in queueItems) {
        final wordId = item.wordId;
        final operation = SyncOperation.fromString(item.operation);
        final queueId = item.id;
        final retryCount = item.retryCount;

        // Dead letter: skip items that have failed too many times
        if (retryCount > 10) {
          _logger.warning('Skipping dead letter queue item: $queueId (retries: $retryCount)');
          await _syncSource.removeFromSyncQueue(queueId);
          continue;
        }

        // Exponential backoff: skip items that haven't waited long enough
        // Backoff seconds: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
        if (retryCount > 0) {
          final backoffSeconds = (1 << retryCount).clamp(0, 1024); // 2^retryCount, max 1024s
          final lastAttempt = item.updatedAt;
          final timeSinceLastAttempt = now.difference(lastAttempt).inSeconds;
          if (timeSinceLastAttempt < backoffSeconds) {
            _logger.debug('Skipping backoff queue item: $queueId (wait: $backoffSeconds - $timeSinceLastAttempt)');
            continue; // Not enough time has passed, skip for now
          }
        }

        try {
          switch (operation) {
            case SyncOperation.upsert:
              final word = await _localSource.getWordById(wordId);
              if (word != null) {
                await _remoteSource.upsertWord(word);
                _logger.syncEvent('Successfully upserted word: ${word.wordText}');
              } else {
                 _logger.warning('Failed to upsert, missing word from local source: $wordId');
              }
              break;
            case SyncOperation.delete:
              await _remoteSource.deleteWord(wordId);
              _logger.syncEvent('Successfully deleted word locally with remote cascade: $wordId');
              break;
          }
          await _syncSource.removeFromSyncQueue(queueId);
          successCount++;
        } catch (e, stackTrace) {
          _logger.error('Error syncing operation: ${operation.name} on word $wordId', e, stackTrace);
          // Report to Sentry
          try {
            await Sentry.captureException(e, stackTrace: stackTrace);
          } catch (_) {}
          await _syncSource.updateSyncQueueRetry(queueId, e.toString());
        }
      }
      return Right(successCount);
    } catch (e, stackTrace) {
      _logger.error('Failed executing whole sync block queue query', e, stackTrace);
      try {
        await Sentry.captureException(e, stackTrace: stackTrace);
      } catch (_) {}
      return Left(SyncFailure(e.toString()));
    }
  }
}
