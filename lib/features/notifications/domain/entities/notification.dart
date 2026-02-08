import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Notification entity

class AppNotification extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String? body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    this.data = const {},
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        body,
        data,
        isRead,
        readAt,
        createdAt,
      ];
}

enum NotificationType {
  newMessage,
  priceDrop,
  newListing,
  listingViewed,
  subscriptionExpiring,
  reviewReceived,
  systemUpdate,
  promotion;

  static NotificationType fromString(String value) {
    switch (value) {
      case 'new_message':
        return NotificationType.newMessage;
      case 'price_drop':
        return NotificationType.priceDrop;
      case 'new_listing':
        return NotificationType.newListing;
      case 'listing_viewed':
        return NotificationType.listingViewed;
      case 'subscription_expiring':
        return NotificationType.subscriptionExpiring;
      case 'review_received':
        return NotificationType.reviewReceived;
      case 'system_update':
        return NotificationType.systemUpdate;
      case 'promotion':
        return NotificationType.promotion;
      default:
        return NotificationType.systemUpdate;
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.newMessage:
        return Icons.chat_bubble_outline;
      case NotificationType.priceDrop:
        return Icons.trending_down;
      case NotificationType.newListing:
        return Icons.fiber_new;
      case NotificationType.listingViewed:
        return Icons.visibility;
      case NotificationType.subscriptionExpiring:
        return Icons.warning;
      case NotificationType.reviewReceived:
        return Icons.star;
      case NotificationType.systemUpdate:
        return Icons.system_update;
      case NotificationType.promotion:
        return Icons.local_offer;
    }
  }
}
