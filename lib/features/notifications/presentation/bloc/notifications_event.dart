import 'package:equatable/equatable.dart';

import '../../domain/entities/notification.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationsEvent {
  const NotificationsLoadRequested();
}

class NotificationsUpdated extends NotificationsEvent {
  final List<AppNotification> notifications;

  const NotificationsUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
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
