import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/security/security_service.dart';

@LazySingleton(as: SecurityService)
class SecureStorageService implements SecurityService {
  SecureStorageService(@Named('secure_storage') this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<Either<Failure, Unit>> write({
    required String key,
    required String value,
  }) async {
    try {
      await _storage.write(key: key, value: value);
      return right(unit);
    } catch (e) {
      return left(SecurityFailure('Failed to write to secure storage: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> read({required String key}) async {
    try {
      final value = await _storage.read(key: key);
      return right(value);
    } catch (e) {
      return left(SecurityFailure('Failed to read from secure storage: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
      return right(unit);
    } catch (e) {
      return left(SecurityFailure('Failed to delete from secure storage: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAll() async {
    try {
      await _storage.deleteAll();
      return right(unit);
    } catch (e) {
      return left(SecurityFailure('Failed to clear secure storage: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> containsKey({required String key}) async {
    try {
      final exists = await _storage.containsKey(key: key);
      return right(exists);
    } catch (e) {
      return left(SecurityFailure('Failed to check secure storage key: $e'));
    }
  }
}
