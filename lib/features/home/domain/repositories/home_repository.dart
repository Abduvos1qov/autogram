import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../entities/feed_item.dart';

/// Home repository interface

abstract class HomeRepository {
  /// Get feed items with pagination
  Future<Either<Failure, PaginatedResponse<FeedItem>>> getFeed({
    int page = 1,
    int pageSize = 20,
  });

  /// Like a listing
  Future<Either<Failure, void>> likeListing(String listingId);

  /// Unlike a listing
  Future<Either<Failure, void>> unlikeListing(String listingId);

  /// Save a listing
  Future<Either<Failure, void>> saveListing(String listingId);

  /// Unsave a listing
  Future<Either<Failure, void>> unsaveListing(String listingId);

  /// Record a view
  Future<Either<Failure, void>> recordView({
    required String listingId,
    int? duration,
  });
}
