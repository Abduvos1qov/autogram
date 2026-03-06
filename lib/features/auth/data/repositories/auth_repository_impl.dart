import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Auth repository implementation

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    DateTime? dateOfBirth,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );

      await _localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.resetPassword(email: email);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, User>> setUsername({
    required String username,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await _remoteDataSource.setUsername(username: username);
      await _localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUsernameAvailability({
    required String username,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final isAvailable =
          await _remoteDataSource.checkUsernameAvailability(username: username);
      return Right(isAvailable);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // First try remote
      if (await _networkInfo.isConnected) {
        final user = await _remoteDataSource.getCurrentUser();
        if (user != null) {
          await _localDataSource.cacheUser(user);
          return Right(user);
        }
      }

      // Fall back to cache
      final cachedUser = await _localDataSource.getCachedUser();
      return Right(cachedUser);
    } catch (e) {
      // On error, try cache
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? fullName,
    String? email,
    String? avatarUrl,
    String? language,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await _remoteDataSource.updateProfile(
        fullName: fullName,
        email: email,
        avatarUrl: avatarUrl,
        language: language,
      );

      await _localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, User>> upgradeToSeller() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await _remoteDataSource.upgradeToSeller();
      await _localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearUserCache();
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final result = await getCurrentUser();
    return result.fold(
      (failure) => false,
      (user) => user != null,
    );
  }

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;
}
