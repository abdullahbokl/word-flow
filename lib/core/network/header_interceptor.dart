import 'package:dio/dio.dart';
import 'package:word_flow/core/config/env_config.dart';

class HeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['apikey'] = EnvConfig.supabaseAnonKey;
    options.headers['Content-Type'] = 'application/json';
    options.headers['Prefer'] = 'return=representation';
    super.onRequest(options, handler);
  }
}
