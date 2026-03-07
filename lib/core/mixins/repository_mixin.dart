import 'package:dartz/dartz.dart';

import '../errors/error_handler.dart';
import '../errors/failures.dart';
import '../network/network_info.dart';

/// Mixin to reduce boilerplate in repository implementations.
///
/// Provides [safeRemoteCall] for network operations (with connectivity check)
/// and [safeLocalCall] for local/cache operations.
mixin RepositoryMixin {
  /// Execute a remote call with network check and error handling.
  ///
  /// Returns [NetworkFailure] if not connected,
  /// otherwise delegates errors to [ErrorHandler.handleException].
  Future<Either<Failure, T>> safeRemoteCall<T>(
    NetworkInfo networkInfo,
    Future<T> Function() call,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await call();
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  /// Execute a local/cache call with error handling.
  ///
  /// Returns [CacheFailure] on any exception.
  Future<Either<Failure, T>> safeLocalCall<T>(
    Future<T> Function() call,
  ) async {
    try {
      final result = await call();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
