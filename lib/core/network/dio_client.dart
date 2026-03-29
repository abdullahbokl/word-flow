import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_flow/core/config/env_config.dart';
import 'package:word_flow/core/network/auth_interceptor.dart';
import 'package:word_flow/core/network/error_interceptor.dart';
import 'package:word_flow/core/network/header_interceptor.dart';

@lazySingleton
class DioClient {

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
  final SupabaseClient _supabaseClient;
  late final Dio _dio;

  Dio get instance => _dio;
}
