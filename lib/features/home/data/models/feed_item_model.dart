import '../../domain/entities/feed_item.dart';

/// Feed item model with JSON serialization

class FeedItemModel extends FeedItem {
  const FeedItemModel({
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
    super.videoUrl,
    super.videoThumbnailUrl,
    super.videoDuration,
    required super.images,
    super.city,
    super.district,
    super.autoDetails,
    required super.viewsCount,
    required super.likesCount,
    required super.savesCount,
    required super.isLiked,
    required super.isSaved,
    required super.publishedAt,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    final seller = json['seller_profiles'] as Map<String, dynamic>?;
    final autoDetails = json['listing_auto_details'] as Map<String, dynamic>?;

    return FeedItemModel(
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
      videoUrl: json['video_url'] as String?,
      videoThumbnailUrl: json['video_thumbnail_url'] as String?,
      videoDuration: json['video_duration'] as int?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      city: json['city'] as String?,
      district: json['district'] as String?,
      autoDetails: autoDetails != null
          ? AutoDetailsModel.fromJson(autoDetails)
          : null,
      viewsCount: json['views_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      savesCount: json['saves_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
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
      'video_duration': videoDuration,
      'images': images,
      'city': city,
      'district': district,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'saves_count': savesCount,
      'published_at': publishedAt.toIso8601String(),
    };
  }

  factory FeedItemModel.fromEntity(FeedItem entity) {
    return FeedItemModel(
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
      videoDuration: entity.videoDuration,
      images: entity.images,
      city: entity.city,
      district: entity.district,
      autoDetails: entity.autoDetails,
      viewsCount: entity.viewsCount,
      likesCount: entity.likesCount,
      savesCount: entity.savesCount,
      isLiked: entity.isLiked,
      isSaved: entity.isSaved,
      publishedAt: entity.publishedAt,
    );
  }
}

class AutoDetailsModel extends AutoDetails {
  const AutoDetailsModel({
    super.brand,
    super.model,
    super.year,
    super.mileage,
    super.fuelType,
    super.transmission,
    super.driveType,
    super.bodyType,
    super.color,
    super.engineVolume,
    super.condition,
    super.hasAccident,
    super.ownersCount,
  });

  factory AutoDetailsModel.fromJson(Map<String, dynamic> json) {
    return AutoDetailsModel(
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      mileage: json['mileage'] as int?,
      fuelType: json['fuel_type'] as String?,
      transmission: json['transmission'] as String?,
      driveType: json['drive_type'] as String?,
      bodyType: json['body_type'] as String?,
      color: json['color'] as String?,
      engineVolume: (json['engine_volume'] as num?)?.toDouble(),
      condition: json['condition'] as String?,
      hasAccident: json['has_accident'] as bool? ?? false,
      ownersCount: json['owners_count'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'mileage': mileage,
      'fuel_type': fuelType,
      'transmission': transmission,
      'drive_type': driveType,
      'body_type': bodyType,
      'color': color,
      'engine_volume': engineVolume,
      'condition': condition,
      'has_accident': hasAccident,
      'owners_count': ownersCount,
    };
  }
}
