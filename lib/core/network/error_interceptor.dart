import 'package:dio/dio.dart';
import '../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode != null) {
      final code = err.response!.statusCode!;
      if (code >= 400 && code < 500) {
        throw AuthException(err.message ?? 'Authentication error');
      } else if (code >= 500) {
        throw ServerException(err.message ?? 'Server error');
      }
    }
    super.onError(err, handler);
  }
}
