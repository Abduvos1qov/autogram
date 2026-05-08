import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/repository_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/activity_log.dart';
import '../../domain/repositories/activity_log_repository.dart';
import '../datasources/activity_log_remote_datasource.dart';

/// Activity log repository implementation

class ActivityLogRepositoryImpl
    with RepositoryMixin
    implements ActivityLogRepository {
  final ActivityLogRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ActivityLogRepositoryImpl({
    required ActivityLogRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> logActivity({
    required String sellerProfileId,
    required ActivityType actionType,
    required String description,
    Map<String, dynamic>? metadata,
  }) =>
      safeRemoteCall(_networkInfo, () async {
        await _remoteDataSource.logActivity(
          sellerProfileId: sellerProfileId,
          actionType: actionType,
          description: description,
          metadata: metadata,
        );
      });

  @override
  Future<Either<Failure, List<ActivityLog>>> getActivityLogs({
    required String sellerProfileId,
    String? filterCategory,
    String? userId,
    int page = 1,
    int pageSize = 20,
  }) =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.getActivityLogs(
          sellerProfileId: sellerProfileId,
          filterCategory: filterCategory,
          userId: userId,
          page: page,
          pageSize: pageSize,
        );
      });

  @override
  Future<Either<Failure, List<ActivityLog>>> getMemberActivityLogs({
    required String sellerProfileId,
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.getMemberActivityLogs(
          sellerProfileId: sellerProfileId,
          userId: userId,
          page: page,
          pageSize: pageSize,
        );
      });
}
