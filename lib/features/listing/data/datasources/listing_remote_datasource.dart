import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/listing.dart';
import '../models/listing_model.dart';

/// Listing remote data source

abstract class ListingRemoteDataSource {
  Future<ListingModel> getListing(String id);
  Future<PaginatedResponse<ListingModel>> getSellerListings({
    required String sellerId,
    int page = 1,
    int pageSize = 20,
    ListingStatus? status,
  });
  Future<List<ListingModel>> getSimilarListings(String listingId);
  Future<void> likeListing(String listingId);
  Future<void> unlikeListing(String listingId);
  Future<void> saveListing(String listingId);
  Future<void> unsaveListing(String listingId);
  Future<void> shareListing(String listingId);
  Future<void> reportListing({
    required String listingId,
    required String reason,
    String? description,
  });
  Future<void> recordView({
    required String listingId,
    int? duration,
  });
  Future<SellerModel> getSeller(String sellerId);
  Future<void> followSeller(String sellerId);
  Future<void> unfollowSeller(String sellerId);
}

class ListingRemoteDataSourceImpl implements ListingRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  ListingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ListingModel> getListing(String id) async {
    try {
      // Check if test mode
      if (TestConfig.isTestMode) {
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        final listing = MockData.getListingById(id);
        if (listing == null) {
          throw const NotFoundException(message: 'E\'lon topilmadi');
        }
        return ListingModel.fromEntity(listing);
      }

      final response = await supabaseClient
          .from(ApiEndpoints.listings)
          .select('''
            *,
            seller_profiles(*),
            listing_auto_details(*)
          ''')
          .eq('id', id)
          .single();

      return ListingModel.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PaginatedResponse<ListingModel>> getSellerListings({
    required String sellerId,
    int page = 1,
    int pageSize = 20,
    ListingStatus? status,
  }) async {
    try {
      final filterStatus = status ?? ListingStatus.active;

      if (TestConfig.isTestMode) {
        await Future.delayed(const Duration(milliseconds: 400));
        final all = MockData.mockListings
            .where(
              (l) => l.sellerId == sellerId && l.status == filterStatus,
            )
            .toList();

        final start = (page - 1) * pageSize;
        if (start >= all.length) {
          return PaginatedResponse(
            data: const [],
            page: page,
            pageSize: pageSize,
            total: all.length,
            hasMore: false,
          );
        }
        final end = (start + pageSize).clamp(0, all.length);
        final pageItems = all
            .sublist(start, end)
            .map((l) => ListingModel.fromEntity(l))
            .toList();

        return PaginatedResponse(
          data: pageItems,
          page: page,
          pageSize: pageSize,
          total: all.length,
          hasMore: end < all.length,
        );
      }

      final offset = (page - 1) * pageSize;

      final response = await supabaseClient
          .from(ApiEndpoints.listings)
          .select('''
            *,
            seller_profiles(*),
            listing_auto_details(*)
          ''')
          .eq('seller_id', sellerId)
          .eq('status', filterStatus.name)
          .order('created_at', ascending: false)
          .range(offset, offset + pageSize - 1);

      final listings = (response as List)
          .map((json) => ListingModel.fromJson(json))
          .toList();

      final countResponse = await supabaseClient
          .from(ApiEndpoints.listings)
          .select('id')
          .eq('seller_id', sellerId)
          .eq('status', filterStatus.name)
          .count(supabase.CountOption.exact);

      final total = countResponse.count;
      return PaginatedResponse(
        data: listings,
        page: page,
        pageSize: pageSize,
        total: total,
        hasMore: (page * pageSize) < total,
      );
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ListingModel>> getSimilarListings(String listingId) async {
    try {
      // First get the listing to find similar ones
      final listing = await getListing(listingId);

      final response = await supabaseClient
          .from(ApiEndpoints.listings)
          .select('''
            *,
            seller_profiles(*),
            listing_auto_details(*)
          ''')
          .neq('id', listingId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(10);

      return (response as List)
          .map((json) => ListingModel.fromJson(json))
          .toList();
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> likeListing(String listingId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Tizimga kirilmagan');

      await supabaseClient.from(ApiEndpoints.likes).insert({
        'user_id': userId,
        'listing_id': listingId,
      });

      // Update likes count
      await supabaseClient.rpc('increment_likes', params: {
        'listing_id': listingId,
      });
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unlikeListing(String listingId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Tizimga kirilmagan');

      await supabaseClient
          .from(ApiEndpoints.likes)
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);

      // Update likes count
      await supabaseClient.rpc('decrement_likes', params: {
        'listing_id': listingId,
      });
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveListing(String listingId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Tizimga kirilmagan');

      await supabaseClient.from(ApiEndpoints.saves).insert({
        'user_id': userId,
        'listing_id': listingId,
      });
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unsaveListing(String listingId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Tizimga kirilmagan');

      await supabaseClient
          .from(ApiEndpoints.saves)
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> shareListing(String listingId) async {
    try {
      await supabaseClient.rpc('increment_shares', params: {
        'listing_id': listingId,
      });
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> reportListing({
    required String listingId,
    required String reason,
    String? description,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      await supabaseClient.from('reports').insert({
        'user_id': userId,
        'listing_id': listingId,
        'reason': reason,
        'description': description,
      });
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> recordView({
    required String listingId,
    int? duration,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      await supabaseClient.from(ApiEndpoints.views).insert({
        'user_id': userId,
        'listing_id': listingId,
        'duration': duration,
      });

      // Update views count
      await supabaseClient.rpc('increment_views', params: {
        'listing_id': listingId,
      });
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SellerModel> getSeller(String sellerId) async {
    try {
      final response = await supabaseClient
          .from(ApiEndpoints.sellerProfiles)
          .select('*')
          .eq('id', sellerId)
          .single();

      return SellerModel.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> followSeller(String sellerId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Tizimga kirilmagan');

      await supabaseClient.from('follows').insert({
        'user_id': userId,
        'seller_id': sellerId,
      });
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unfollowSeller(String sellerId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Tizimga kirilmagan');

      await supabaseClient
          .from('follows')
          .delete()
          .eq('user_id', userId)
          .eq('seller_id', sellerId);
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
