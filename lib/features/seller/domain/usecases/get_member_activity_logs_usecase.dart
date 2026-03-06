import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/activity_log.dart';
import '../repositories/activity_log_repository.dart';

/// Get activity logs for a specific member

class GetMemberActivityLogsUseCase
    implements UseCase<List<ActivityLog>, GetMemberActivityLogsParams> {
  final ActivityLogRepository _repository;

  GetMemberActivityLogsUseCase(this._repository);

  @override
  Future<Either<Failure, List<ActivityLog>>> call(
      GetMemberActivityLogsParams params) {
    return _repository.getMemberActivityLogs(
      sellerProfileId: params.sellerProfileId,
      userId: params.userId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetMemberActivityLogsParams extends Equatable {
  final String sellerProfileId;
  final String userId;
  final int page;
  final int pageSize;

  const GetMemberActivityLogsParams({
    required this.sellerProfileId,
    required this.userId,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [sellerProfileId, userId, page, pageSize];
}
