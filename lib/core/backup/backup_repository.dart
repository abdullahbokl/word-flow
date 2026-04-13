import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';

class BackupMetadata {
  const BackupMetadata({required this.modifiedTime, required this.size});
  final DateTime modifiedTime;
  final int size;
}

abstract class BackupRepository {
  Future<Either<Failure, Unit>> connect();
  Future<Either<Failure, Unit>> backup();
  Future<Either<Failure, Unit>> restore();
  Future<Either<Failure, BackupMetadata?>> getBackupMetadata();
  Future<bool> isAuthenticated();
  Future<void> signOut();
  Future<String?> getConnectedEmail();
}
