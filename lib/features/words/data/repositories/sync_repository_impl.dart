import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/word_local_source.dart';
import '../datasources/word_remote_source.dart';

@LazySingleton(as: SyncRepository)
class SyncRepositoryImpl implements SyncRepository {
  final WordLocalSource _localSource;
  final WordRemoteSource _remoteSource;

  SyncRepositoryImpl(this._localSource, this._remoteSource);

  @override
  Future<Either<Failure, int>> getPendingCount() async {
    try {
      final count = await _localSource.getSyncQueueCount();
      return Right(count);
    } catch (e) {
      return Left(SyncFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> syncPendingWords() async {
    try {
      final queueItems = await _localSource.getSyncQueue(20);
      int successCount = 0;

      for (final item in queueItems) {
        final wordId = item['word_id'] as String;
        final operation = item['operation'] as String;
        final queueId = item['id'] as int;
        final retryCount = item['retry_count'] as int? ?? 0;

        if (retryCount > 5) {
          // Mark as stale and skip auto-sync
          continue;
        }

        try {
          if (operation == 'upsert') {
            final word = await _localSource.getWordById(wordId);
            if (word != null) {
              await _remoteSource.upsertWord(word);
            }
          } else if (operation == 'delete') {
            await _remoteSource.deleteWord(wordId);
          }
          await _localSource.removeFromSyncQueue(queueId);
          successCount++;
        } catch (e) {
          await _localSource.updateSyncQueueRetry(queueId, e.toString());
        }
      }
      return Right(successCount);
    } catch (e) {
      return Left(SyncFailure(e.toString()));
    }
  }
}
