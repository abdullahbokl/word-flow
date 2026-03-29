import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/sync_repository.dart';
import 'package:word_flow/core/usecases/usecase.dart';

@lazySingleton
class SyncPendingWords extends BaseUseCase<int, NoParams> {
  SyncPendingWords(this._repository);
  final SyncRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return _repository.syncPendingWords();
  }
}
