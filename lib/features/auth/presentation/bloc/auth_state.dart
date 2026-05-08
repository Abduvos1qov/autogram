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
///
/// Loading messages are no longer carried on the state — the UI decides which
/// `auth.loading.*` translation key to render based on its own context. Keeps
/// the bloc free of user-facing strings.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Sign up successful, needs email verification
class AuthSignUpSuccess extends AuthState {
  final String email;

  const AuthSignUpSuccess(this.email);

  @override
  List<Object?> get props => [email];
}

/// Authenticated but needs to set username
class AuthNeedsUsername extends AuthState {
  final User user;

  const AuthNeedsUsername(this.user);

  @override
  List<Object?> get props => [user];
}

/// Authenticated state
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Password reset email sent
class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// OTP sent for forgot password
class AuthForgotPasswordOtpSent extends AuthState {
  final String email;

  const AuthForgotPasswordOtpSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Forgot password OTP verified, ready for new password
class AuthForgotPasswordOtpVerified extends AuthState {
  final String email;

  const AuthForgotPasswordOtpVerified(this.email);

  @override
  List<Object?> get props => [email];
}

/// Password reset successful
class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

/// Error state
class AuthError extends AuthState {
  final Failure failure;

  const AuthError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
