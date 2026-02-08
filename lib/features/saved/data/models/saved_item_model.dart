import '../../domain/entities/saved_item.dart';

/// Saved item data model

class SavedItemModel extends SavedItem {
  const SavedItemModel({
    required super.id,
    required super.listingId,
    required super.title,
    required super.price,
    required super.currency,
    super.thumbnailUrl,
    required super.sellerId,
    required super.sellerName,
    required super.isSellerVerified,
    super.city,
    super.autoDetails,
    required super.savedAt,
  });

  factory SavedItemModel.fromJson(Map<String, dynamic> json) {
    final listing = json['listings'] as Map<String, dynamic>?;
    final seller = listing?['seller_profiles'] as Map<String, dynamic>?;
    final autoDetails = listing?['listing_auto_details'] as Map<String, dynamic>?;

    return SavedItemModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      title: listing?['title'] as String? ?? '',
      price: (listing?['price'] as num?)?.toDouble() ?? 0,
      currency: listing?['currency'] as String? ?? 'USD',
      thumbnailUrl: listing?['video_thumbnail_url'] as String? ??
          (listing?['images'] as List?)?.firstOrNull as String?,
      sellerId: listing?['seller_id'] as String? ?? '',
      sellerName: seller?['business_name'] as String? ?? '',
      isSellerVerified: seller?['is_verified'] as bool? ?? false,
      city: listing?['city'] as String?,
      autoDetails: autoDetails != null
          ? SavedAutoDetailsModel.fromJson(autoDetails)
          : null,
      savedAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class SavedAutoDetailsModel extends SavedAutoDetails {
  const SavedAutoDetailsModel({
    super.year,
    super.mileage,
    super.transmission,
  });

  factory SavedAutoDetailsModel.fromJson(Map<String, dynamic> json) {
    return SavedAutoDetailsModel(
      year: json['year'] as int?,
      mileage: json['mileage'] as int?,
      transmission: json['transmission'] as String?,
    );
  }
}
