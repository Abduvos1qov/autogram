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

  /// Set username for current user
  Future<Either<Failure, User>> setUsername({required String username});

  /// Check if username is available
  Future<Either<Failure, bool>> checkUsernameAvailability({
    required String username,
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
