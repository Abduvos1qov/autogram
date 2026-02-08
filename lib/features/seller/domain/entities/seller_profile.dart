import 'package:equatable/equatable.dart';

/// Seller profile entity

class SellerProfile extends Equatable {
  final String id;
  final String userId;
  final String businessName;
  final BusinessType businessType;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String? address;
  final String? city;
  final String? district;
  final double? latitude;
  final double? longitude;
  final List<String> contactPhones;
  final String? telegram;
  final String? instagram;
  final String? website;
  final Map<String, WorkingHours> workingHours;
  final bool isVerified;
  final DateTime? verifiedAt;
  final SubscriptionPlan subscriptionPlan;
  final DateTime? subscriptionExpiresAt;
  final SellerStats stats;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SellerProfile({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessType,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.address,
    this.city,
    this.district,
    this.latitude,
    this.longitude,
    this.contactPhones = const [],
    this.telegram,
    this.instagram,
    this.website,
    this.workingHours = const {},
    required this.isVerified,
    this.verifiedAt,
    required this.subscriptionPlan,
    this.subscriptionExpiresAt,
    required this.stats,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasActiveSubscription {
    if (subscriptionPlan == SubscriptionPlan.free) return true;
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  bool get canPostListings {
    return hasActiveSubscription && stats.activeListings < subscriptionPlan.maxListings;
  }

  SellerProfile copyWith({
    String? id,
    String? userId,
    String? businessName,
    BusinessType? businessType,
    String? description,
    String? logoUrl,
    String? coverUrl,
    String? address,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
    List<String>? contactPhones,
    String? telegram,
    String? instagram,
    String? website,
    Map<String, WorkingHours>? workingHours,
    bool? isVerified,
    DateTime? verifiedAt,
    SubscriptionPlan? subscriptionPlan,
    DateTime? subscriptionExpiresAt,
    SellerStats? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactPhones: contactPhones ?? this.contactPhones,
      telegram: telegram ?? this.telegram,
      instagram: instagram ?? this.instagram,
      website: website ?? this.website,
      workingHours: workingHours ?? this.workingHours,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        businessName,
        businessType,
        description,
        logoUrl,
        coverUrl,
        address,
        city,
        district,
        latitude,
        longitude,
        contactPhones,
        telegram,
        instagram,
        website,
        workingHours,
        isVerified,
        verifiedAt,
        subscriptionPlan,
        subscriptionExpiresAt,
        stats,
        createdAt,
        updatedAt,
      ];
}

enum BusinessType {
  individual,
  dealer,
  showroom;

  String get label {
    switch (this) {
      case BusinessType.individual:
        return 'Jismoniy shaxs';
      case BusinessType.dealer:
        return 'Diler';
      case BusinessType.showroom:
        return 'Avtosalon';
    }
  }

  String get description {
    switch (this) {
      case BusinessType.individual:
        return 'Shaxsiy avtomobillarni sotish';
      case BusinessType.dealer:
        return 'Avtomobil savdosi bilan shug\'ullanish';
      case BusinessType.showroom:
        return 'Rasmiy avtosalon yoki ko\'rgazma zali';
    }
  }

  String get icon {
    switch (this) {
      case BusinessType.individual:
        return 'person';
      case BusinessType.dealer:
        return 'store';
      case BusinessType.showroom:
        return 'business';
    }
  }

  static BusinessType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'dealer':
        return BusinessType.dealer;
      case 'showroom':
        return BusinessType.showroom;
      case 'individual':
      default:
        return BusinessType.individual;
    }
  }
}

enum SubscriptionPlan {
  free,
  basic,
  professional,
  premium;

  String get label {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Bepul';
      case SubscriptionPlan.basic:
        return 'Boshlang\'ich';
      case SubscriptionPlan.professional:
        return 'Professional';
      case SubscriptionPlan.premium:
        return 'Premium';
    }
  }

  int get maxListings {
    switch (this) {
      case SubscriptionPlan.free:
        return 3;
      case SubscriptionPlan.basic:
        return 10;
      case SubscriptionPlan.professional:
        return 50;
      case SubscriptionPlan.premium:
        return 999;
    }
  }

  int get monthlyPrice {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.basic:
        return 99000;
      case SubscriptionPlan.professional:
        return 299000;
      case SubscriptionPlan.premium:
        return 599000;
    }
  }

  List<String> get features {
    switch (this) {
      case SubscriptionPlan.free:
        return [
          '3 ta e\'lon',
          'Standart ko\'rinish',
          'Asosiy statistika',
        ];
      case SubscriptionPlan.basic:
        return [
          '10 ta e\'lon',
          'Standart ko\'rinish',
          'To\'liq statistika',
          'Chat qo\'llab-quvvatlash',
        ];
      case SubscriptionPlan.professional:
        return [
          '50 ta e\'lon',
          'Yuqori ko\'rinish',
          'Kengaytirilgan statistika',
          'Ustuvor qo\'llab-quvvatlash',
          'Tasdiqlangan badge',
        ];
      case SubscriptionPlan.premium:
        return [
          'Cheksiz e\'lonlar',
          'Maksimal ko\'rinish',
          'Premium statistika',
          'Shaxsiy menejer',
          'Tasdiqlangan badge',
          'Maxsus reklamalar',
        ];
    }
  }

  static SubscriptionPlan fromString(String value) {
    switch (value.toLowerCase()) {
      case 'basic':
        return SubscriptionPlan.basic;
      case 'professional':
        return SubscriptionPlan.professional;
      case 'premium':
        return SubscriptionPlan.premium;
      case 'free':
      default:
        return SubscriptionPlan.free;
    }
  }
}

class WorkingHours extends Equatable {
  final String open;
  final String close;
  final bool isClosed;

  const WorkingHours({
    required this.open,
    required this.close,
    this.isClosed = false,
  });

  @override
  List<Object?> get props => [open, close, isClosed];
}

class SellerStats extends Equatable {
  final int totalListings;
  final int activeListings;
  final int totalSold;
  final int totalViews;
  final double avgRating;
  final int totalReviews;
  final int followersCount;

  const SellerStats({
    this.totalListings = 0,
    this.activeListings = 0,
    this.totalSold = 0,
    this.totalViews = 0,
    this.avgRating = 0,
    this.totalReviews = 0,
    this.followersCount = 0,
  });

  @override
  List<Object?> get props => [
        totalListings,
        activeListings,
        totalSold,
        totalViews,
        avgRating,
        totalReviews,
        followersCount,
      ];
}
