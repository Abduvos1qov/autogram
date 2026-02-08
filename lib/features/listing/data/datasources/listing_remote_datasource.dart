import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../models/listing_model.dart';

/// Listing remote data source

abstract class ListingRemoteDataSource {
  Future<ListingModel> getListing(String id);
  Future<PaginatedResponse<ListingModel>> getSellerListings({
    required String sellerId,
    int page = 1,
    int pageSize = 20,
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
  final SupabaseClient supabaseClient;

  ListingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ListingModel> getListing(String id) async {
    try {
      // Check if test mode
      if (TestConfig.isTestMode) {
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        final listing = MockData.getListingById(id);
        if (listing == null) {
          throw const ServerException(message: 'Listing not found');
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
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PaginatedResponse<ListingModel>> getSellerListings({
    required String sellerId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final offset = (page - 1) * pageSize;

      final response = await supabaseClient
          .from(ApiEndpoints.listings)
          .select('''
            *,
            seller_profiles(*),
            listing_auto_details(*)
          ''')
          .eq('seller_id', sellerId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .range(offset, offset + pageSize - 1);

      final listings = (response as List)
          .map((json) => ListingModel.fromJson(json))
          .toList();

      final countResponse = await supabaseClient
          .from(ApiEndpoints.listings)
          .select('id')
          .eq('seller_id', sellerId)
          .eq('status', 'active')
          .count(CountOption.exact);

      final total = countResponse.count;
      return PaginatedResponse(
        data: listings,
        page: page,
        pageSize: pageSize,
        total: total,
        hasMore: (page * pageSize) < total,
      );
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
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
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> likeListing(String listingId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      await supabaseClient.from(ApiEndpoints.likes).insert({
        'user_id': userId,
        'listing_id': listingId,
      });

      // Update likes count
      await supabaseClient.rpc('increment_likes', params: {
        'listing_id': listingId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unlikeListing(String listingId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      await supabaseClient
          .from(ApiEndpoints.likes)
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);

      // Update likes count
      await supabaseClient.rpc('decrement_likes', params: {
        'listing_id': listingId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveListing(String listingId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      await supabaseClient.from(ApiEndpoints.saves).insert({
        'user_id': userId,
        'listing_id': listingId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unsaveListing(String listingId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      await supabaseClient
          .from(ApiEndpoints.saves)
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> shareListing(String listingId) async {
    try {
      await supabaseClient.rpc('increment_shares', params: {
        'listing_id': listingId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
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
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
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
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
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
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> followSeller(String sellerId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      await supabaseClient.from('follows').insert({
        'user_id': userId,
        'seller_id': sellerId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unfollowSeller(String sellerId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      await supabaseClient
          .from('follows')
          .delete()
          .eq('user_id', userId)
          .eq('seller_id', sellerId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
