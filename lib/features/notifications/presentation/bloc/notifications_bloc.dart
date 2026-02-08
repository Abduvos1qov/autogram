import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

// Events
sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationsEvent {
  const NotificationsLoadRequested();
}

class NotificationMarkAsRead extends NotificationsEvent {
  final String notificationId;
  const NotificationMarkAsRead(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

class NotificationsMarkAllAsRead extends NotificationsEvent {
  const NotificationsMarkAllAsRead();
}

class NotificationDeleted extends NotificationsEvent {
  final String notificationId;
  const NotificationDeleted(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

// State
enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<AppNotification> notifications;
  final int unreadCount;
  final Failure? failure;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.failure,
  });

  bool get isLoading => status == NotificationsStatus.loading;
  bool get hasError => status == NotificationsStatus.error;
  bool get isEmpty => notifications.isEmpty && status == NotificationsStatus.loaded;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    int? unreadCount,
    Failure? failure,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, notifications, unreadCount, failure];
}

// BLoC
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository _repository;
  StreamSubscription? _notificationsSubscription;

  NotificationsBloc({required NotificationRepository repository})
      : _repository = repository,
        super(const NotificationsState()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationsMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationDeleted>(_onDeleted);
  }

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    AppLogger.info('Loading notifications');
    emit(state.copyWith(status: NotificationsStatus.loading));

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
      },
    );
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
      unreadCount: notification.isRead ? state.unreadCount : state.unreadCount - 1,
    ));

    await _repository.deleteNotification(event.notificationId);
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
