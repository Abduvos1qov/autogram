import 'package:logger/logger.dart';

import '../config/env_config.dart';

/// App-wide logger utility

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: EnvConfig.enableLogging ? Level.debug : Level.warning,
  );

  AppLogger._();

  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (EnvConfig.enableLogging) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (EnvConfig.enableLogging) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  static void warning(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // Network logging
  static void network(String method, String url, {dynamic data}) {
    if (EnvConfig.enableLogging) {
      _logger.d('[$method] $url\n${data ?? ''}');
    }
  }

  // Event logging
  static void event(String name, {Map<String, dynamic>? parameters}) {
    if (EnvConfig.enableLogging) {
      _logger.i('EVENT: $name ${parameters ?? ''}');
    }
  }
}
