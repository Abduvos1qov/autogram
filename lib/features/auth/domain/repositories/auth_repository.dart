import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Auth repository interface - defines contract for auth operations

abstract class AuthRepository {
  /// Sign up with email and password
  Future<Either<Failure, void>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    DateTime? dateOfBirth,
  });

  /// Sign in with email and password
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  /// Send password reset email
  Future<Either<Failure, void>> resetPassword({required String email});

  /// Verify OTP code after sign-up
  Future<Either<Failure, User>> verifyOtp({
    required String email,
    required String otp,
  });

  /// Resend sign-up OTP
  Future<Either<Failure, void>> resendSignUpOtp({required String email});

  /// Send OTP for forgot password
  Future<Either<Failure, void>> sendForgotPasswordOtp({
    required String email,
  });

  /// Verify forgot password OTP
  Future<Either<Failure, void>> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  });

  /// Reset password with new password after OTP verification
  Future<Either<Failure, void>> resetPasswordWithNew({
    required String email,
    required String newPassword,
  });

  /// Set username for current user
  Future<Either<Failure, User>> setUsername({required String username});

  /// Check if username is available
  Future<Either<Failure, bool>> checkUsernameAvailability({
    required String username,
  });

  /// Get current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get auth state stream
  Stream<User?> get authStateChanges;
}
