import 'package:equatable/equatable.dart';

/// Conversation entity

class Conversation extends Equatable {
  final String id;
  final String? listingId;
  final String? listingTitle;
  final String? listingThumbnailUrl;
  final double? listingPrice;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatarUrl;
  final bool isOtherUserVerified;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  const Conversation({
    required this.id,
    this.listingId,
    this.listingTitle,
    this.listingThumbnailUrl,
    this.listingPrice,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    required this.isOtherUserVerified,
    this.lastMessageText,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
  });

  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => [
        id,
        listingId,
        listingTitle,
        listingThumbnailUrl,
        listingPrice,
        otherUserId,
        otherUserName,
        otherUserAvatarUrl,
        isOtherUserVerified,
        lastMessageText,
        lastMessageAt,
        unreadCount,
        createdAt,
      ];
}
