import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/test_config.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/notification.dart';

abstract class NotificationRemoteDataSource {
  Future<List<AppNotification>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<int> getUnreadCount();
  Stream<List<AppNotification>> watchNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final supabase.SupabaseClient _supabase;

  NotificationRemoteDataSourceImpl({
    required supabase.SupabaseClient supabaseClient,
  }) : _supabase = supabaseClient;

  AppNotification _markRead(AppNotification n) => AppNotification(
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

  @override
  Future<List<AppNotification>> getNotifications() async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Returning mock notifications');
      await Future.delayed(const Duration(milliseconds: 500));
      return List.from(MockData.currentNotifications);
    }

    // TODO(backend): wire to Supabase notifications table
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((json) => _fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    if (TestConfig.isTestMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      final list = MockData.currentNotifications;
      final index = list.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        list[index] = _markRead(list[index]);
      }
      return;
    }

    // TODO(backend): wire to Supabase notifications.update
    await _supabase
        .from('notifications')
        .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
        .eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    if (TestConfig.isTestMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final list = MockData.currentNotifications;
      for (var i = 0; i < list.length; i++) {
        if (!list[i].isRead) {
          list[i] = _markRead(list[i]);
        }
      }
      return;
    }

    // TODO(backend): wire to Supabase notifications.update where is_read=false
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    await _supabase
        .from('notifications')
        .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    if (TestConfig.isTestMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      MockData.currentNotifications.removeWhere((n) => n.id == notificationId);
      return;
    }

    // TODO(backend): wire to Supabase notifications.delete
    await _supabase.from('notifications').delete().eq('id', notificationId);
  }

  @override
  Future<int> getUnreadCount() async {
    if (TestConfig.isTestMode) {
      return MockData.currentNotifications.where((n) => !n.isRead).length;
    }

    // TODO(backend): wire to Supabase count query
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final response = await _supabase
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false)
        .count();
    return response.count;
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    if (TestConfig.isTestMode) {
      return Stream.value(List.from(MockData.currentNotifications));
    }

    // TODO(backend): wire to Supabase realtime channel
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return const Stream.empty();
    }
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .map((rows) => rows.map(_fromJson).toList());
  }

  AppNotification _fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.fromString(json['type'] as String? ?? ''),
      title: json['title'] as String,
      body: json['body'] as String?,
      data: (json['data'] as Map<String, dynamic>?) ?? const {},
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
