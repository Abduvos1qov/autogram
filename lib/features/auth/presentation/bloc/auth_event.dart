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

/// Send OTP to phone
class AuthOtpRequested extends AuthEvent {
  final String phone;

  const AuthOtpRequested(this.phone);

  @override
  List<Object?> get props => [phone];
}

/// Verify OTP code
class AuthOtpVerified extends AuthEvent {
  final String phone;
  final String code;

  const AuthOtpVerified({
    required this.phone,
    required this.code,
  });

  @override
  List<Object?> get props => [phone, code];
}

/// Register new user
class AuthRegisterRequested extends AuthEvent {
  final String phone;
  final String fullName;
  final String? email;

  const AuthRegisterRequested({
    required this.phone,
    required this.fullName,
    this.email,
  });

  @override
  List<Object?> get props => [phone, fullName, email];
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
  final String phone;

  const AuthOtpResendRequested(this.phone);

  @override
  List<Object?> get props => [phone];
}
