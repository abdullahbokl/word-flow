import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/error/exceptions.dart';
import 'package:word_flow/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteSource {
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Stream<UserEntity?> get userStream;
}

@LazySingleton(as: AuthRemoteSource)
class AuthRemoteSourceImpl implements AuthRemoteSource {

  AuthRemoteSourceImpl(this._supabaseClient);
  final supabase.SupabaseClient _supabaseClient;

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw AuthException('Signed in but user data is missing.');
      }
      return UserEntity(
        id: response.user!.id,
        email: response.user!.email!,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw AuthException('Signed up but user data is missing.');
      }
      return UserEntity(
        id: response.user!.id,
        email: response.user!.email!,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Stream<UserEntity?> get userStream {
    return _supabaseClient.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return UserEntity(id: user.id, email: user.email!);
    });
  }
}
