import 'package:equatable/equatable.dart';

/// Listing entity

class Listing extends Equatable {
  final String id;
  final String sellerId;
  final String? categoryId;
  final String title;
  final String? description;
  final double price;
  final String currency;
  final bool isNegotiable;
  final ListingStatus status;
  final bool isFeatured;
  final DateTime? featuredUntil;
  final String? videoUrl;
  final String? videoThumbnailUrl;
  final int? videoDuration;
  final List<String> images;
  final String? city;
  final String? district;
  final int viewsCount;
  final int likesCount;
  final int savesCount;
  final int sharesCount;
  final bool isLiked;
  final bool isSaved;
  final AutoDetails? autoDetails;
  final Seller seller;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Listing({
    required this.id,
    required this.sellerId,
    this.categoryId,
    required this.title,
    this.description,
    required this.price,
    required this.currency,
    required this.isNegotiable,
    required this.status,
    required this.isFeatured,
    this.featuredUntil,
    this.videoUrl,
    this.videoThumbnailUrl,
    this.videoDuration,
    required this.images,
    this.city,
    this.district,
    required this.viewsCount,
    required this.likesCount,
    required this.savesCount,
    required this.sharesCount,
    required this.isLiked,
    required this.isSaved,
    this.autoDetails,
    required this.seller,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Listing copyWith({
    String? id,
    String? sellerId,
    String? categoryId,
    String? title,
    String? description,
    double? price,
    String? currency,
    bool? isNegotiable,
    ListingStatus? status,
    bool? isFeatured,
    DateTime? featuredUntil,
    String? videoUrl,
    String? videoThumbnailUrl,
    int? videoDuration,
    List<String>? images,
    String? city,
    String? district,
    int? viewsCount,
    int? likesCount,
    int? savesCount,
    int? sharesCount,
    bool? isLiked,
    bool? isSaved,
    AutoDetails? autoDetails,
    Seller? seller,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Listing(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredUntil: featuredUntil ?? this.featuredUntil,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
      videoDuration: videoDuration ?? this.videoDuration,
      images: images ?? this.images,
      city: city ?? this.city,
      district: district ?? this.district,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      autoDetails: autoDetails ?? this.autoDetails,
      seller: seller ?? this.seller,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sellerId,
        categoryId,
        title,
        description,
        price,
        currency,
        isNegotiable,
        status,
        isFeatured,
        featuredUntil,
        videoUrl,
        videoThumbnailUrl,
        videoDuration,
        images,
        city,
        district,
        viewsCount,
        likesCount,
        savesCount,
        sharesCount,
        isLiked,
        isSaved,
        autoDetails,
        seller,
        publishedAt,
        createdAt,
        updatedAt,
      ];
}

enum ListingStatus {
  draft,
  pending,
  active,
  sold,
  archived;

  String get label {
    switch (this) {
      case ListingStatus.draft:
        return 'Qoralama';
      case ListingStatus.pending:
        return 'Kutilmoqda';
      case ListingStatus.active:
        return 'Faol';
      case ListingStatus.sold:
        return 'Sotilgan';
      case ListingStatus.archived:
        return 'Arxivlangan';
    }
  }
}

class AutoDetails extends Equatable {
  final String? brand;
  final String? model;
  final int? year;
  final int? mileage;
  final String? fuelType;
  final String? transmission;
  final String? driveType;
  final String? bodyType;
  final String? color;
  final double? engineVolume;
  final String? condition;
  final bool hasAccident;
  final int ownersCount;
  final List<String> features;

  const AutoDetails({
    this.brand,
    this.model,
    this.year,
    this.mileage,
    this.fuelType,
    this.transmission,
    this.driveType,
    this.bodyType,
    this.color,
    this.engineVolume,
    this.condition,
    this.hasAccident = false,
    this.ownersCount = 1,
    this.features = const [],
  });

  @override
  List<Object?> get props => [
        brand,
        model,
        year,
        mileage,
        fuelType,
        transmission,
        driveType,
        bodyType,
        color,
        engineVolume,
        condition,
        hasAccident,
        ownersCount,
        features,
      ];
}

class Seller extends Equatable {
  final String id;
  final String userId;
  final String businessName;
  final String? businessType;
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
  final Map<String, dynamic> workingHours;
  final bool isVerified;
  final DateTime? verifiedAt;
  final String subscriptionType;
  final DateTime? subscriptionExpiresAt;
  final int totalListings;
  final int activeListings;
  final int totalSold;
  final int totalViews;
  final double avgRating;
  final int totalReviews;
  final bool isFollowing;
  final DateTime createdAt;

  const Seller({
    required this.id,
    required this.userId,
    required this.businessName,
    this.businessType,
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
    required this.subscriptionType,
    this.subscriptionExpiresAt,
    required this.totalListings,
    required this.activeListings,
    required this.totalSold,
    required this.totalViews,
    required this.avgRating,
    required this.totalReviews,
    required this.isFollowing,
    required this.createdAt,
  });

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
        subscriptionType,
        subscriptionExpiresAt,
        totalListings,
        activeListings,
        totalSold,
        totalViews,
        avgRating,
        totalReviews,
        isFollowing,
        createdAt,
      ];
}
