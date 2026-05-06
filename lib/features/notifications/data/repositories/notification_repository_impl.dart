import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/repository_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl
    with RepositoryMixin
    implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getNotifications();
    });
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.markAsRead(notificationId);
    });
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.markAllAsRead();
    });
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.deleteNotification(notificationId);
    });
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getUnreadCount();
    });
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    return _remoteDataSource.watchNotifications();
  }
}
