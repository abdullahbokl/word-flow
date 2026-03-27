import 'package:injectable/injectable.dart';
import '../../../../core/database/app_database.dart';

abstract class SyncLocalSource {
  Future<void> enqueueSyncOperation(String wordId, String operation);
  Future<List<Map<String, dynamic>>> getSyncQueue(int limit);
  Future<void> removeFromSyncQueue(int queueId);
  Future<void> updateSyncQueueRetry(int queueId, String error);
  Future<int> getSyncQueueCount();
  Stream<int> watchSyncQueueCount();
  Future<void> clearOrphanedSyncEntries();
}

@LazySingleton(as: SyncLocalSource)
class SyncLocalSourceImpl implements SyncLocalSource {
  final WordFlowDatabase _db;

  SyncLocalSourceImpl(this._db);

  @override
  Future<void> enqueueSyncOperation(String wordId, String operation) async {
    await _db.enqueueSyncOperation(wordId, operation);
  }

  @override
  Future<List<Map<String, dynamic>>> getSyncQueue(int limit) async {
    final rows = await _db.getSyncQueue(limit);
    return rows
        .map((r) => <String, dynamic>{
              'id': r.id,
              'word_id': r.wordId,
              'operation': r.operation,
              'retry_count': r.retryCount,
              'last_error': r.lastError,
              'created_at': r.createdAt.toUtc().toIso8601String(),
            })
        .toList(growable: false);
  }

  @override
  Future<void> removeFromSyncQueue(int queueId) async {
    await _db.removeFromSyncQueue(queueId);
  }

  @override
  Future<void> updateSyncQueueRetry(int queueId, String error) async {
    await _db.updateSyncQueueRetry(queueId, error);
  }

  @override
  Future<int> getSyncQueueCount() async {
    return _db.getPendingSyncCount();
  }

  @override
  Stream<int> watchSyncQueueCount() {
    return _db.watchPendingSyncCount();
  }

  @override
  Future<void> clearOrphanedSyncEntries() async {
    await _db.clearOrphanedSyncEntries();
  }
}
