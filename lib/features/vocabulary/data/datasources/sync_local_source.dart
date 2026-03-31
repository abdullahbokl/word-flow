import 'package:injectable/injectable.dart';
import 'package:word_flow/core/database/app_database.dart';

abstract class SyncLocalSource {
  Future<void> enqueueSyncOperation(String wordId, String operation);
  Future<List<WordSyncQueueData>> getSyncQueue(int limit);
  Future<void> removeFromSyncQueue(int queueId);
  Future<void> updateSyncQueueRetry(int queueId, String error);
  Future<int> getSyncQueueCount();
  Stream<int> watchSyncQueueCount();
  Future<void> clearOrphanedSyncEntries();
}

@LazySingleton(as: SyncLocalSource)
class SyncLocalSourceImpl implements SyncLocalSource {
  SyncLocalSourceImpl(this._db);
  final WordFlowDatabase _db;

  @override
  Future<void> enqueueSyncOperation(String wordId, String operation) async {
    await _db.enqueueSyncOperation(wordId, operation);
  }

  @override
  Future<List<WordSyncQueueData>> getSyncQueue(int limit) =>
      _db.getSyncQueue(limit);

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
