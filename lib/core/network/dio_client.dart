import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'header_interceptor.dart';

@lazySingleton
class DioClient {
  final SupabaseClient _supabaseClient;
  late final Dio _dio;

  DioClient(this._supabaseClient) {
    _dio = Dio(BaseOptions(
      baseUrl: '${EnvConfig.supabaseUrl}/rest/v1/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.addAll([
      HeaderInterceptor(),
      AuthInterceptor(_supabaseClient),
      ErrorInterceptor(),
    ]);
  }

  Dio get instance => _dio;
}
