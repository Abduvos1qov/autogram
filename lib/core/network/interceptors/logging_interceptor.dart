import 'package:dio/dio.dart';

import '../../utils/logger.dart';

/// Interceptor for logging HTTP requests and responses

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('┌─────────────────────────────────────────────────');
    AppLogger.debug('│ REQUEST: ${options.method} ${options.uri}');
    AppLogger.debug('│ Headers: ${options.headers}');
    if (options.data != null) {
      AppLogger.debug('│ Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      AppLogger.debug('│ Query: ${options.queryParameters}');
    }
    AppLogger.debug('└─────────────────────────────────────────────────');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug('┌─────────────────────────────────────────────────');
    AppLogger.debug(
      '│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
    );
    AppLogger.debug('│ Data: ${response.data}');
    AppLogger.debug('└─────────────────────────────────────────────────');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('┌─────────────────────────────────────────────────');
    AppLogger.error(
      '│ ERROR: ${err.response?.statusCode ?? 'N/A'} ${err.requestOptions.uri}',
    );
    AppLogger.error('│ Message: ${err.message}');
    if (err.response?.data != null) {
      AppLogger.error('│ Data: ${err.response?.data}');
    }
    AppLogger.error('└─────────────────────────────────────────────────');

    handler.next(err);
  }
}
