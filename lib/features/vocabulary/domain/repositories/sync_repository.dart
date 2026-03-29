import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';

abstract class SyncRepository {
  Future<Either<Failure, int>> getPendingCount();
  Stream<int> watchPendingCount();
  Future<Either<Failure, int>> syncPendingWords();
  Future<Either<Failure, int>> pullRemoteChanges(String userId);
}
