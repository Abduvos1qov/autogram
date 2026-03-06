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
