import '../../domain/entities/seller_profile.dart';

/// Seller profile data model

class SellerProfileModel extends SellerProfile {
  const SellerProfileModel({
    required super.id,
    required super.userId,
    required super.businessName,
    required super.businessType,
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
    required super.subscriptionPlan,
    super.subscriptionExpiresAt,
    required super.stats,
    super.seatsUsed,
    super.additionalSeats,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SellerProfileModel.fromJson(Map<String, dynamic> json) {
    return SellerProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String,
      businessType: BusinessType.fromString(json['business_type'] as String? ?? 'individual'),
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
      workingHours: _parseWorkingHours(json['working_hours'] as Map<String, dynamic>?),
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      subscriptionPlan: SubscriptionPlan.fromString(json['subscription_type'] as String? ?? 'free'),
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
      stats: SellerStatsModel.fromJson(json),
      seatsUsed: json['seats_used'] as int? ?? 0,
      additionalSeats: json['additional_seats'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static Map<String, WorkingHours> _parseWorkingHours(Map<String, dynamic>? json) {
    if (json == null) return {};

    return json.map((key, value) {
      final hours = value as Map<String, dynamic>;
      return MapEntry(
        key,
        WorkingHours(
          open: hours['open'] as String? ?? '09:00',
          close: hours['close'] as String? ?? '18:00',
          isClosed: hours['is_closed'] as bool? ?? false,
        ),
      );
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'business_type': businessType.name,
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
      'working_hours': workingHours.map((key, value) => MapEntry(
        key,
        {
          'open': value.open,
          'close': value.close,
          'is_closed': value.isClosed,
        },
      )),
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
      'subscription_type': subscriptionPlan.name,
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
      'seats_used': seatsUsed,
      'additional_seats': additionalSeats,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SellerProfileModel.fromEntity(SellerProfile entity) {
    return SellerProfileModel(
      id: entity.id,
      userId: entity.userId,
      businessName: entity.businessName,
      businessType: entity.businessType,
      description: entity.description,
      logoUrl: entity.logoUrl,
      coverUrl: entity.coverUrl,
      address: entity.address,
      city: entity.city,
      district: entity.district,
      latitude: entity.latitude,
      longitude: entity.longitude,
      contactPhones: entity.contactPhones,
      telegram: entity.telegram,
      instagram: entity.instagram,
      website: entity.website,
      workingHours: entity.workingHours,
      isVerified: entity.isVerified,
      verifiedAt: entity.verifiedAt,
      subscriptionPlan: entity.subscriptionPlan,
      subscriptionExpiresAt: entity.subscriptionExpiresAt,
      stats: entity.stats,
      seatsUsed: entity.seatsUsed,
      additionalSeats: entity.additionalSeats,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

class SellerStatsModel extends SellerStats {
  const SellerStatsModel({
    super.totalListings,
    super.activeListings,
    super.totalSold,
    super.totalViews,
    super.avgRating,
    super.totalReviews,
    super.followersCount,
  });

  factory SellerStatsModel.fromJson(Map<String, dynamic> json) {
    return SellerStatsModel(
      totalListings: json['total_listings'] as int? ?? 0,
      activeListings: json['active_listings'] as int? ?? 0,
      totalSold: json['total_sold'] as int? ?? 0,
      totalViews: json['total_views'] as int? ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      followersCount: json['followers_count'] as int? ?? 0,
    );
  }
}
