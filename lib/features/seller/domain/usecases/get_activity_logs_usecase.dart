import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/activity_log.dart';
import '../repositories/activity_log_repository.dart';

/// Get activity logs for a seller organization

class GetActivityLogsUseCase
    implements UseCase<List<ActivityLog>, GetActivityLogsParams> {
  final ActivityLogRepository _repository;

  GetActivityLogsUseCase(this._repository);

  @override
  Future<Either<Failure, List<ActivityLog>>> call(
      GetActivityLogsParams params) {
    return _repository.getActivityLogs(
      sellerProfileId: params.sellerProfileId,
      filterCategory: params.filterCategory,
      userId: params.userId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetActivityLogsParams extends Equatable {
  final String sellerProfileId;
  final String? filterCategory;
  final String? userId;
  final int page;
  final int pageSize;

  const GetActivityLogsParams({
    required this.sellerProfileId,
    this.filterCategory,
    this.userId,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props =>
      [sellerProfileId, filterCategory, userId, page, pageSize];
}
