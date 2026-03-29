import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/core/sync/sync_operation.dart';
import 'package:word_flow/features/words/domain/repositories/sync_repository.dart';
import 'package:word_flow/features/words/data/datasources/word_local_source.dart';
import 'package:word_flow/features/words/data/datasources/word_remote_source.dart';
import 'package:word_flow/features/words/data/datasources/sync_local_source.dart';

@LazySingleton(as: SyncRepository)
class SyncRepositoryImpl implements SyncRepository {

  SyncRepositoryImpl(this._localSource, this._syncSource, this._remoteSource);
  final WordLocalSource _localSource;
  final SyncLocalSource _syncSource;
  final WordRemoteSource _remoteSource;

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
        final wordId = item.wordId;
        final operation = SyncOperation.fromString(item.operation);
        final queueId = item.id;
        final retryCount = item.retryCount;

        if (retryCount > 5) continue;

        try {
          switch (operation) {
            case SyncOperation.upsert:
              final word = await _localSource.getWordById(wordId);
              if (word != null) await _remoteSource.upsertWord(word);
              break;
            case SyncOperation.delete:
              await _remoteSource.deleteWord(wordId);
              break;
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
