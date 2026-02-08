import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../entities/reel.dart';

/// Reels repository interface

abstract class ReelsRepository {
  /// Get reels with pagination
  Future<Either<Failure, PaginatedResponse<Reel>>> getReels({
    int page = 1,
    int pageSize = 10,
  });

  /// Like a reel
  Future<Either<Failure, void>> likeReel(String reelId);

  /// Unlike a reel
  Future<Either<Failure, void>> unlikeReel(String reelId);

  /// Save a reel
  Future<Either<Failure, void>> saveReel(String reelId);

  /// Unsave a reel
  Future<Either<Failure, void>> unsaveReel(String reelId);

  /// Record reel view
  Future<Either<Failure, void>> recordView({
    required String reelId,
    required int duration,
  });

  /// Share reel
  Future<Either<Failure, void>> shareReel(String reelId);

  /// Follow seller
  Future<Either<Failure, void>> followSeller(String sellerId);

  /// Unfollow seller
  Future<Either<Failure, void>> unfollowSeller(String sellerId);
}
