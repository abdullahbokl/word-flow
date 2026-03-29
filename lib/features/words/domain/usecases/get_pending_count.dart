import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/repositories/sync_repository.dart';

@lazySingleton
class GetPendingCount {

  GetPendingCount(this._repository);
  final SyncRepository _repository;

  Future<Either<Failure, int>> call() {
    return _repository.getPendingCount();
  }
}
