import 'package:fpdart/fpdart.dart';
import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/errors/error_mapper.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/observability/sentry_breadcrumbs.dart';
import 'package:word_flow/core/sync/sync_operation.dart';
import 'package:word_flow/core/sync/sync_preferences.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/sync_repository.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_dead_letter_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_local_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_remote_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';
import 'package:word_flow/features/vocabulary/data/mappers/word_mapper.dart';
import 'package:word_flow/core/database/app_database.dart';

@LazySingleton(as: SyncRepository)
class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl(
    this._localSource,
    this._syncSource,
    this._deadLetterSource,
    this._remoteSource,
    this._preferences,
    this._logger,
  );

  final WordLocalSource _localSource;
  final SyncLocalSource _syncSource;
  final SyncDeadLetterSource _deadLetterSource;
  final WordRemoteSource _remoteSource;
  final SyncPreferences _preferences;
  final AppLogger _logger;

  Failure _mapSyncFailure(dynamic error, StackTrace stackTrace) {
    final mapped = ErrorMapper.mapException(error, stackTrace, _logger);
    if (mapped is SyncFailure) {
      return mapped;
    }
    return SyncFailure(mapped.message);
  }

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
      _logger.syncEvent(
        'Found ${queueItems.length} items in sync queue limit query',
      );
      int successCount = 0;
      final now = DateTime.now().toUtc();

      for (final item in queueItems) {
        final wordId = item.wordId;
        final operation = SyncOperation.fromString(item.operation);
        final queueId = item.id;
        final retryCount = item.retryCount;

        // Dead letter: skip items that have failed too many times
        if (retryCount > 10) {
          final word = await _localSource.getWordById(wordId);
          final wordText = word?.wordText ?? '[deleted locally]';
          final errorMessage =
              item.lastError ?? 'Exceeded max retry count ($retryCount)';

          await _deadLetterSource.addDeadLetter(
            wordId: wordId,
            wordText: wordText,
            operation: item.operation,
            lastError: errorMessage,
            failedAt: now,
          );

          // Breadcrumb: Dead-letter event (warning level)
          SentryBreadcrumbs.addDBBreadcrumb(
            'Sync item moved to dead letters',
            operation: item.operation,
            data: {
              'wordId': wordId,
              'wordText': wordText,
              'retryCount': retryCount,
              'lastError': errorMessage,
              'queueId': queueId,
            },
            level: SentryLevel.warning,
          );

          _logger.warning(
            'Moved queue item to dead letters: $queueId (retries: $retryCount)',
          );
          await _syncSource.removeFromSyncQueue(queueId);
          continue;
        }

        // Exponential backoff: skip items that haven't waited long enough
        // Backoff seconds: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
        if (retryCount > 0) {
          final backoffSeconds = (1 << retryCount).clamp(
            0,
            1024,
          ); // 2^retryCount, max 1024s
          final lastAttempt = item.updatedAt;
          final timeSinceLastAttempt = now.difference(lastAttempt).inSeconds;
          if (timeSinceLastAttempt < backoffSeconds) {
            _logger.debug(
              'Skipping backoff queue item: $queueId (wait: $backoffSeconds - $timeSinceLastAttempt)',
            );
            continue; // Not enough time has passed, skip for now
          }
        }

        try {
          switch (operation) {
            case SyncOperation.upsert:
              final word = await _localSource.getWordById(wordId);
              if (word != null) {
                final mappedWord = WordMapper.fromRow(word);
                final mapFailure = mappedWord.fold((f) => f, (_) => null);
                if (mapFailure != null) {
                  _logger.error(
                    'Skipping invalid local word during sync: $wordId',
                    mapFailure,
                  );
                  await _syncSource.removeFromSyncQueue(queueId);
                  continue;
                }

                await _remoteSource.upsertWord(
                  WordMapper.toRemoteDto(
                    mappedWord.getOrElse(
                      (_) =>
                          throw StateError('Mapped word unexpectedly missing'),
                    ),
                  ),
                );
                _logger.syncEvent(
                  'Successfully upserted word: ${word.wordText}',
                );
              } else {
                _logger.warning(
                  'Failed to upsert, missing word from local source: $wordId',
                );
              }
              break;
            case SyncOperation.delete:
              await _remoteSource.deleteWord(wordId);
              _logger.syncEvent(
                'Successfully deleted word locally with remote cascade: $wordId',
              );
              break;
          }
          await _syncSource.removeFromSyncQueue(queueId);
          successCount++;
        } catch (e, stackTrace) {
          _logger.error(
            'Error syncing operation: ${operation.name} on word $wordId',
            e,
            stackTrace,
          );
          // Report to Sentry
          try {
            await Sentry.captureException(e, stackTrace: stackTrace);
          } catch (_) {}
          await _syncSource.updateSyncQueueRetry(queueId, e.toString());
        }
      }
      return Right(successCount);
    } catch (e, stackTrace) {
      // No force-cast: map safely, then normalize to sync-domain failure.
      return Left(_mapSyncFailure(e, stackTrace));
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

      const int limit = 500;
      String? cursorTime;
      String? cursorId;

      while (true) {
        final remoteBatchResult = lastPull == null
            ? await _remoteSource.fetchUserWords(
                userId,
                limit: limit,
                cursorTime: cursorTime,
                cursorId: cursorId,
              )
            : await _remoteSource.fetchWordsUpdatedSince(
                userId,
                lastPull,
                limit: limit,
                cursorTime: cursorTime,
                cursorId: cursorId,
              );

        final fetchFailure = remoteBatchResult.fold(
          (failure) => failure,
          (_) => null,
        );
        if (fetchFailure != null) {
          _logger.error(
            'Failed fetching remote changes at cursor ($cursorTime, $cursorId)',
            fetchFailure,
          );
          return Left(fetchFailure);
        }

        final paginatedData = remoteBatchResult.getOrElse(
          (_) => throw StateError('Remote batch unexpectedly missing'),
        );

        _logger.syncEvent(
          'Fetched ${paginatedData.words.length} updated words from remote (cursor: $cursorTime, $cursorId)',
        );

        // Stage all local writes for this page in memory first.
        final companionsToCommit = <WordsCompanion>[];
        var pageNewCount = 0;
        var pageMergedCount = 0;
        var pageSkippedCount = 0;

        for (final remoteDto in paginatedData.words) {
          final localWord = await _localSource.getWordById(remoteDto.id);

          if (localWord == null) {
            final mappedRemote = WordMapper.fromRemoteDto(remoteDto);
            final mapFailure = mappedRemote.fold((f) => f, (_) => null);
            if (mapFailure != null) {
              _logger.error(
                'Skipping invalid remote word during pull: ${remoteDto.id}',
                mapFailure,
              );
              pageSkippedCount++;
              continue;
            }

            companionsToCommit.add(
              WordMapper.toCompanion(
                mappedRemote.getOrElse(
                  (_) => throw StateError(
                    'Mapped remote word unexpectedly missing',
                  ),
                ),
                includeServerTimestamp: true,
              ),
            );
            pageNewCount++;
            continue;
          }

          // Merge strategy:
          // - total_count: HIGHER value
          // - is_known: logical OR
          // - word_text: keep remote
          // - winner selection: server_timestamp (server-authored clock)
          final mergedTotalCount = max(
            localWord.totalCount,
            remoteDto.totalCount,
          );
          final mergedIsKnown = localWord.isKnown || remoteDto.isKnown;
          final remoteServerTs = remoteDto.serverTimestamp;
          final localServerTs = localWord.serverTimestamp;
          final useRemote =
              remoteServerTs != null &&
              (localServerTs == null || remoteServerTs.isAfter(localServerTs));

          final mergedWordText = useRemote
              ? remoteDto.wordText
              : localWord.wordText;
          final mergedLastUpdated = useRemote
              ? remoteDto.lastUpdated
              : localWord.lastUpdated;
          final mergedServerTimestamp = useRemote
              ? remoteServerTs
              : localServerTs;

          if (localWord.totalCount != mergedTotalCount ||
              localWord.isKnown != mergedIsKnown ||
              localWord.wordText != mergedWordText ||
              localWord.lastUpdated != mergedLastUpdated ||
              localWord.serverTimestamp != mergedServerTimestamp) {
            final updatedDto = remoteDto.copyWith(
              totalCount: mergedTotalCount,
              isKnown: mergedIsKnown,
              wordText: mergedWordText,
              lastUpdated: mergedLastUpdated,
              serverTimestamp: mergedServerTimestamp,
            );

            final mappedUpdated = WordMapper.fromRemoteDto(updatedDto);
            final mapFailure = mappedUpdated.fold((f) => f, (_) => null);
            if (mapFailure != null) {
              _logger.error(
                'Skipping invalid merged remote word during pull: ${updatedDto.id}',
                mapFailure,
              );
              pageSkippedCount++;
              continue;
            }

            companionsToCommit.add(
              WordMapper.toCompanion(
                mappedUpdated.getOrElse(
                  (_) => throw StateError(
                    'Mapped updated word unexpectedly missing',
                  ),
                ),
                includeServerTimestamp: true,
              ),
            );
            pageMergedCount++;
          } else {
            pageSkippedCount++;
          }
        }

        try {
          if (companionsToCommit.isNotEmpty) {
            // Commit this page atomically; partial page writes are not allowed.
            await _localSource.saveWordsInTransaction(companionsToCommit);
          }
        } catch (e, stackTrace) {
          _logger.error(
            'Pull transaction failed at cursor ($cursorTime, $cursorId)',
            e,
            stackTrace,
          );
          try {
            await Sentry.captureException(e, stackTrace: stackTrace);
          } catch (_) {}
          return const Left(SyncFailure('Pull transaction failed'));
        }

        newCount += pageNewCount;
        mergedCount += pageMergedCount;
        skippedCount += pageSkippedCount;

        cursorTime = paginatedData.nextCursorTime;
        cursorId = paginatedData.nextCursorId;
        if (cursorTime == null || cursorId == null) {
          break;
        }
      }

      // Only advance pull cursor after all page transactions succeeded.
      await _preferences.setLastPullTimestamp(userId, now);
      _logger.syncEvent(
        'Successfully completed pull sync: $newCount new, $mergedCount merged, $skippedCount skipped',
      );
      return Right(newCount + mergedCount);
    } catch (e, stackTrace) {
      // No force-cast: map safely, then normalize to sync-domain failure.
      return Left(_mapSyncFailure(e, stackTrace));
    }
  }
}
