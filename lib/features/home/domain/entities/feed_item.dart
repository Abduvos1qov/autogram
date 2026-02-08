import 'package:equatable/equatable.dart';

/// Feed item entity - represents a listing in the home feed

class FeedItem extends Equatable {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? sellerLogoUrl;
  final bool isSellerVerified;
  final String title;
  final String? description;
  final double price;
  final String currency;
  final bool isNegotiable;
  final String? videoUrl;
  final String? videoThumbnailUrl;
  final int? videoDuration;
  final List<String> images;
  final String? city;
  final String? district;
  final AutoDetails? autoDetails;
  final int viewsCount;
  final int likesCount;
  final int savesCount;
  final bool isLiked;
  final bool isSaved;
  final DateTime publishedAt;

  const FeedItem({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerLogoUrl,
    required this.isSellerVerified,
    required this.title,
    this.description,
    required this.price,
    required this.currency,
    required this.isNegotiable,
    this.videoUrl,
    this.videoThumbnailUrl,
    this.videoDuration,
    required this.images,
    this.city,
    this.district,
    this.autoDetails,
    required this.viewsCount,
    required this.likesCount,
    required this.savesCount,
    required this.isLiked,
    required this.isSaved,
    required this.publishedAt,
  });

  String get location {
    if (city != null && district != null) {
      return '$district, $city';
    }
    return city ?? '';
  }

  String get thumbnailUrl => videoThumbnailUrl ?? images.firstOrNull ?? '';

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  FeedItem copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? sellerLogoUrl,
    bool? isSellerVerified,
    String? title,
    String? description,
    double? price,
    String? currency,
    bool? isNegotiable,
    String? videoUrl,
    String? videoThumbnailUrl,
    int? videoDuration,
    List<String>? images,
    String? city,
    String? district,
    AutoDetails? autoDetails,
    int? viewsCount,
    int? likesCount,
    int? savesCount,
    bool? isLiked,
    bool? isSaved,
    DateTime? publishedAt,
  }) {
    return FeedItem(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerLogoUrl: sellerLogoUrl ?? this.sellerLogoUrl,
      isSellerVerified: isSellerVerified ?? this.isSellerVerified,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
      videoDuration: videoDuration ?? this.videoDuration,
      images: images ?? this.images,
      city: city ?? this.city,
      district: district ?? this.district,
      autoDetails: autoDetails ?? this.autoDetails,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sellerId,
        sellerName,
        sellerLogoUrl,
        isSellerVerified,
        title,
        description,
        price,
        currency,
        isNegotiable,
        videoUrl,
        videoThumbnailUrl,
        videoDuration,
        images,
        city,
        district,
        autoDetails,
        viewsCount,
        likesCount,
        savesCount,
        isLiked,
        isSaved,
        publishedAt,
      ];
}

/// Auto details for car listings

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
  });

  String get fullName {
    if (brand != null && model != null) {
      return '$brand $model';
    }
    return brand ?? model ?? '';
  }

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
      ];
}
