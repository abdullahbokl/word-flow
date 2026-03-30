import 'dart:convert';
import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:word_flow/core/security/security_service.dart';

@lazySingleton
class DatabaseKeyManager {
  DatabaseKeyManager(this._securityService);

  static const String _keyName = 'wordflow_database_key';
  final SecurityService _securityService;

  Future<String> getOrCreateKey() async {
    final result = await _securityService.read(key: _keyName);
    
    return result.fold(
      (failure) => _generateAndStoreKey(),
      (key) {
        if (key != null && key.isNotEmpty) {
          return key;
        } else {
          return _generateAndStoreKey();
        }
      },
    );
  }

  Future<String> _generateAndStoreKey() async {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final newKey = base64UrlEncode(values);
    
    final writeResult = await _securityService.write(key: _keyName, value: newKey);
    return writeResult.fold(
      (failure) => newKey, // Fallback: return the key even if persistence failed
      (_) => newKey,
    );
  }
}
