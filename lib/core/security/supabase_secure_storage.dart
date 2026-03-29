import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_flow/core/security/security_service.dart';

class SupabaseSecureStorage extends LocalStorage {
  SupabaseSecureStorage(this._securityService);

  final SecurityService _securityService;

  static const _supabaseSessionKey = 'supabase_session';

  @override
  Future<void> initialize() async {
    // No initialization needed for SecureStorage
  }

  @override
  Future<String?> accessToken() async {
    final result = await _securityService.read(key: _supabaseSessionKey);
    return result.getOrElse((_) => null);
  }

  @override
  Future<bool> hasAccessToken() async {
    final result = await _securityService.containsKey(key: _supabaseSessionKey);
    return result.getOrElse((_) => false);
  }

  @override
  Future<void> removePersistedSession() async {
    await _securityService.delete(key: _supabaseSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _securityService.write(
      key: _supabaseSessionKey,
      value: persistSessionString,
    );
  }
}
