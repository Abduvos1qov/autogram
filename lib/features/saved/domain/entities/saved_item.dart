import 'package:equatable/equatable.dart';

/// Saved item entity

class SavedItem extends Equatable {
  final String id;
  final String listingId;
  final String title;
  final double price;
  final String currency;
  final String? thumbnailUrl;
  final String sellerId;
  final String sellerName;
  final bool isSellerVerified;
  final String? city;
  final SavedAutoDetails? autoDetails;
  final DateTime savedAt;

  const SavedItem({
    required this.id,
    required this.listingId,
    required this.title,
    required this.price,
    required this.currency,
    this.thumbnailUrl,
    required this.sellerId,
    required this.sellerName,
    required this.isSellerVerified,
    this.city,
    this.autoDetails,
    required this.savedAt,
  });

  @override
  List<Object?> get props => [
        id,
        listingId,
        title,
        price,
        currency,
        thumbnailUrl,
        sellerId,
        sellerName,
        isSellerVerified,
        city,
        autoDetails,
        savedAt,
      ];
}

class SavedAutoDetails extends Equatable {
  final int? year;
  final int? mileage;
  final String? transmission;

  const SavedAutoDetails({
    this.year,
    this.mileage,
    this.transmission,
  });

  @override
  List<Object?> get props => [year, mileage, transmission];
}
