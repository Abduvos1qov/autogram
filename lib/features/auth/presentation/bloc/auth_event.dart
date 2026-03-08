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

/// Sign in with email and password
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Sign up with email and password
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final DateTime? dateOfBirth;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
    this.dateOfBirth,
  });

  @override
  List<Object?> get props => [email, password, fullName, phone, dateOfBirth];
}

/// Send password reset email
class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Submit username
class AuthUsernameSubmitted extends AuthEvent {
  final String username;

  const AuthUsernameSubmitted(this.username);

  @override
  List<Object?> get props => [username];
}

/// Verify OTP code after sign-up
class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthVerifyOtpRequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

/// Resend OTP code
class AuthResendOtpRequested extends AuthEvent {
  final String email;

  const AuthResendOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Send OTP for forgot password
class AuthForgotPasswordOtpRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Verify OTP for forgot password
class AuthVerifyForgotPasswordOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthVerifyForgotPasswordOtpRequested({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

/// Set new password after forgot password OTP verification
class AuthResetPasswordWithNewPassword extends AuthEvent {
  final String email;
  final String newPassword;

  const AuthResetPasswordWithNewPassword({
    required this.email,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, newPassword];
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
