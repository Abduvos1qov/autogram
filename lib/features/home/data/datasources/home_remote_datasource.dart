import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/logger.dart';
import '../models/feed_item_model.dart';

/// Remote data source for home feed

abstract class HomeRemoteDataSource {
  Future<PaginatedResponse<FeedItemModel>> getFeed({
    int page = 1,
    int pageSize = 20,
  });

  Future<void> likeListing(String listingId);
  Future<void> unlikeListing(String listingId);
  Future<void> saveListing(String listingId);
  Future<void> unsaveListing(String listingId);
  Future<void> recordView({required String listingId, int? duration});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final supabase.SupabaseClient _supabase;

  HomeRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<PaginatedResponse<FeedItemModel>> getFeed({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      AppLogger.info('Fetching feed: page=$page, pageSize=$pageSize');

      // Check if test mode
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Returning mock feed items');
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

        final offset = (page - 1) * pageSize;
        final mockFeedItems = MockData.mockFeedItems;
        final paginatedItems = mockFeedItems.skip(offset).take(pageSize).toList();

        final feedItemModels = paginatedItems.map((item) => FeedItemModel.fromEntity(item)).toList();

        return PaginatedResponse.fromList(
          feedItemModels,
          page: page,
          pageSize: pageSize,
        );
      }

      final userId = _supabase.auth.currentUser?.id;
      final offset = (page - 1) * pageSize;

      // Fetch listings with seller info and auto details
      final response = await _supabase
          .from(ApiEndpoints.listings)
          .select('''
            *,
            seller_profiles!inner (
              id,
              business_name,
              logo_url,
              is_verified
            ),
            listing_auto_details (*)
          ''')
          .eq('status', 'active')
          .order('published_at', ascending: false)
          .range(offset, offset + pageSize - 1);

      final listings = response as List<dynamic>;

      // Get user's likes and saves if authenticated
      Set<String> likedIds = {};
      Set<String> savedIds = {};

      if (userId != null && listings.isNotEmpty) {
        final listingIds = listings.map((l) => l['id'] as String).toList();

        final likes = await _supabase
            .from(ApiEndpoints.likes)
            .select('listing_id')
            .eq('user_id', userId)
            .inFilter('listing_id', listingIds);

        final saves = await _supabase
            .from(ApiEndpoints.saves)
            .select('listing_id')
            .eq('user_id', userId)
            .inFilter('listing_id', listingIds);

        likedIds = (likes as List).map((l) => l['listing_id'] as String).toSet();
        savedIds = (saves as List).map((s) => s['listing_id'] as String).toSet();
      }

      final items = listings.map((json) {
        final item = Map<String, dynamic>.from(json);
        item['is_liked'] = likedIds.contains(item['id']);
        item['is_saved'] = savedIds.contains(item['id']);
        return FeedItemModel.fromJson(item);
      }).toList();

      AppLogger.info('Fetched ${items.length} feed items');

      return PaginatedResponse.fromList(
        items,
        page: page,
        pageSize: pageSize,
      );
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error fetching feed', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      AppLogger.error('Error fetching feed', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> likeListing(String listingId) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating likeListing $listingId');
        await Future.delayed(const Duration(milliseconds: 200));
        return;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Tizimga kirilmagan');

      await _supabase.from(ApiEndpoints.likes).insert({
        'user_id': userId,
        'listing_id': listingId,
      });

      // Increment likes_count
      await _supabase.rpc('increment_likes_count', params: {
        'listing_id': listingId,
      });

      AppLogger.info('Liked listing: $listingId');
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Error liking listing', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('Error liking listing', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unlikeListing(String listingId) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating unlikeListing $listingId');
        await Future.delayed(const Duration(milliseconds: 200));
        return;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Tizimga kirilmagan');

      await _supabase
          .from(ApiEndpoints.likes)
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);

      // Decrement likes_count
      await _supabase.rpc('decrement_likes_count', params: {
        'listing_id': listingId,
      });

      AppLogger.info('Unliked listing: $listingId');
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Error unliking listing', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('Error unliking listing', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveListing(String listingId) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating saveListing $listingId');
        await Future.delayed(const Duration(milliseconds: 200));
        return;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Tizimga kirilmagan');

      await _supabase.from(ApiEndpoints.saves).insert({
        'user_id': userId,
        'listing_id': listingId,
      });

      // Increment saves_count
      await _supabase.rpc('increment_saves_count', params: {
        'listing_id': listingId,
      });

      AppLogger.info('Saved listing: $listingId');
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Error saving listing', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('Error saving listing', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unsaveListing(String listingId) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating unsaveListing $listingId');
        await Future.delayed(const Duration(milliseconds: 200));
        return;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Tizimga kirilmagan');

      await _supabase
          .from(ApiEndpoints.saves)
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);

      // Decrement saves_count
      await _supabase.rpc('decrement_saves_count', params: {
        'listing_id': listingId,
      });

      AppLogger.info('Unsaved listing: $listingId');
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Error unsaving listing', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('Error unsaving listing', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> recordView({
    required String listingId,
    int? duration,
  }) async {
    try {
      if (TestConfig.isTestMode) {
        // Silent: views are fire-and-forget; no log noise.
        return;
      }

      final userId = _supabase.auth.currentUser?.id;

      await _supabase.from(ApiEndpoints.views).insert({
        'user_id': userId,
        'listing_id': listingId,
        'duration': duration,
      });

      // Increment views_count
      await _supabase.rpc('increment_views_count', params: {
        'listing_id': listingId,
      });
    } catch (e) {
      // Don't throw error for view recording
      AppLogger.warning('Error recording view', e);
    }
  }
}
