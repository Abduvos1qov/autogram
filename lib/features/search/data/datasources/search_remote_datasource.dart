import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/filter.dart';
import '../models/filter_model.dart';
import '../models/search_result_model.dart';

/// Search remote data source

abstract class SearchRemoteDataSource {
  Future<PaginatedResponse<SearchResultModel>> searchListings({
    String? query,
    SearchFilter? filter,
    int page = 1,
    int pageSize = 20,
  });

  Future<List<BrandModelData>> getBrands();

  Future<List<CarModelData>> getModels(String brandId);

  Future<List<String>> getSuggestions(String query);

  Future<List<String>> getPopularSearches();
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  SearchRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<PaginatedResponse<SearchResultModel>> searchListings({
    String? query,
    SearchFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // Check if test mode
      if (TestConfig.isTestMode) {
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

        final results = MockData.searchListings(
          query: query,
          brand: filter?.brand,
          model: filter?.model,
          minYear: filter?.minYear,
          maxYear: filter?.maxYear,
          minPrice: filter?.minPrice,
          maxPrice: filter?.maxPrice,
          city: filter?.city,
        );

        final offset = (page - 1) * pageSize;
        final paginatedResults = results.skip(offset).take(pageSize).toList();

        final searchResultModels = paginatedResults
            .map((listing) => SearchResultModel.fromListing(listing))
            .toList();

        return PaginatedResponse.fromList(
          searchResultModels,
          page: page,
          pageSize: pageSize,
        );
      }

      final userId = supabaseClient.auth.currentUser?.id;
      final offset = (page - 1) * pageSize;

      var queryBuilder = supabaseClient
          .from(ApiEndpoints.listings)
          .select('''
            *,
            seller_profiles!inner(
              id,
              business_name,
              logo_url,
              is_verified
            ),
            listing_auto_details(*)
          ''')
          .eq('status', 'active');

      // Apply text search
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or('title.ilike.%$query%,description.ilike.%$query%');
      }

      // Apply filters
      if (filter != null) {
        if (filter.minPrice != null) {
          queryBuilder = queryBuilder.gte('price', filter.minPrice!);
        }
        if (filter.maxPrice != null) {
          queryBuilder = queryBuilder.lte('price', filter.maxPrice!);
        }
        if (filter.city != null) {
          queryBuilder = queryBuilder.eq('city', filter.city!);
        }
        if (filter.verifiedSellersOnly == true) {
          queryBuilder = queryBuilder.eq('seller_profiles.is_verified', true);
        }

        // Sort - don't reassign as order changes builder type
      }

      // Apply sorting and execute query
      dynamic sortedQuery;
      if (filter != null) {
        switch (filter.sortBy) {
          case SortOption.newest:
            sortedQuery = queryBuilder.order('created_at', ascending: false);
            break;
          case SortOption.oldest:
            sortedQuery = queryBuilder.order('created_at', ascending: true);
            break;
          case SortOption.priceLow:
            sortedQuery = queryBuilder.order('price', ascending: true);
            break;
          case SortOption.priceHigh:
            sortedQuery = queryBuilder.order('price', ascending: false);
            break;
          case SortOption.popular:
            sortedQuery = queryBuilder.order('views_count', ascending: false);
            break;
          case SortOption.mileageLow:
            sortedQuery = queryBuilder.order('created_at', ascending: false);
            break;
        }
      } else {
        sortedQuery = queryBuilder.order('created_at', ascending: false);
      }

      final response = await sortedQuery.range(offset, offset + pageSize - 1);

      final results = (response as List)
          .map((json) => _addUserInteractions(json, userId))
          .map((json) => SearchResultModel.fromJson(json))
          .toList();

      // Get total count
      final countResponse = await supabaseClient
          .from(ApiEndpoints.listings)
          .select('id')
          .eq('status', 'active')
          .count(supabase.CountOption.exact);

      final totalCount = countResponse.count;

      return PaginatedResponse(
        data: results,
        page: page,
        pageSize: pageSize,
      total: totalCount, hasMore: true,
      );
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Map<String, dynamic> _addUserInteractions(
    Map<String, dynamic> json,
    String? userId,
  ) {
    // Default values if user not logged in
    json['is_liked'] = false;
    json['is_saved'] = false;
    return json;
  }

  @override
  Future<List<BrandModelData>> getBrands() async {
    try {
      final response = await supabaseClient
          .from('brands')
          .select('*')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => BrandModelData.fromJson(json))
          .toList();
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CarModelData>> getModels(String brandId) async {
    try {
      final response = await supabaseClient
          .from('models')
          .select('*')
          .eq('brand_id', brandId)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => CarModelData.fromJson(json))
          .toList();
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<String>> getSuggestions(String query) async {
    try {
      final response = await supabaseClient
          .from(ApiEndpoints.listings)
          .select('title')
          .ilike('title', '%$query%')
          .limit(10);

      return (response as List)
          .map((json) => json['title'] as String)
          .toSet()
          .toList();
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<String>> getPopularSearches() async {
    // Return static popular searches for now
    // In production, this would be based on analytics
    return [
      'Gentra',
      'Malibu',
      'Cobalt',
      'Nexia',
      'Lacetti',
      'Tracker',
      'Camry',
      'Spark',
    ];
  }
}
