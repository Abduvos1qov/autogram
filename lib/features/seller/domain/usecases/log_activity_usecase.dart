import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/activity_log.dart';
import '../repositories/activity_log_repository.dart';

/// Log a new activity in the seller organization

class LogActivityUseCase implements UseCase<void, LogActivityParams> {
  final ActivityLogRepository _repository;

  LogActivityUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(LogActivityParams params) {
    return _repository.logActivity(
      sellerProfileId: params.sellerProfileId,
      actionType: params.actionType,
      description: params.description,
      metadata: params.metadata,
    );
  }
}

class LogActivityParams extends Equatable {
  final String sellerProfileId;
  final ActivityType actionType;
  final String description;
  final Map<String, dynamic>? metadata;

  const LogActivityParams({
    required this.sellerProfileId,
    required this.actionType,
    required this.description,
    this.metadata,
  });

  @override
  List<Object?> get props => [sellerProfileId, actionType, description, metadata];
}
