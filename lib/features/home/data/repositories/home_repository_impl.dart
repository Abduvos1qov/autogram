import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/repository_mixin.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl with RepositoryMixin implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  HomeRepositoryImpl({
    required HomeRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, PaginatedResponse<FeedItem>>> getFeed({
    int page = 1,
    int pageSize = 20,
  }) {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getFeed(page: page, pageSize: pageSize);
    });
  }

  @override
  Future<Either<Failure, void>> likeListing(String listingId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.likeListing(listingId);
    });
  }

  @override
  Future<Either<Failure, void>> unlikeListing(String listingId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.unlikeListing(listingId);
    });
  }

  @override
  Future<Either<Failure, void>> saveListing(String listingId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.saveListing(listingId);
    });
  }

  @override
  Future<Either<Failure, void>> unsaveListing(String listingId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.unsaveListing(listingId);
    });
  }

  @override
  Future<Either<Failure, void>> recordView({
    required String listingId,
    int? duration,
  }) async {
    final result = await safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.recordView(
        listingId: listingId,
        duration: duration,
      );
    });
    return result.fold(
      (failure) {
        AppLogger.warning('Failed to record view: ${failure.message}');
        return const Right(null);
      },
      (_) => const Right(null),
    );
  }
}
