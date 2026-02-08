import '../../../listing/domain/entities/listing.dart';
import '../../domain/entities/search_result.dart';

/// Search result data model

class SearchResultModel extends SearchResult {
  const SearchResultModel({
    required super.id,
    required super.title,
    required super.price,
    required super.currency,
    super.videoThumbnailUrl,
    required super.images,
    required super.sellerId,
    required super.sellerName,
    super.sellerLogoUrl,
    required super.isSellerVerified,
    super.city,
    required super.viewsCount,
    required super.likesCount,
    required super.isLiked,
    required super.isSaved,
    super.autoDetails,
    required super.createdAt,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    final seller = json['seller_profiles'] as Map<String, dynamic>?;
    final autoDetails = json['listing_auto_details'] as Map<String, dynamic>?;

    return SearchResultModel(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      videoThumbnailUrl: json['video_thumbnail_url'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sellerId: json['seller_id'] as String,
      sellerName: seller?['business_name'] as String? ?? 'Unknown',
      sellerLogoUrl: seller?['logo_url'] as String?,
      isSellerVerified: seller?['is_verified'] as bool? ?? false,
      city: json['city'] as String?,
      viewsCount: json['views_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      autoDetails: autoDetails != null
          ? AutoSearchDetailsModel.fromJson(autoDetails)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'currency': currency,
      'video_thumbnail_url': videoThumbnailUrl,
      'images': images,
      'seller_id': sellerId,
      'city': city,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SearchResultModel.fromListing(Listing listing) {
    return SearchResultModel(
      id: listing.id,
      title: listing.title,
      price: listing.price,
      currency: listing.currency,
      videoThumbnailUrl: listing.videoThumbnailUrl,
      images: listing.images,
      sellerId: listing.sellerId,
      sellerName: listing.seller.businessName,
      sellerLogoUrl: listing.seller.logoUrl,
      isSellerVerified: listing.seller.isVerified,
      city: listing.city,
      viewsCount: listing.viewsCount,
      likesCount: listing.likesCount,
      isLiked: listing.isLiked,
      isSaved: listing.isSaved,
      autoDetails: listing.autoDetails != null
          ? AutoSearchDetailsModel(
              brand: listing.autoDetails!.brand,
              model: listing.autoDetails!.model,
              year: listing.autoDetails!.year,
              mileage: listing.autoDetails!.mileage,
              fuelType: listing.autoDetails!.fuelType,
              transmission: listing.autoDetails!.transmission,
              bodyType: listing.autoDetails!.bodyType,
              color: listing.autoDetails!.color,
            )
          : null,
      createdAt: listing.createdAt,
    );
  }
}

class AutoSearchDetailsModel extends AutoSearchDetails {
  const AutoSearchDetailsModel({
    super.brand,
    super.model,
    super.year,
    super.mileage,
    super.fuelType,
    super.transmission,
    super.bodyType,
    super.color,
  });

  factory AutoSearchDetailsModel.fromJson(Map<String, dynamic> json) {
    return AutoSearchDetailsModel(
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      mileage: json['mileage'] as int?,
      fuelType: json['fuel_type'] as String?,
      transmission: json['transmission'] as String?,
      bodyType: json['body_type'] as String?,
      color: json['color'] as String?,
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
      'body_type': bodyType,
      'color': color,
    };
  }
}
