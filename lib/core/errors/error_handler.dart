import 'dart:io';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthException, StorageException, Headers;

import 'exceptions.dart';
import 'failures.dart';

/// Global error handler for converting exceptions to failures

class ErrorHandler {
  ErrorHandler._();

  /// Supabase auth error messages → Uzbek user messages
  static const _authErrorMessages = <String, String>{
    'Invalid login credentials': 'Noto\'g\'ri email yoki parol',
    'invalid_credentials': 'Noto\'g\'ri email yoki parol',
    'Email not confirmed': 'Email tasdiqlanmagan. Emailingizni tekshiring.',
    'User already registered': 'Bu email allaqachon ro\'yxatdan o\'tgan',
    'user_already_exists': 'Bu foydalanuvchi allaqachon ro\'yxatdan o\'tgan',
    'Invalid Refresh Token': 'Sessiya muddati tugagan. Qaytadan kiring.',
    'Refresh Token Not Found': 'Sessiya muddati tugagan. Qaytadan kiring.',
    'User not found': 'Foydalanuvchi topilmadi',
    'Password should be at least 6 characters':
        'Parol kamida 6 ta belgidan iborat bo\'lishi kerak',
    'For security purposes, you can only request this after':
        'Xavfsizlik uchun biroz kuting va qaytadan urinib ko\'ring.',
    'otp_expired': 'Tasdiqlash kodi muddati tugadi. Yangisini so\'rang.',
  };

  /// Convert any exception to a Failure
  static Failure handleException(dynamic exception) {
    if (exception is Failure) {
      return exception;
    }

    if (exception is DioException) {
      return _handleDioException(exception);
    }

    if (exception is AuthException) {
      return _handleAuthException(exception);
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

  /// Handle custom AuthException with Uzbek message mapping
  static Failure _handleAuthException(AuthException exception) {
    final uzMessage = _mapAuthMessage(exception.message);
    return AuthFailure(
      message: uzMessage,
      code: exception.code,
    );
  }

  /// Map auth error message to Uzbek
  static String _mapAuthMessage(String message) {
    // Direct match
    final direct = _authErrorMessages[message];
    if (direct != null) return direct;

    // Partial match for messages that contain variable parts
    for (final entry in _authErrorMessages.entries) {
      if (message.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    return message;
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
        return AuthFailure(message: _mapAuthMessage(message));
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
        return const ValidationFailure(
          message: 'Bu ma\'lumot allaqachon mavjud',
          code: '23505',
        );
      case '23503': // foreign_key_violation
        return const ValidationFailure(
          message: 'Bog\'langan ma\'lumot topilmadi',
          code: '23503',
        );
      case '23502': // not_null_violation
        return const ValidationFailure(
          message: 'Majburiy maydon to\'ldirilmagan',
          code: '23502',
        );
      case '42501': // insufficient_privilege (RLS)
        return const PermissionFailure(
          message: 'Sizda bu amalni bajarish huquqi yo\'q',
        );
      case 'PGRST116': // not found (.single() returned no rows)
        return const NotFoundFailure(message: 'Ma\'lumot topilmadi');
      case 'PGRST301': // too many rows for .single()
        return ServerFailure(message: message, code: code);
      default:
        return ServerFailure(message: message, code: code);
    }
  }

  /// Map PostgrestException to the correct custom exception.
  /// Used by data sources to throw typed exceptions instead of ServerException.
  static Never throwFromPostgrest(PostgrestException e) {
    final code = e.code;

    switch (code) {
      case '23505':
        throw const ValidationException(
          message: 'Bu ma\'lumot allaqachon mavjud',
        );
      case '23503':
        throw const ValidationException(
          message: 'Bog\'langan ma\'lumot topilmadi',
        );
      case '23502':
        throw const ValidationException(
          message: 'Majburiy maydon to\'ldirilmagan',
        );
      case '42501':
        throw const PermissionException(
          message: 'Sizda bu amalni bajarish huquqi yo\'q',
        );
      case 'PGRST116':
        throw const NotFoundException(message: 'Ma\'lumot topilmadi');
      default:
        throw ServerException(message: e.message);
    }
  }

  /// Map Supabase AuthException (gotrue) to custom AuthException with Uzbek message.
  /// Used by data sources that catch Supabase auth errors.
  static Never throwFromSupabaseAuth(dynamic e) {
    // e is supabase_flutter.AuthException but we can't reference the type
    // directly here due to the `hide` directive
    final message = e.message as String;
    throw AuthException(message: _mapAuthMessage(message));
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
      return _hasCustomMessage(failure.message, 'Authentication failed')
          ? failure.message
          : 'Autentifikatsiya xatosi. Qaytadan kiring.';
    }

    if (failure is PermissionFailure) {
      return _hasCustomMessage(failure.message, 'Permission denied')
          ? failure.message
          : 'Sizda bu amalni bajarish huquqi yo\'q.';
    }

    if (failure is NotFoundFailure) {
      return _hasCustomMessage(failure.message, 'Resource not found')
          ? failure.message
          : 'Ma\'lumot topilmadi.';
    }

    if (failure is RateLimitFailure) {
      return 'Juda ko\'p so\'rov. Biroz kuting.';
    }

    if (failure is ValidationFailure) {
      return _hasCustomMessage(failure.message, 'Validation failed')
          ? failure.message
          : 'Ma\'lumotlarni tekshiring.';
    }

    if (failure is CacheFailure) {
      return 'Ma\'lumotlarni yuklashda xatolik.';
    }

    if (failure is ServerFailure) {
      return _hasCustomMessage(failure.message, 'Server error occurred')
          ? failure.message
          : 'Server xatosi yuz berdi. Keyinroq urinib ko\'ring.';
    }

    return 'Noma\'lum xato yuz berdi.';
  }

  /// Returns true if the message is a custom one (not the English default).
  static bool _hasCustomMessage(String message, String defaultMessage) {
    return message != defaultMessage &&
        message.isNotEmpty &&
        message != 'Server error';
  }
}
