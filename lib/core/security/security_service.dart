import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';

abstract class SecurityService {
  /// Persists a sensitive value securely.
  Future<Either<Failure, Unit>> write({required String key, required String value});

  /// Retrieves a sensitive value from secure storage.
  Future<Either<Failure, String?>> read({required String key});

  /// Removes a value from secure storage.
  Future<Either<Failure, Unit>> delete({required String key});

  /// Clears all secure storage entries.
  Future<Either<Failure, Unit>> deleteAll();

  /// Checks if a key exists in secure storage.
  Future<Either<Failure, bool>> containsKey({required String key});
}
