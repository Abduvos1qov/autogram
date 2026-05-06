import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository _repository;
  StreamSubscription? _notificationsSubscription;

  NotificationsBloc({required NotificationRepository repository})
      : _repository = repository,
        super(const NotificationsState()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<NotificationsUpdated>(_onUpdated);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationsMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationDeleted>(_onDeleted);
  }

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    AppLogger.info('Loading notifications');
    emit(state.copyWith(status: NotificationsStatus.loading, clearFailure: true));

    final result = await _repository.getNotifications();

    await result.fold(
      (failure) async {
        AppLogger.error('Failed to load notifications: ${failure.message}');
        emit(state.copyWith(
          status: NotificationsStatus.error,
          failure: failure,
        ));
      },
      (notifications) async {
        final unreadResult = await _repository.getUnreadCount();
        final unreadCount = unreadResult.fold((_) => 0, (count) => count);

        AppLogger.info('Loaded ${notifications.length} notifications');
        emit(state.copyWith(
          status: NotificationsStatus.loaded,
          notifications: notifications,
          unreadCount: unreadCount,
        ));

        _notificationsSubscription?.cancel();
        _notificationsSubscription = _repository.watchNotifications().listen(
          (notifications) {
            add(NotificationsUpdated(notifications));
          },
        );
      },
    );
  }

  void _onUpdated(
    NotificationsUpdated event,
    Emitter<NotificationsState> emit,
  ) {
    final unreadCount = event.notifications.where((n) => !n.isRead).length;
    emit(state.copyWith(
      notifications: event.notifications,
      unreadCount: unreadCount,
    ));
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == event.notificationId) {
        return AppNotification(
          id: n.id,
          userId: n.userId,
          type: n.type,
          title: n.title,
          body: n.body,
          data: n.data,
          isRead: true,
          readAt: DateTime.now(),
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();

    emit(state.copyWith(
      notifications: updatedNotifications,
      unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
    ));

    await _repository.markAsRead(event.notificationId);
  }

  Future<void> _onMarkAllAsRead(
    NotificationsMarkAllAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final updatedNotifications = state.notifications.map((n) {
      return AppNotification(
        id: n.id,
        userId: n.userId,
        type: n.type,
        title: n.title,
        body: n.body,
        data: n.data,
        isRead: true,
        readAt: DateTime.now(),
        createdAt: n.createdAt,
      );
    }).toList();

    emit(state.copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
    ));

    await _repository.markAllAsRead();
  }

  Future<void> _onDeleted(
    NotificationDeleted event,
    Emitter<NotificationsState> emit,
  ) async {
    final notification = state.notifications.firstWhere(
      (n) => n.id == event.notificationId,
    );

    final updatedNotifications = state.notifications
        .where((n) => n.id != event.notificationId)
        .toList();

    emit(state.copyWith(
      notifications: updatedNotifications,
      unreadCount:
          notification.isRead ? state.unreadCount : state.unreadCount - 1,
    ));

    await _repository.deleteNotification(event.notificationId);
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
