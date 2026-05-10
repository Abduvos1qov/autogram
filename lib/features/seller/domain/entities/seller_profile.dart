import 'package:equatable/equatable.dart';

import 'contact_phone.dart';

/// Seller profile entity

class SellerProfile extends Equatable {
  final String id;
  final String userId;
  final String businessName;
  final BusinessType businessType;

  /// Public @handle for the storefront URL (`/seller/<username>`). Unique across
  /// all sellers. Lowercase alphanumeric + underscore, 3–30 chars. Backend
  /// migration TODO — may be null until column lands.
  final String? username;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String? address;
  final String? city;
  final String? district;
  final double? latitude;
  final double? longitude;

  /// Public-facing contact phones with per-row labels (sales/office/whatsapp…).
  /// Replaces the legacy `List<String>`; data layer parses both shapes for
  /// backward compatibility.
  final List<ContactPhone> contactPhones;

  /// Optional contact-person identity rendered next to the contact block on the
  /// storefront. Both fields are independent — name without role is fine.
  final String? contactPersonName;
  final String? contactPersonRole;
  final String? telegram;
  final String? instagram;
  final String? facebook;
  final String? youtube;
  final String? website;
  final Map<String, WorkingHours> workingHours;
  final bool isVerified;
  final DateTime? verifiedAt;
  final SubscriptionPlan subscriptionPlan;
  final DateTime? subscriptionExpiresAt;
  final SellerStats stats;
  final int seatsUsed;
  final int additionalSeats;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SellerProfile({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessType,
    this.username,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.address,
    this.city,
    this.district,
    this.latitude,
    this.longitude,
    this.contactPhones = const [],
    this.contactPersonName,
    this.contactPersonRole,
    this.telegram,
    this.instagram,
    this.facebook,
    this.youtube,
    this.website,
    this.workingHours = const {},
    required this.isVerified,
    this.verifiedAt,
    required this.subscriptionPlan,
    this.subscriptionExpiresAt,
    required this.stats,
    this.seatsUsed = 0,
    this.additionalSeats = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasActiveSubscription {
    if (subscriptionPlan == SubscriptionPlan.free) return true;
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  bool get canPostListings {
    if (!hasActiveSubscription) return false;
    final limit = subscriptionPlan.maxListings;
    if (limit == -1) return true;
    return stats.activeListings < limit;
  }

  SellerProfile copyWith({
    String? id,
    String? userId,
    String? businessName,
    BusinessType? businessType,
    String? username,
    String? description,
    String? logoUrl,
    String? coverUrl,
    String? address,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
    List<ContactPhone>? contactPhones,
    String? contactPersonName,
    String? contactPersonRole,
    String? telegram,
    String? instagram,
    String? facebook,
    String? youtube,
    String? website,
    Map<String, WorkingHours>? workingHours,
    bool? isVerified,
    DateTime? verifiedAt,
    SubscriptionPlan? subscriptionPlan,
    DateTime? subscriptionExpiresAt,
    SellerStats? stats,
    int? seatsUsed,
    int? additionalSeats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      username: username ?? this.username,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactPhones: contactPhones ?? this.contactPhones,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      contactPersonRole: contactPersonRole ?? this.contactPersonRole,
      telegram: telegram ?? this.telegram,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      youtube: youtube ?? this.youtube,
      website: website ?? this.website,
      workingHours: workingHours ?? this.workingHours,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      stats: stats ?? this.stats,
      seatsUsed: seatsUsed ?? this.seatsUsed,
      additionalSeats: additionalSeats ?? this.additionalSeats,
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
        username,
        description,
        logoUrl,
        coverUrl,
        address,
        city,
        district,
        latitude,
        longitude,
        contactPhones,
        contactPersonName,
        contactPersonRole,
        telegram,
        instagram,
        facebook,
        youtube,
        website,
        workingHours,
        isVerified,
        verifiedAt,
        subscriptionPlan,
        subscriptionExpiresAt,
        stats,
        seatsUsed,
        additionalSeats,
        createdAt,
        updatedAt,
      ];
}

enum BusinessType {
  individual,
  dealer,
  showroom;

  /// Translation key for the localized type label.
  /// Use as `type.labelKey.tr()` in UI code.
  String get labelKey => 'seller.business_types.$name.label';

  /// Translation key for the localized type description.
  /// Use as `type.descriptionKey.tr()` in UI code.
  String get descriptionKey => 'seller.business_types.$name.description';

  /// Legacy raw label (Uzbek). Kept for backward compatibility with the data
  /// layer fallback (when backend doesn't return a localized name) and for any
  /// non-UI consumer. UI must use [labelKey] + `.tr()`.
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

  /// Legacy raw description (Uzbek). UI must use [descriptionKey] + `.tr()`.
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

/// Subscription tier — sentinel `-1` means "unlimited" (for limits) or
/// "negotiable / contract-based" (for prices).
enum SubscriptionPlan {
  free,
  pro,
  premium,
  enterprise;

  /// Translation key for the localized plan name.
  /// Use as `plan.labelKey.tr()` in UI code.
  String get labelKey => 'seller.plans.$name.label';

  /// Translation key for the localized audience description.
  /// Use as `plan.audienceLabelKey.tr()` in UI code.
  String get audienceLabelKey => 'seller.plans.$name.audience';

  /// Translation key for the localized analytics level.
  /// Use as `plan.analyticsLevelKey.tr()` in UI code.
  String get analyticsLevelKey => 'seller.plans.$name.analytics';

  /// Legacy raw plan label (Uzbek). Kept for backward compatibility with the
  /// data layer fallback and the payment summary card. UI must use [labelKey]
  /// + `.tr()`.
  String get label {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Bepul';
      case SubscriptionPlan.pro:
        return 'Pro';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  /// Legacy raw audience label (Uzbek). UI must use [audienceLabelKey] +
  /// `.tr()`.
  String get audienceLabel {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Shaxsiy sotuvchi';
      case SubscriptionPlan.pro:
        return 'Kichik-o\'rta diler (3-5 xodim)';
      case SubscriptionPlan.premium:
        return 'Yirik avtosalon (10-20 xodim)';
      case SubscriptionPlan.enterprise:
        return 'Tarmoq avtosalonlar (30+ xodim, bir nechta filial)';
    }
  }

  /// Maximum active listings allowed on this plan.
  /// Returns `-1` for unlimited.
  int get maxListings {
    switch (this) {
      case SubscriptionPlan.free:
        return 3;
      case SubscriptionPlan.pro:
        return 100;
      case SubscriptionPlan.premium:
      case SubscriptionPlan.enterprise:
        return -1;
    }
  }

  /// Monthly price in UZS. Returns `-1` for "negotiable / contract-based".
  int get monthlyPrice {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.pro:
        return 999000;
      case SubscriptionPlan.premium:
        return 1999000;
      case SubscriptionPlan.enterprise:
        return -1;
    }
  }

  /// Yearly price in UZS. Returns `-1` for "negotiable / contract-based".
  int get yearlyPrice {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.pro:
        return 9990000;
      case SubscriptionPlan.premium:
        return 19990000;
      case SubscriptionPlan.enterprise:
        return -1;
    }
  }

  /// Bundled seats included with the plan. Returns `-1` for unlimited.
  int get seatsLimit {
    switch (this) {
      case SubscriptionPlan.free:
        return 1;
      case SubscriptionPlan.pro:
        return 3;
      case SubscriptionPlan.premium:
        return 10;
      case SubscriptionPlan.enterprise:
        return -1;
    }
  }

  /// Per-seat add-on price in UZS / month.
  /// Returns `0` when add-on is not applicable (Free) and `-1` for negotiable (Enterprise).
  int get additionalSeatPrice {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.pro:
        return 149000;
      case SubscriptionPlan.premium:
        return 249000;
      case SubscriptionPlan.enterprise:
        return -1;
    }
  }

  bool get hasVerifiedBadge {
    switch (this) {
      case SubscriptionPlan.free:
        return false;
      case SubscriptionPlan.pro:
      case SubscriptionPlan.premium:
      case SubscriptionPlan.enterprise:
        return true;
    }
  }

  /// Legacy raw analytics level label (Uzbek). UI must use
  /// [analyticsLevelKey] + `.tr()`.
  String get analyticsLevel {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Asosiy';
      case SubscriptionPlan.pro:
        return 'Kengaytirilgan';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.enterprise:
        return 'Premium+';
    }
  }

  bool get hasPersonalManager {
    switch (this) {
      case SubscriptionPlan.free:
      case SubscriptionPlan.pro:
        return false;
      case SubscriptionPlan.premium:
      case SubscriptionPlan.enterprise:
        return true;
    }
  }

  bool get hasApiAccess => this == SubscriptionPlan.enterprise;

  bool get hasMultiBranch => this == SubscriptionPlan.enterprise;

  List<String> get features {
    switch (this) {
      case SubscriptionPlan.free:
        return const [
          '3 ta e\'lon',
          '1 seat',
          'Asosiy analitika',
        ];
      case SubscriptionPlan.pro:
        return const [
          '100 ta e\'lon',
          '3 seat (qo\'shimcha 149k UZS/oy)',
          'Verified badge',
          'Kengaytirilgan analitika',
        ];
      case SubscriptionPlan.premium:
        return const [
          'Cheksiz e\'lon',
          '10 seat (qo\'shimcha 249k UZS/oy)',
          'Verified badge',
          'Premium analitika',
          'Shaxsiy menejer',
        ];
      case SubscriptionPlan.enterprise:
        return const [
          'Cheksiz e\'lon',
          'Cheksiz seat',
          'Verified badge',
          'Premium+ analitika',
          'Shaxsiy menejer',
          'API kirish',
          'Multi-filial',
        ];
    }
  }

  /// Defensive parser. Supports legacy values written before Phase 2 refactor:
  /// - 'basic' → pro (legacy first paid tier)
  /// - 'professional' → premium (legacy second paid tier)
  /// Note: legacy 'premium' (top tier in old enum) maps to new 'premium' (middle
  /// tier). This is intentional — auto-upgrading users to enterprise on parse
  /// would be unsafe.
  static SubscriptionPlan fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pro':
      case 'basic':
        return SubscriptionPlan.pro;
      case 'premium':
      case 'professional':
        return SubscriptionPlan.premium;
      case 'enterprise':
        return SubscriptionPlan.enterprise;
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
