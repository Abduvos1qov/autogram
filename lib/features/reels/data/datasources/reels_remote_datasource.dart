import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/logger.dart';
import '../models/reel_model.dart';

/// Remote data source for reels

abstract class ReelsRemoteDataSource {
  Future<PaginatedResponse<ReelModel>> getReels({
    int page = 1,
    int pageSize = 10,
  });

  Future<void> likeReel(String reelId);
  Future<void> unlikeReel(String reelId);
  Future<void> saveReel(String reelId);
  Future<void> unsaveReel(String reelId);
  Future<void> recordView({required String reelId, required int duration});
  Future<void> shareReel(String reelId);
}

class ReelsRemoteDataSourceImpl implements ReelsRemoteDataSource {
  final supabase.SupabaseClient _supabase;

  ReelsRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<PaginatedResponse<ReelModel>> getReels({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      AppLogger.info('Fetching reels: page=$page, pageSize=$pageSize');

      // Check if test mode
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Returning mock reels');
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

        final offset = (page - 1) * pageSize;
        final mockReels = MockData.mockReels;
        final paginatedReels = mockReels.skip(offset).take(pageSize).toList();

        final reelModels = paginatedReels.map((reel) => ReelModel.fromEntity(reel)).toList();

        return PaginatedResponse.fromList(
          reelModels,
          page: page,
          pageSize: pageSize,
        );
      }

      final userId = _supabase.auth.currentUser?.id;
      final offset = (page - 1) * pageSize;

      // Fetch listings with video, seller info and auto details
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
          .not('video_url', 'is', null)
          .order('views_count', ascending: false)
          .order('published_at', ascending: false)
          .range(offset, offset + pageSize - 1);

      final listings = response as List<dynamic>;

      // Get user's likes and saves if authenticated
      Set<String> likedIds = {};
      Set<String> savedIds = {};
      Set<String> followingIds = {};

      if (userId != null && listings.isNotEmpty) {
        final listingIds = listings.map((l) => l['id'] as String).toList();
        final sellerIds = listings
            .map((l) => l['seller_id'] as String)
            .toSet()
            .toList();

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

        likedIds =
            (likes as List).map((l) => l['listing_id'] as String).toSet();
        savedIds =
            (saves as List).map((s) => s['listing_id'] as String).toSet();

        // TODO: Add following logic when followers table is implemented
      }

      final reels = listings.map((json) {
        final item = Map<String, dynamic>.from(json);
        item['is_liked'] = likedIds.contains(item['id']);
        item['is_saved'] = savedIds.contains(item['id']);
        item['is_following'] = followingIds.contains(item['seller_id']);
        return ReelModel.fromJson(item);
      }).toList();

      AppLogger.info('Fetched ${reels.length} reels');

      return PaginatedResponse.fromList(
        reels,
        page: page,
        pageSize: pageSize,
      );
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error fetching reels', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      AppLogger.error('Error fetching reels', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> likeReel(String reelId) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating likeReel $reelId');
        await Future.delayed(const Duration(milliseconds: 200));
        return;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthException(message: 'Tizimga kirilmagan');
      }

      await _supabase.from(ApiEndpoints.likes).insert({
        'user_id': userId,
        'listing_id': reelId,
      });

      await _supabase.rpc('increment_likes_count', params: {
        'listing_id': reelId,
      });

      AppLogger.info('Liked reel: $reelId');
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Error liking reel', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('Error liking reel', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unlikeReel(String reelId) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating unlikeReel $reelId');
        await Future.delayed(const Duration(milliseconds: 200));
        return;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthException(message: 'Tizimga kirilmagan');
      }

      await _supabase
          .from(ApiEndpoints.likes)
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', reelId);

      await _supabase.rpc('decrement_likes_count', params: {
        'listing_id': reelId,
      });

      AppLogger.info('Unliked reel: $reelId');
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Error unliking reel', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('Error unliking reel', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveReel(String reelId) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating saveReel $reelId');
        await Future.delayed(const Duration(milliseconds: 200));
        return;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthException(message: 'Tizimga kirilmagan');
      }

      await _supabase.from(ApiEndpoints.saves).insert({
        'user_id': userId,
        'listing_id': reelId,
      });

      await _supabase.rpc('increment_saves_count', params: {
        'listing_id': reelId,
      });

      AppLogger.info('Saved reel: $reelId');
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Error saving reel', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('Error saving reel', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unsaveReel(String reelId) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating unsaveReel $reelId');
        await Future.delayed(const Duration(milliseconds: 200));
        return;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthException(message: 'Tizimga kirilmagan');
      }

      await _supabase
          .from(ApiEndpoints.saves)
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', reelId);

      await _supabase.rpc('decrement_saves_count', params: {
        'listing_id': reelId,
      });

      AppLogger.info('Unsaved reel: $reelId');
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Error unsaving reel', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('Error unsaving reel', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> recordView({
    required String reelId,
    required int duration,
  }) async {
    try {
      if (TestConfig.isTestMode) {
        // Silent: views are fire-and-forget; no log noise.
        return;
      }

      final userId = _supabase.auth.currentUser?.id;

      await _supabase.from(ApiEndpoints.views).insert({
        'user_id': userId,
        'listing_id': reelId,
        'duration': duration,
      });

      await _supabase.rpc('increment_views_count', params: {
        'listing_id': reelId,
      });
    } catch (e) {
      // Don't throw error for view recording
      AppLogger.warning('Error recording view', e);
    }
  }

  @override
  Future<void> shareReel(String reelId) async {
    try {
      if (TestConfig.isTestMode) {
        // Silent: shares are fire-and-forget; no log noise.
        return;
      }

      await _supabase.rpc('increment_shares_count', params: {
        'listing_id': reelId,
      });
    } catch (e) {
      AppLogger.warning('Error recording share', e);
    }
  }
}
