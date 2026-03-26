import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class SyncRepository {
  Future<Either<Failure, int>> getPendingCount();
  Future<Either<Failure, int>> syncPendingWords();
}
