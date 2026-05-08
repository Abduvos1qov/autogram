import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../entities/listing.dart';

/// Listing repository interface

abstract class ListingRepository {
  /// Get listing by ID
  Future<Either<Failure, Listing>> getListing(String id);

  /// Get seller's listings.
  ///
  /// [status] optionally filters to a single listing status (e.g. only
  /// `active` or only `sold`). When `null`, returns active listings — preserved
  /// as the default for backward compatibility.
  Future<Either<Failure, PaginatedResponse<Listing>>> getSellerListings({
    required String sellerId,
    int page = 1,
    int pageSize = 20,
    ListingStatus? status,
  });

  /// Get similar listings
  Future<Either<Failure, List<Listing>>> getSimilarListings(String listingId);

  /// Like listing
  Future<Either<Failure, void>> likeListing(String listingId);

  /// Unlike listing
  Future<Either<Failure, void>> unlikeListing(String listingId);

  /// Save listing
  Future<Either<Failure, void>> saveListing(String listingId);

  /// Unsave listing
  Future<Either<Failure, void>> unsaveListing(String listingId);

  /// Share listing
  Future<Either<Failure, void>> shareListing(String listingId);

  /// Report listing
  Future<Either<Failure, void>> reportListing({
    required String listingId,
    required String reason,
    String? description,
  });

  /// Record view
  Future<Either<Failure, void>> recordView({
    required String listingId,
    int? duration,
  });

  /// Get seller by ID
  Future<Either<Failure, Seller>> getSeller(String sellerId);

  /// Follow seller
  Future<Either<Failure, void>> followSeller(String sellerId);

  /// Unfollow seller
  Future<Either<Failure, void>> unfollowSeller(String sellerId);
}
