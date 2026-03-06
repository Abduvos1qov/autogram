import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/activity_log.dart';

/// Activity log repository interface

abstract class ActivityLogRepository {
  /// Log a new activity
  Future<Either<Failure, void>> logActivity({
    required String sellerProfileId,
    required ActivityType actionType,
    required String description,
    Map<String, dynamic>? metadata,
  });

  /// Get activity logs for a seller organization (with filters + pagination)
  Future<Either<Failure, List<ActivityLog>>> getActivityLogs({
    required String sellerProfileId,
    String? filterCategory,
    String? userId,
    int page = 1,
    int pageSize = 20,
  });

  /// Get activity logs for a specific member
  Future<Either<Failure, List<ActivityLog>>> getMemberActivityLogs({
    required String sellerProfileId,
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
}
