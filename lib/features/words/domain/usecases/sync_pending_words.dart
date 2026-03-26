import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/sync_repository.dart';

@lazySingleton
class SyncPendingWords {
  final SyncRepository _repository;

  SyncPendingWords(this._repository);

  Future<Either<Failure, int>> call() {
    return _repository.syncPendingWords();
  }
}
