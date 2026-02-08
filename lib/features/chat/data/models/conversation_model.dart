import '../../domain/entities/conversation.dart';

/// Conversation data model

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    super.listingId,
    super.listingTitle,
    super.listingThumbnailUrl,
    super.listingPrice,
    required super.otherUserId,
    required super.otherUserName,
    super.otherUserAvatarUrl,
    required super.isOtherUserVerified,
    super.lastMessageText,
    super.lastMessageAt,
    required super.unreadCount,
    required super.createdAt,
  });

  factory ConversationModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final listing = json['listings'] as Map<String, dynamic>?;
    final buyer = json['buyer'] as Map<String, dynamic>?;
    final seller = json['seller_profiles'] as Map<String, dynamic>?;

    // Determine other user based on current user
    final isBuyer = json['buyer_id'] == currentUserId;

    return ConversationModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String?,
      listingTitle: listing?['title'] as String?,
      listingThumbnailUrl: listing?['video_thumbnail_url'] as String?,
      listingPrice: (listing?['price'] as num?)?.toDouble(),
      otherUserId: isBuyer
          ? (json['seller_id'] as String? ?? '')
          : (json['buyer_id'] as String? ?? ''),
      otherUserName: isBuyer
          ? (seller?['business_name'] as String? ?? 'Unknown')
          : (buyer?['full_name'] as String? ?? 'Unknown'),
      otherUserAvatarUrl: isBuyer ? (seller?['logo_url'] as String?) : (buyer?['avatar_url'] as String?),
      isOtherUserVerified: isBuyer
          ? (seller?['is_verified'] as bool? ?? false)
          : false,
      lastMessageText: json['last_message_text'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: isBuyer
          ? (json['buyer_unread_count'] as int? ?? 0)
          : (json['seller_unread_count'] as int? ?? 0),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory ConversationModel.fromEntity(Conversation entity) {
    return ConversationModel(
      id: entity.id,
      listingId: entity.listingId,
      listingTitle: entity.listingTitle,
      listingThumbnailUrl: entity.listingThumbnailUrl,
      listingPrice: entity.listingPrice,
      otherUserId: entity.otherUserId,
      otherUserName: entity.otherUserName,
      otherUserAvatarUrl: entity.otherUserAvatarUrl,
      isOtherUserVerified: entity.isOtherUserVerified,
      lastMessageText: entity.lastMessageText,
      lastMessageAt: entity.lastMessageAt,
      unreadCount: entity.unreadCount,
      createdAt: entity.createdAt,
    );
  }
}
