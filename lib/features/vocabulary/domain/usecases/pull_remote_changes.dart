import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/sync_repository.dart';

@lazySingleton
class PullRemoteChanges {
  PullRemoteChanges(this._repository);

  final SyncRepository _repository;

  Future<Either<Failure, int>> call(String userId) async {
    return _repository.pullRemoteChanges(userId);
  }
}
