import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/word_local_source.dart';
import '../datasources/word_remote_source.dart';
import '../datasources/sync_local_source.dart';

@LazySingleton(as: SyncRepository)
class SyncRepositoryImpl implements SyncRepository {
  final WordLocalSource _localSource;
  final SyncLocalSource _syncSource;
  final WordRemoteSource _remoteSource;

  SyncRepositoryImpl(this._localSource, this._syncSource, this._remoteSource);

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
      final queueItems = await _syncSource.getSyncQueue(20);
      int successCount = 0;

      for (final item in queueItems) {
        final wordId = item['word_id'] as String;
        final operation = item['operation'] as String;
        final queueId = item['id'] as int;
        final retryCount = item['retry_count'] as int? ?? 0;

        if (retryCount > 5) continue;

        try {
          if (operation == 'upsert') {
            final word = await _localSource.getWordById(wordId);
            if (word != null) await _remoteSource.upsertWord(word);
          } else if (operation == 'delete') {
            await _remoteSource.deleteWord(wordId);
          }
          await _syncSource.removeFromSyncQueue(queueId);
          successCount++;
        } catch (e) {
          await _syncSource.updateSyncQueueRetry(queueId, e.toString());
        }
      }
      return Right(successCount);
    } catch (e) {
      return Left(SyncFailure(e.toString()));
    }
  }
}
