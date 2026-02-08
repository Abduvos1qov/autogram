import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Auth repository interface - defines contract for auth operations

abstract class AuthRepository {
  /// Send OTP to phone number
  Future<Either<Failure, void>> sendOtp(String phone);

  /// Verify OTP code
  Future<Either<Failure, User?>> verifyOtp({
    required String phone,
    required String code,
  });

  /// Register new user
  Future<Either<Failure, User>> register({
    required String phone,
    required String fullName,
    String? email,
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
