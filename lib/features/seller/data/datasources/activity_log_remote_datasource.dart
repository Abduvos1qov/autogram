import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart' as app_exceptions;
import '../../domain/entities/activity_log.dart';
import '../models/activity_log_model.dart';

/// Remote data source interface for activity logs

abstract class ActivityLogRemoteDataSource {
  /// Log a new activity
  Future<void> logActivity({
    required String sellerProfileId,
    required ActivityType actionType,
    required String description,
    Map<String, dynamic>? metadata,
  });

  /// Get activity logs with optional filters and pagination
  Future<List<ActivityLogModel>> getActivityLogs({
    required String sellerProfileId,
    String? filterCategory,
    String? userId,
    int page = 1,
    int pageSize = 20,
  });

  /// Get activity logs for a specific member
  Future<List<ActivityLogModel>> getMemberActivityLogs({
    required String sellerProfileId,
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
}

/// Implementation using Supabase

class ActivityLogRemoteDataSourceImpl implements ActivityLogRemoteDataSource {
  final supabase.SupabaseClient _supabase;

  ActivityLogRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  static const _selectWithJoins =
      '*, actor:user_id(full_name, avatar_url)';

  @override
  Future<void> logActivity({
    required String sellerProfileId,
    required ActivityType actionType,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw app_exceptions.AuthException(
          message: 'Foydalanuvchi tizimga kirmagan',
        );
      }

      await _supabase.from(ApiEndpoints.memberActivityLog).insert({
        'seller_profile_id': sellerProfileId,
        'user_id': currentUser.id,
        'action_type': actionType.value,
        'description': description,
        if (metadata != null) 'metadata': metadata,
      });
    } on app_exceptions.AuthException {
      rethrow;
    } catch (e) {
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'Faoliyatni qayd qilishda xatolik',
      );
    }
  }

  @override
  Future<List<ActivityLogModel>> getActivityLogs({
    required String sellerProfileId,
    String? filterCategory,
    String? userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      var query = _supabase
          .from(ApiEndpoints.memberActivityLog)
          .select(_selectWithJoins)
          .eq('seller_profile_id', sellerProfileId);

      // Apply user filter
      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      // Apply category filter by filtering action_type values
      if (filterCategory != null) {
        final actionTypes = _getActionTypesForCategory(filterCategory);
        if (actionTypes.isNotEmpty) {
          query = query.inFilter(
            'action_type',
            actionTypes.map((t) => t.value).toList(),
          );
        }
      }

      // Pagination
      final offset = (page - 1) * pageSize;
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + pageSize - 1);

      return (response as List)
          .map((json) => ActivityLogModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'Faoliyat tarixini yuklashda xatolik',
      );
    }
  }

  @override
  Future<List<ActivityLogModel>> getMemberActivityLogs({
    required String sellerProfileId,
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return getActivityLogs(
      sellerProfileId: sellerProfileId,
      userId: userId,
      page: page,
      pageSize: pageSize,
    );
  }

  List<ActivityType> _getActionTypesForCategory(String category) {
    return ActivityType.values
        .where((t) => t.category == category)
        .toList();
  }
}
