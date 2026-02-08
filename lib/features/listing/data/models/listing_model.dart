import '../../domain/entities/listing.dart';

/// Listing data model

class ListingModel extends Listing {
  const ListingModel({
    required super.id,
    required super.sellerId,
    super.categoryId,
    required super.title,
    super.description,
    required super.price,
    required super.currency,
    required super.isNegotiable,
    required super.status,
    required super.isFeatured,
    super.featuredUntil,
    super.videoUrl,
    super.videoThumbnailUrl,
    super.videoDuration,
    required super.images,
    super.city,
    super.district,
    required super.viewsCount,
    required super.likesCount,
    required super.savesCount,
    required super.sharesCount,
    required super.isLiked,
    required super.isSaved,
    super.autoDetails,
    required super.seller,
    super.publishedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final sellerJson = json['seller_profiles'] as Map<String, dynamic>?;
    final autoDetailsJson = json['listing_auto_details'] as Map<String, dynamic>?;

    return ListingModel(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      categoryId: json['category_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      status: _parseStatus(json['status'] as String?),
      isFeatured: json['is_featured'] as bool? ?? false,
      featuredUntil: json['featured_until'] != null
          ? DateTime.parse(json['featured_until'] as String)
          : null,
      videoUrl: json['video_url'] as String?,
      videoThumbnailUrl: json['video_thumbnail_url'] as String?,
      videoDuration: json['video_duration'] as int?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      city: json['city'] as String?,
      district: json['district'] as String?,
      viewsCount: json['views_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      savesCount: json['saves_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      autoDetails: autoDetailsJson != null
          ? AutoDetailsModel.fromJson(autoDetailsJson)
          : null,
      seller: sellerJson != null
          ? SellerModel.fromJson(sellerJson)
          : SellerModel.empty(),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static ListingStatus _parseStatus(String? status) {
    switch (status) {
      case 'draft':
        return ListingStatus.draft;
      case 'pending':
        return ListingStatus.pending;
      case 'active':
        return ListingStatus.active;
      case 'sold':
        return ListingStatus.sold;
      case 'archived':
        return ListingStatus.archived;
      default:
        return ListingStatus.draft;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'is_negotiable': isNegotiable,
      'status': status.name,
      'is_featured': isFeatured,
      'featured_until': featuredUntil?.toIso8601String(),
      'video_url': videoUrl,
      'video_thumbnail_url': videoThumbnailUrl,
      'video_duration': videoDuration,
      'images': images,
      'city': city,
      'district': district,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'saves_count': savesCount,
      'shares_count': sharesCount,
      'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ListingModel.fromEntity(Listing entity) {
    return ListingModel(
      id: entity.id,
      sellerId: entity.sellerId,
      categoryId: entity.categoryId,
      title: entity.title,
      description: entity.description,
      price: entity.price,
      currency: entity.currency,
      isNegotiable: entity.isNegotiable,
      status: entity.status,
      isFeatured: entity.isFeatured,
      featuredUntil: entity.featuredUntil,
      videoUrl: entity.videoUrl,
      videoThumbnailUrl: entity.videoThumbnailUrl,
      videoDuration: entity.videoDuration,
      images: entity.images,
      city: entity.city,
      district: entity.district,
      viewsCount: entity.viewsCount,
      likesCount: entity.likesCount,
      savesCount: entity.savesCount,
      sharesCount: entity.sharesCount,
      isLiked: entity.isLiked,
      isSaved: entity.isSaved,
      autoDetails: entity.autoDetails,
      seller: entity.seller,
      publishedAt: entity.publishedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
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
    super.features,
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
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
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
      'features': features,
    };
  }
}

class SellerModel extends Seller {
  const SellerModel({
    required super.id,
    required super.userId,
    required super.businessName,
    super.businessType,
    super.description,
    super.logoUrl,
    super.coverUrl,
    super.address,
    super.city,
    super.district,
    super.latitude,
    super.longitude,
    super.contactPhones,
    super.telegram,
    super.instagram,
    super.website,
    super.workingHours,
    required super.isVerified,
    super.verifiedAt,
    required super.subscriptionType,
    super.subscriptionExpiresAt,
    required super.totalListings,
    required super.activeListings,
    required super.totalSold,
    required super.totalViews,
    required super.avgRating,
    required super.totalReviews,
    required super.isFollowing,
    required super.createdAt,
  });

  factory SellerModel.empty() {
    return SellerModel(
      id: '',
      userId: '',
      businessName: 'Unknown',
      isVerified: false,
      subscriptionType: 'free',
      totalListings: 0,
      activeListings: 0,
      totalSold: 0,
      totalViews: 0,
      avgRating: 0,
      totalReviews: 0,
      isFollowing: false,
      createdAt: DateTime.now(),
    );
  }

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      businessName: json['business_name'] as String? ?? 'Unknown',
      businessType: json['business_type'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactPhones: (json['contact_phones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      telegram: json['telegram'] as String?,
      instagram: json['instagram'] as String?,
      website: json['website'] as String?,
      workingHours: json['working_hours'] as Map<String, dynamic>? ?? {},
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      subscriptionType: json['subscription_type'] as String? ?? 'free',
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
      totalListings: json['total_listings'] as int? ?? 0,
      activeListings: json['active_listings'] as int? ?? 0,
      totalSold: json['total_sold'] as int? ?? 0,
      totalViews: json['total_views'] as int? ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'business_type': businessType,
      'description': description,
      'logo_url': logoUrl,
      'cover_url': coverUrl,
      'address': address,
      'city': city,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'contact_phones': contactPhones,
      'telegram': telegram,
      'instagram': instagram,
      'website': website,
      'working_hours': workingHours,
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
      'subscription_type': subscriptionType,
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
      'total_listings': totalListings,
      'active_listings': activeListings,
      'total_sold': totalSold,
      'total_views': totalViews,
      'avg_rating': avgRating,
      'total_reviews': totalReviews,
      'is_following': isFollowing,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
