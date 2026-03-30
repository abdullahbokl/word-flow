import 'package:injectable/injectable.dart';
import 'package:word_flow/core/database/app_database.dart';

abstract class SyncDeadLetterSource {
  Future<void> addDeadLetter({
    required String wordId,
    required String wordText,
    required String operation,
    required String lastError,
    required DateTime failedAt,
  });

  Future<List<SyncDeadLetter>> getDeadLetters();
  Future<SyncDeadLetter?> getDeadLetterById(int id);
  Future<void> acknowledgeDeadLetter(int id);
  Stream<int> watchDeadLetterCount();
}

@LazySingleton(as: SyncDeadLetterSource)
class SyncDeadLetterSourceImpl implements SyncDeadLetterSource {
  SyncDeadLetterSourceImpl(this._db);

  final WordFlowDatabase _db;

  @override
  Future<void> addDeadLetter({
    required String wordId,
    required String wordText,
    required String operation,
    required String lastError,
    required DateTime failedAt,
  }) {
    return _db.insertDeadLetter(
      wordId: wordId,
      wordText: wordText,
      operation: operation,
      lastError: lastError,
      failedAt: failedAt,
    );
  }

  @override
  Future<List<SyncDeadLetter>> getDeadLetters() {
    return _db.getUnacknowledgedDeadLetters();
  }

  @override
  Future<SyncDeadLetter?> getDeadLetterById(int id) {
    return _db.getDeadLetterById(id);
  }

  @override
  Future<void> acknowledgeDeadLetter(int id) {
    return _db.acknowledgeDeadLetter(id);
  }

  @override
  Stream<int> watchDeadLetterCount() {
    return _db.watchUnacknowledgedDeadLetterCount();
  }
}
