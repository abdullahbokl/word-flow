import 'package:fpdart/fpdart.dart';
import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/sync/sync_operation.dart';
import 'package:word_flow/core/sync/sync_preferences.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/sync_repository.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_local_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_remote_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';
import 'package:word_flow/features/vocabulary/data/mappers/word_mapper.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

@LazySingleton(as: SyncRepository)
class SyncRepositoryImpl implements SyncRepository {

  SyncRepositoryImpl(
    this._localSource,
    this._syncSource,
    this._remoteSource,
    this._preferences,
    this._logger,
  );

  final WordLocalSource _localSource;
  final SyncLocalSource _syncSource;
  final WordRemoteSource _remoteSource;
  final SyncPreferences _preferences;
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
    if (_remoteSource is DisabledWordRemoteSource) {
      _logger.debug('Skipping syncPendingWords: Remote sync not configured');
      return const Left(SyncFailure('Remote sync not configured'));
    }

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
                await _remoteSource.upsertWord(WordMapper.toRemoteDto(WordMapper.fromRow(word)));
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

  @override
  Future<Either<Failure, int>> pullRemoteChanges(String userId) async {
    if (_remoteSource is DisabledWordRemoteSource) {
      _logger.debug('Skipping pullRemoteChanges: Remote sync not configured');
      return const Left(SyncFailure('Remote sync not configured'));
    }

    try {
      _logger.syncEvent('Starting pull of remote changes for user: $userId');
      final lastPull = await _preferences.getLastPullTimestamp(userId);
      final now = DateTime.now().toUtc();

      int newCount = 0;
      int mergedCount = 0;
      int skippedCount = 0;
      
      int offset = 0;
      const int limit = 500;
      bool hasMore = true;

      while (hasMore) {
        final remoteBatchResult = lastPull == null
            ? await _remoteSource.fetchUserWords(userId, limit: limit, offset: offset)
            : await _remoteSource.fetchWordsUpdatedSince(userId, lastPull, limit: limit, offset: offset);

        await remoteBatchResult.fold(
          (failure) async {
             _logger.error('Failed fetching remote changes at offset $offset', failure);
             // Handle error per-page: stop pulling further pages but don't abort the entire sync
             hasMore = false;
          },
          (paginatedData) async {
            _logger.syncEvent('Fetched ${paginatedData.words.length} updated words from remote (offset $offset)');

            for (final remoteDto in paginatedData.words) {
              final localWord = await _localSource.getWordById(remoteDto.id);
              
              if (localWord == null) {
                // Completely new word
                final companion = WordMapper.toCompanion(WordMapper.fromRemoteDto(remoteDto));
                await _localSource.saveWord(companion);
                newCount++;
              } else {
                // Merge strategy:
                // - total_count: HIGHER value
                // - is_known: logical OR
                // - word_text: keep remote
                // - last_updated: NEWER timestamp
                final mergedTotalCount = max(localWord.totalCount, remoteDto.totalCount);
                final mergedIsKnown = localWord.isKnown || remoteDto.isKnown;
                final mergedWordText = remoteDto.wordText;
                
                final remoteTime = remoteDto.lastUpdated;
                final localTime = localWord.lastUpdated;
                final mergedLastUpdated = remoteTime.isAfter(localTime) ? remoteTime : localTime;

                // Check if merged result differs from local state
                if (localWord.totalCount != mergedTotalCount ||
                    localWord.isKnown != mergedIsKnown ||
                    localWord.wordText != mergedWordText ||
                    localWord.lastUpdated != mergedLastUpdated) {
                  
                  final updatedDto = remoteDto.copyWith(
                    totalCount: mergedTotalCount,
                    isKnown: mergedIsKnown,
                    wordText: mergedWordText,
                    lastUpdated: mergedLastUpdated,
                  );

                  final companion = WordMapper.toCompanion(WordMapper.fromRemoteDto(updatedDto));
                  await _localSource.saveWord(companion);
                  mergedCount++;
                } else {
                  // No changes to apply locally
                  skippedCount++;
                }
              }
            }

            hasMore = paginatedData.hasMore;
            offset += limit;
          },
        );
      }

      await _preferences.setLastPullTimestamp(userId, now);
      _logger.syncEvent('Successfully completed pull sync: $newCount new, $mergedCount merged, $skippedCount skipped');
      return Right(newCount + mergedCount);
    } catch (e, stackTrace) {
      _logger.error('Unexpected error during pull sync', e, stackTrace);
      return Left(SyncFailure(e.toString()));
    }
  }
}
