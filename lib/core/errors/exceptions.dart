/// Custom exceptions for the app

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Server error occurred',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache error occurred'});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Network error occurred'});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({
    this.message = 'Authentication error occurred',
    this.code,
  });

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationException({
    this.message = 'Validation error occurred',
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

class StorageException implements Exception {
  final String message;

  const StorageException({this.message = 'Storage error occurred'});

  @override
  String toString() => 'StorageException: $message';
}

class PermissionException implements Exception {
  final String message;
  final String? permission;

  const PermissionException({
    this.message = 'Permission denied',
    this.permission,
  });

  @override
  String toString() => 'PermissionException: $message';
}

class NotFoundException implements Exception {
  final String message;
  final String? resource;

  const NotFoundException({
    this.message = 'Resource not found',
    this.resource,
  });

  @override
  String toString() => 'NotFoundException: $message';
}

class TimeoutException implements Exception {
  final String message;

  const TimeoutException({this.message = 'Request timeout'});

  @override
  String toString() => 'TimeoutException: $message';
}

class RateLimitException implements Exception {
  final String message;
  final int? retryAfter;

  const RateLimitException({
    this.message = 'Rate limit exceeded',
    this.retryAfter,
  });

  @override
  String toString() => 'RateLimitException: $message';
}
