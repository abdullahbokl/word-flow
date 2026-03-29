import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/sync_repository.dart';

@lazySingleton
class WatchPendingCount extends BaseStreamUseCase<int, NoParams> {
  WatchPendingCount(this._repository);
  final SyncRepository _repository;

  @override
  Stream<Either<Failure, int>> call(NoParams params) {
    return _repository.watchPendingCount().map((count) => Right(count));
  }
}
