import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/repositories/sync_repository.dart';

@lazySingleton
class SyncPendingWords {

  SyncPendingWords(this._repository);
  final SyncRepository _repository;

  Future<Either<Failure, int>> call() {
    return _repository.syncPendingWords();
  }
}
