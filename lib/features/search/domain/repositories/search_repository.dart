import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../entities/filter.dart';
import '../entities/search_result.dart';

/// Search repository interface

abstract class SearchRepository {
  /// Search listings with filters
  Future<Either<Failure, PaginatedResponse<SearchResult>>> searchListings({
    String? query,
    SearchFilter? filter,
    int page = 1,
    int pageSize = 20,
  });

  /// Get available brands
  Future<Either<Failure, List<BrandModel>>> getBrands();

  /// Get models for a brand
  Future<Either<Failure, List<CarModel>>> getModels(String brandId);

  /// Get search suggestions
  Future<Either<Failure, List<String>>> getSuggestions(String query);

  /// Get recent searches
  Future<Either<Failure, List<String>>> getRecentSearches();

  /// Add to recent searches
  Future<Either<Failure, void>> addRecentSearch(String query);

  /// Clear recent searches
  Future<Either<Failure, void>> clearRecentSearches();

  /// Get popular searches
  Future<Either<Failure, List<String>>> getPopularSearches();
}
