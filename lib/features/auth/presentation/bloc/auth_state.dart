import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';

/// Auth BLoC states

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// OTP sent state
class AuthOtpSent extends AuthState {
  final String email;

  const AuthOtpSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// OTP verified, but user needs to complete profile
class AuthNeedsRegistration extends AuthState {
  final String email;

  const AuthNeedsRegistration(this.email);

  @override
  List<Object?> get props => [email];
}

/// Authenticated state
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Error state
class AuthError extends AuthState {
  final Failure failure;
  final AuthState? previousState;

  const AuthError({
    required this.failure,
    this.previousState,
  });

  @override
  List<Object?> get props => [failure, previousState];
}

/// OTP resent state
class AuthOtpResent extends AuthState {
  final String email;

  const AuthOtpResent(this.email);

  @override
  List<Object?> get props => [email];
}
