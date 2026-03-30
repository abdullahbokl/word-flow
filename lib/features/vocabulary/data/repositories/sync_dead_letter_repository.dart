import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_dead_letter_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';

@lazySingleton
class SyncDeadLetterRepository {
  SyncDeadLetterRepository(this._deadLetterSource, this._syncSource);

  final SyncDeadLetterSource _deadLetterSource;
  final SyncLocalSource _syncSource;

  Future<Either<Failure, List<SyncDeadLetter>>> getDeadLetters() async {
    try {
      final items = await _deadLetterSource.getDeadLetters();
      return Right(items);
    } catch (e) {
      return Left(SyncFailure(e.toString()));
    }
  }

  Stream<int> watchDeadLetterCount() {
    return _deadLetterSource.watchDeadLetterCount();
  }

  Future<Either<Failure, Unit>> acknowledgeDeadLetter(int id) async {
    try {
      await _deadLetterSource.acknowledgeDeadLetter(id);
      return const Right(unit);
    } catch (e) {
      return Left(SyncFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> requeueDeadLetter(int id) async {
    try {
      final item = await _deadLetterSource.getDeadLetterById(id);
      if (item == null) {
        return const Left(SyncFailure('Dead letter item not found'));
      }

      await _syncSource.enqueueSyncOperation(item.wordId, item.operation);
      await _deadLetterSource.acknowledgeDeadLetter(id);
      return const Right(unit);
    } catch (e) {
      return Left(SyncFailure(e.toString()));
    }
  }
}
