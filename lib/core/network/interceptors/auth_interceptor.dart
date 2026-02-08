import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Interceptor to add authentication headers

class AuthInterceptor extends Interceptor {
  final SupabaseClient _supabase;

  AuthInterceptor({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = _supabase.auth.currentSession;

    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      try {
        final response = await _supabase.auth.refreshSession();
        if (response.session != null) {
          // Retry the request with new token
          final options = err.requestOptions;
          options.headers['Authorization'] =
              'Bearer ${response.session!.accessToken}';

          final dio = Dio();
          final retryResponse = await dio.fetch(options);
          handler.resolve(retryResponse);
          return;
        }
      } catch (_) {
        // Token refresh failed, let the error propagate
      }
    }

    handler.next(err);
  }
}
