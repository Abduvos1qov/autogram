import 'package:dio/dio.dart';

import '../../errors/exceptions.dart';

/// Interceptor to handle and transform API errors

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (response != null) {
      final statusCode = response.statusCode ?? 500;
      final data = response.data;
      String message = 'An error occurred';

      if (data is Map<String, dynamic>) {
        message = data['message'] ?? data['error'] ?? message;
      } else if (data is String) {
        message = data;
      }

      switch (statusCode) {
        case 400:
          throw ValidationException(message: message);
        case 401:
          throw AuthException(message: message, code: 'unauthorized');
        case 403:
          throw PermissionException(message: message);
        case 404:
          throw NotFoundException(message: message);
        case 429:
          throw RateLimitException(
            message: message,
            retryAfter: _parseRetryAfter(response.headers),
          );
        case >= 500:
          throw ServerException(message: message, statusCode: statusCode);
        default:
          throw ServerException(message: message, statusCode: statusCode);
      }
    }

    handler.next(err);
  }

  int? _parseRetryAfter(Headers headers) {
    final retryAfter = headers.value('retry-after');
    if (retryAfter != null) {
      return int.tryParse(retryAfter);
    }
    return null;
  }
}
