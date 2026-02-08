import 'package:equatable/equatable.dart';

/// Search result entity

class SearchResult extends Equatable {
  final String id;
  final String title;
  final double price;
  final String currency;
  final String? videoThumbnailUrl;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final String? sellerLogoUrl;
  final bool isSellerVerified;
  final String? city;
  final int viewsCount;
  final int likesCount;
  final bool isLiked;
  final bool isSaved;
  final AutoSearchDetails? autoDetails;
  final DateTime createdAt;

  const SearchResult({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    this.videoThumbnailUrl,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    this.sellerLogoUrl,
    required this.isSellerVerified,
    this.city,
    required this.viewsCount,
    required this.likesCount,
    required this.isLiked,
    required this.isSaved,
    this.autoDetails,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        price,
        currency,
        videoThumbnailUrl,
        images,
        sellerId,
        sellerName,
        sellerLogoUrl,
        isSellerVerified,
        city,
        viewsCount,
        likesCount,
        isLiked,
        isSaved,
        autoDetails,
        createdAt,
      ];
}

class AutoSearchDetails extends Equatable {
  final String? brand;
  final String? model;
  final int? year;
  final int? mileage;
  final String? fuelType;
  final String? transmission;
  final String? bodyType;
  final String? color;

  const AutoSearchDetails({
    this.brand,
    this.model,
    this.year,
    this.mileage,
    this.fuelType,
    this.transmission,
    this.bodyType,
    this.color,
  });

  @override
  List<Object?> get props => [
        brand,
        model,
        year,
        mileage,
        fuelType,
        transmission,
        bodyType,
        color,
      ];
}
