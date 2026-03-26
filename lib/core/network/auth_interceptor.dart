import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor extends Interceptor {
  final SupabaseClient _supabaseClient;

  AuthInterceptor(this._supabaseClient);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = _supabaseClient.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    super.onRequest(options, handler);
  }
}
