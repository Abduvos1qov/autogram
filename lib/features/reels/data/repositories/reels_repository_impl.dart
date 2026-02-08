import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/reel.dart';
import '../../domain/repositories/reels_repository.dart';
import '../datasources/reels_remote_datasource.dart';

/// Reels repository implementation

class ReelsRepositoryImpl implements ReelsRepository {
  final ReelsRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ReelsRepositoryImpl({
    required ReelsRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, PaginatedResponse<Reel>>> getReels({
    int page = 1,
    int pageSize = 10,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await _remoteDataSource.getReels(
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> likeReel(String reelId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.likeReel(reelId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> unlikeReel(String reelId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.unlikeReel(reelId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveReel(String reelId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.saveReel(reelId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> unsaveReel(String reelId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.unsaveReel(reelId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> recordView({
    required String reelId,
    required int duration,
  }) async {
    try {
      await _remoteDataSource.recordView(reelId: reelId, duration: duration);
      return const Right(null);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> shareReel(String reelId) async {
    try {
      await _remoteDataSource.shareReel(reelId);
      return const Right(null);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> followSeller(String sellerId) async {
    // TODO: Implement when followers system is ready
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> unfollowSeller(String sellerId) async {
    // TODO: Implement when followers system is ready
    return const Right(null);
  }
}
