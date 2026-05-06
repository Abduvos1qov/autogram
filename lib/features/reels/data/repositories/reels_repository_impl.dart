import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/repository_mixin.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/reel.dart';
import '../../domain/repositories/reels_repository.dart';
import '../datasources/reels_remote_datasource.dart';

class ReelsRepositoryImpl with RepositoryMixin implements ReelsRepository {
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
  }) {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getReels(page: page, pageSize: pageSize);
    });
  }

  @override
  Future<Either<Failure, void>> likeReel(String reelId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.likeReel(reelId);
    });
  }

  @override
  Future<Either<Failure, void>> unlikeReel(String reelId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.unlikeReel(reelId);
    });
  }

  @override
  Future<Either<Failure, void>> saveReel(String reelId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.saveReel(reelId);
    });
  }

  @override
  Future<Either<Failure, void>> unsaveReel(String reelId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.unsaveReel(reelId);
    });
  }

  @override
  Future<Either<Failure, void>> recordView({
    required String reelId,
    required int duration,
  }) async {
    final result = await safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.recordView(reelId: reelId, duration: duration);
    });
    return result.fold(
      (failure) {
        AppLogger.warning('Failed to record reel view: ${failure.message}');
        return const Right(null);
      },
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> shareReel(String reelId) async {
    final result = await safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.shareReel(reelId);
    });
    return result.fold(
      (failure) {
        AppLogger.warning('Failed to share reel: ${failure.message}');
        return const Right(null);
      },
      (_) => const Right(null),
    );
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
