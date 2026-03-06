import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/activity_log.dart';
import '../../domain/repositories/activity_log_repository.dart';
import '../datasources/activity_log_remote_datasource.dart';

/// Activity log repository implementation

class ActivityLogRepositoryImpl implements ActivityLogRepository {
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
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      await _remoteDataSource.logActivity(
        sellerProfileId: sellerProfileId,
        actionType: actionType,
        description: description,
        metadata: metadata,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<ActivityLog>>> getActivityLogs({
    required String sellerProfileId,
    String? filterCategory,
    String? userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      final logs = await _remoteDataSource.getActivityLogs(
        sellerProfileId: sellerProfileId,
        filterCategory: filterCategory,
        userId: userId,
        page: page,
        pageSize: pageSize,
      );
      return Right(logs);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<ActivityLog>>> getMemberActivityLogs({
    required String sellerProfileId,
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      final logs = await _remoteDataSource.getMemberActivityLogs(
        sellerProfileId: sellerProfileId,
        userId: userId,
        page: page,
        pageSize: pageSize,
      );
      return Right(logs);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
