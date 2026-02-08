import '../../../home/data/models/feed_item_model.dart';
import '../../domain/entities/reel.dart';

/// Reel model with JSON serialization

class ReelModel extends Reel {
  const ReelModel({
    required super.id,
    required super.sellerId,
    required super.sellerName,
    super.sellerLogoUrl,
    required super.isSellerVerified,
    required super.title,
    super.description,
    required super.price,
    required super.currency,
    required super.isNegotiable,
    required super.videoUrl,
    super.videoThumbnailUrl,
    super.videoHlsUrl,
    required super.videoDuration,
    super.city,
    super.autoDetails,
    required super.viewsCount,
    required super.likesCount,
    required super.savesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.isLiked,
    required super.isSaved,
    required super.isFollowing,
    required super.publishedAt,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    final seller = json['seller_profiles'] as Map<String, dynamic>?;
    final autoDetails = json['listing_auto_details'] as Map<String, dynamic>?;

    return ReelModel(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      sellerName: seller?['business_name'] as String? ?? 'Unknown',
      sellerLogoUrl: seller?['logo_url'] as String?,
      isSellerVerified: seller?['is_verified'] as bool? ?? false,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      videoUrl: json['video_url'] as String,
      videoThumbnailUrl: json['video_thumbnail_url'] as String?,
      videoHlsUrl: json['video_hls_url'] as String?,
      videoDuration: json['video_duration'] as int? ?? 0,
      city: json['city'] as String?,
      autoDetails: autoDetails != null
          ? AutoDetailsModel.fromJson(autoDetails)
          : null,
      viewsCount: json['views_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      savesCount: json['saves_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      isFollowing: json['is_following'] as bool? ?? false,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'is_negotiable': isNegotiable,
      'video_url': videoUrl,
      'video_thumbnail_url': videoThumbnailUrl,
      'video_hls_url': videoHlsUrl,
      'video_duration': videoDuration,
      'city': city,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'saves_count': savesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'published_at': publishedAt.toIso8601String(),
    };
  }

  factory ReelModel.fromEntity(Reel entity) {
    return ReelModel(
      id: entity.id,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
      sellerLogoUrl: entity.sellerLogoUrl,
      isSellerVerified: entity.isSellerVerified,
      title: entity.title,
      description: entity.description,
      price: entity.price,
      currency: entity.currency,
      isNegotiable: entity.isNegotiable,
      videoUrl: entity.videoUrl,
      videoThumbnailUrl: entity.videoThumbnailUrl,
      videoHlsUrl: entity.videoHlsUrl,
      videoDuration: entity.videoDuration,
      city: entity.city,
      autoDetails: entity.autoDetails,
      viewsCount: entity.viewsCount,
      likesCount: entity.likesCount,
      savesCount: entity.savesCount,
      commentsCount: entity.commentsCount,
      sharesCount: entity.sharesCount,
      isLiked: entity.isLiked,
      isSaved: entity.isSaved,
      isFollowing: entity.isFollowing,
      publishedAt: entity.publishedAt,
    );
  }
}
