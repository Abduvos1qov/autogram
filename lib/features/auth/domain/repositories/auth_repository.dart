import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Auth repository interface - defines contract for auth operations

abstract class AuthRepository {
  /// Send OTP to email
  Future<Either<Failure, void>> sendOtp({required String email});

  /// Verify OTP code
  Future<Either<Failure, User?>> verifyOtp({
    required String email,
    required String code,
  });

  /// Complete profile after OTP verification
  Future<Either<Failure, User>> completeProfile({
    required String fullName,
    String? phone,
  });

  /// Get current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? fullName,
    String? email,
    String? avatarUrl,
    String? language,
  });

  /// Upgrade to seller role
  Future<Either<Failure, User>> upgradeToSeller();

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get auth state stream
  Stream<User?> get authStateChanges;
}
