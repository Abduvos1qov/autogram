import 'dart:io';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException, Headers;

import 'exceptions.dart';
import 'failures.dart';

/// Global error handler for converting exceptions to failures

class ErrorHandler {
  ErrorHandler._();

  /// Convert any exception to a Failure
  static Failure handleException(dynamic exception) {
    if (exception is Failure) {
      return exception;
    }

    if (exception is DioException) {
      return _handleDioException(exception);
    }

    if (exception is AuthException) {
      return AuthFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is PostgrestException) {
      return _handlePostgrestException(exception);
    }

    if (exception is StorageException) {
      return ServerFailure(
        message: exception.message,
        code: exception.message,
      );
    }

    if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    }

    if (exception is CacheException) {
      return CacheFailure(message: exception.message);
    }

    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    }

    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        fieldErrors: exception.fieldErrors,
      );
    }

    if (exception is NotFoundException) {
      return NotFoundFailure(
        message: exception.message,
        resource: exception.resource,
      );
    }

    if (exception is PermissionException) {
      return PermissionFailure(
        message: exception.message,
        permission: exception.permission,
      );
    }

    if (exception is SocketException) {
      return const NetworkFailure(message: 'No internet connection');
    }

    if (exception is FormatException) {
      return ServerFailure(
        message: 'Invalid data format: ${exception.message}',
      );
    }

    return UnknownFailure(
      message: exception.toString(),
    );
  }

  static Failure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        return _handleBadResponse(exception.response);

      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'Request cancelled');

      case DioExceptionType.unknown:
        if (exception.error is SocketException) {
          return const NetworkFailure();
        }
        return UnknownFailure(message: exception.message ?? 'Unknown error');

      default:
        return UnknownFailure(message: exception.message ?? 'Unknown error');
    }
  }

  static Failure _handleBadResponse(Response? response) {
    if (response == null) {
      return const ServerFailure();
    }

    final statusCode = response.statusCode ?? 500;
    final data = response.data;
    String message = 'Server error';

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ValidationFailure(message: message);
      case 401:
        return AuthFailure(message: message);
      case 403:
        return const PermissionFailure();
      case 404:
        return NotFoundFailure(message: message);
      case 429:
        return RateLimitFailure(
          message: message,
          retryAfter: _parseRetryAfter(response.headers),
        );
      case >= 500:
        return ServerFailure(message: message, statusCode: statusCode);
      default:
        return ServerFailure(message: message, statusCode: statusCode);
    }
  }

  static Failure _handlePostgrestException(PostgrestException exception) {
    final code = exception.code;
    final message = exception.message;

    // Handle common Postgres error codes
    switch (code) {
      case '23505': // unique_violation
        return ValidationFailure(
          message: 'This record already exists',
          code: code,
        );
      case '23503': // foreign_key_violation
        return ValidationFailure(
          message: 'Referenced record not found',
          code: code,
        );
      case '23502': // not_null_violation
        return ValidationFailure(
          message: 'Required field is missing',
          code: code,
        );
      case 'PGRST116': // not found
        return NotFoundFailure(message: message);
      default:
        return ServerFailure(message: message, code: code);
    }
  }

  static int? _parseRetryAfter(Headers headers) {
    final retryAfter = headers.value('retry-after');
    if (retryAfter != null) {
      return int.tryParse(retryAfter);
    }
    return null;
  }

  /// Get user-friendly error message
  static String getUserMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Internet aloqasi yo\'q. Iltimos, ulanishingizni tekshiring.';
    }

    if (failure is TimeoutFailure) {
      return 'So\'rov vaqti tugadi. Qaytadan urinib ko\'ring.';
    }

    if (failure is AuthFailure) {
      return 'Autentifikatsiya xatosi. Qaytadan kiring.';
    }

    if (failure is PermissionFailure) {
      return 'Sizda bu amalni bajarish huquqi yo\'q.';
    }

    if (failure is NotFoundFailure) {
      return 'Ma\'lumot topilmadi.';
    }

    if (failure is RateLimitFailure) {
      return 'Juda ko\'p so\'rov. Biroz kuting.';
    }

    if (failure is ValidationFailure) {
      return failure.message;
    }

    if (failure is ServerFailure) {
      return 'Server xatosi yuz berdi. Keyinroq urinib ko\'ring.';
    }

    return 'Noma\'lum xato yuz berdi.';
  }
}
