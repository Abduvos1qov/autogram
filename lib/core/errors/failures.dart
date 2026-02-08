import 'package:equatable/equatable.dart';

/// Failure classes for Either pattern (dartz)
/// Used to represent left side of Either in clean architecture

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    super.message = 'Server error occurred',
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
    super.code,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed',
    super.code,
  });
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Validation failed',
    super.code,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

class NotFoundFailure extends Failure {
  final String? resource;

  const NotFoundFailure({
    super.message = 'Resource not found',
    super.code,
    this.resource,
  });

  @override
  List<Object?> get props => [message, code, resource];
}

class PermissionFailure extends Failure {
  final String? permission;

  const PermissionFailure({
    super.message = 'Permission denied',
    super.code,
    this.permission,
  });

  @override
  List<Object?> get props => [message, code, permission];
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timeout',
    super.code,
  });
}

class RateLimitFailure extends Failure {
  final int? retryAfter;

  const RateLimitFailure({
    super.message = 'Too many requests',
    super.code,
    this.retryAfter,
  });

  @override
  List<Object?> get props => [message, code, retryAfter];
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unknown error occurred',
    super.code,
  });
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred',
    super.code,
  });
}
