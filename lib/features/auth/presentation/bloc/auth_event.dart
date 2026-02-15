import 'package:equatable/equatable.dart';

/// Auth BLoC events

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status on app start
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Send OTP to email
class AuthOtpRequested extends AuthEvent {
  final String email;

  const AuthOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Verify OTP code
class AuthOtpVerified extends AuthEvent {
  final String email;
  final String code;

  const AuthOtpVerified({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [email, code];
}

/// Complete profile (register)
class AuthCompleteProfileRequested extends AuthEvent {
  final String email;
  final String fullName;
  final String? phone;

  const AuthCompleteProfileRequested({
    required this.email,
    required this.fullName,
    this.phone,
  });

  @override
  List<Object?> get props => [email, fullName, phone];
}

/// Logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Upgrade to seller
class AuthUpgradeToSellerRequested extends AuthEvent {
  const AuthUpgradeToSellerRequested();
}

/// Update profile
class AuthProfileUpdateRequested extends AuthEvent {
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String? language;

  const AuthProfileUpdateRequested({
    this.fullName,
    this.email,
    this.avatarUrl,
    this.language,
  });

  @override
  List<Object?> get props => [fullName, email, avatarUrl, language];
}

/// Resend OTP
class AuthOtpResendRequested extends AuthEvent {
  final String email;

  const AuthOtpResendRequested(this.email);

  @override
  List<Object?> get props => [email];
}
