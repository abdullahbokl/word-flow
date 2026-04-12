import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';

class BackupMetadata {
  final DateTime modifiedTime;
  final int size;
  const BackupMetadata({required this.modifiedTime, required this.size});
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
