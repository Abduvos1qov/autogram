import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/feedback/empty_view.dart';
import '../../../../core/widgets/feedback/error_view.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../domain/entities/notification.dart';
import '../bloc/notifications_bloc.dart';

/// Notifications screen

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const NotificationsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirishnomalar'),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  context.read<NotificationsBloc>().add(
                        const NotificationsMarkAllAsRead(),
                      );
                },
                child: const Text('Barchasini o\'qildi'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state.hasError) {
            return ErrorView(
              failure: state.failure,
              onRetry: () {
                context.read<NotificationsBloc>().add(
                      const NotificationsLoadRequested(),
                    );
              },
            );
          }

          if (state.isEmpty) {
            return const EmptyView(
              icon: Icons.notifications_none,
              title: 'Bildirishnomalar yo\'q',
              message: 'Yangi bildirishnomalar shu yerda ko\'rinadi',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationsBloc>().add(
                    const NotificationsLoadRequested(),
                  );
            },
            child: ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _buildNotificationTile(context, notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: AppColors.error,
        child: const Icon(
          Icons.delete,
          color: AppColors.white,
        ),
      ),
      onDismissed: (_) {
        context.read<NotificationsBloc>().add(
              NotificationDeleted(notification.id),
            );
      },
      child: ListTile(
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationsBloc>().add(
                  NotificationMarkAsRead(notification.id),
                );
          }
          _handleNotificationTap(context, notification);
        },
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.surface
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            notification.type.icon,
            color: notification.isRead ? AppColors.textSecondary : AppColors.primary,
          ),
        ),
        title: Text(
          notification.title,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.body != null) ...[
              Text(
                notification.body!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Text(
              Formatters.formatDateTime(notification.createdAt),
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.newMessage:
        final conversationId = notification.data['conversation_id'] as String?;
        if (conversationId != null) {
          context.push('/chat/$conversationId');
        }
        break;
      case NotificationType.priceDrop:
      case NotificationType.newListing:
      case NotificationType.listingViewed:
        final listingId = notification.data['listing_id'] as String?;
        if (listingId != null) {
          context.push('/listing/$listingId');
        }
        break;
      case NotificationType.reviewReceived:
        context.push('/reviews');
        break;
      case NotificationType.subscriptionExpiring:
        context.push('/subscription');
        break;
      default:
        break;
    }
  }
}
