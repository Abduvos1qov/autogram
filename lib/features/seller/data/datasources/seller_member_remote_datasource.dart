import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart' as app_exceptions;
import '../../../../core/services/permission_service.dart';
import '../models/seller_member_model.dart';

/// Remote data source interface for seller members

abstract class SellerMemberRemoteDataSource {
  /// Get all team members for a seller organization
  Future<List<SellerMemberModel>> getTeamMembers(String sellerProfileId);

  /// Get a specific member by user ID within a seller organization
  Future<SellerMemberModel?> getMemberByUserId(
    String sellerProfileId,
    String userId,
  );

  /// Add a new member to the organization
  Future<SellerMemberModel> addMember({
    required String sellerProfileId,
    required String email,
    required MemberRole role,
  });

  /// Update a member's role
  Future<SellerMemberModel> updateMemberRole({
    required String memberId,
    required MemberRole role,
  });

  /// Remove (deactivate) a member
  Future<void> removeMember(String memberId);

  /// Get the current user's membership
  Future<SellerMemberModel?> getCurrentMembership();
}

/// Implementation using Supabase

class SellerMemberRemoteDataSourceImpl implements SellerMemberRemoteDataSource {
  final SupabaseClient _supabase;

  SellerMemberRemoteDataSourceImpl({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<List<SellerMemberModel>> getTeamMembers(
      String sellerProfileId) async {
    try {
      final response = await _supabase
          .from(ApiEndpoints.sellerMembers)
          .select('*, profiles:user_id(full_name, email, avatar_url)')
          .eq('seller_profile_id', sellerProfileId)
          .eq('is_active', true)
          .order('created_at');

      return (response as List)
          .map((json) => SellerMemberModel.fromJson(json))
          .toList();
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Jamoa a\'zolarini yuklashda xatolik: $e',
      );
    }
  }

  @override
  Future<SellerMemberModel?> getMemberByUserId(
    String sellerProfileId,
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from(ApiEndpoints.sellerMembers)
          .select('*, profiles:user_id(full_name, email, avatar_url)')
          .eq('seller_profile_id', sellerProfileId)
          .eq('user_id', userId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return SellerMemberModel.fromJson(response);
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'A\'zoni topishda xatolik: $e',
      );
    }
  }

  @override
  Future<SellerMemberModel> addMember({
    required String sellerProfileId,
    required String email,
    required MemberRole role,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw app_exceptions.AuthException(
          message: 'Foydalanuvchi tizimga kirmagan',
        );
      }

      // Look up user by email in profiles table
      final userResponse = await _supabase
          .from(ApiEndpoints.profiles)
          .select('id, full_name, email, avatar_url')
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) {
        throw app_exceptions.NotFoundException(
          message: 'Bu email bilan foydalanuvchi topilmadi: $email',
        );
      }

      final targetUserId = userResponse['id'] as String;

      // Check if already a member
      final existing = await _supabase
          .from(ApiEndpoints.sellerMembers)
          .select('id')
          .eq('seller_profile_id', sellerProfileId)
          .eq('user_id', targetUserId)
          .maybeSingle();

      if (existing != null) {
        throw app_exceptions.ValidationException(
          message: 'Bu foydalanuvchi allaqachon jamoa a\'zosi',
        );
      }

      // Insert new member
      final now = DateTime.now().toIso8601String();
      final insertData = {
        'seller_profile_id': sellerProfileId,
        'user_id': targetUserId,
        'role': role.value,
        'invited_by': currentUser.id,
        'invited_at': now,
        'joined_at': now, // Auto-join for now (invitation flow can be added later)
        'is_active': true,
        'member_name': userResponse['full_name'] as String? ?? 'Noma\'lum',
        'member_email': userResponse['email'] as String?,
        'member_avatar_url': userResponse['avatar_url'] as String?,
      };

      final response = await _supabase
          .from(ApiEndpoints.sellerMembers)
          .insert(insertData)
          .select('*, profiles:user_id(full_name, email, avatar_url)')
          .single();

      return SellerMemberModel.fromJson(response);
    } on app_exceptions.AuthException {
      rethrow;
    } on app_exceptions.NotFoundException {
      rethrow;
    } on app_exceptions.ValidationException {
      rethrow;
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Jamoa a\'zosini qo\'shishda xatolik: $e',
      );
    }
  }

  @override
  Future<SellerMemberModel> updateMemberRole({
    required String memberId,
    required MemberRole role,
  }) async {
    try {
      final response = await _supabase
          .from(ApiEndpoints.sellerMembers)
          .update({
            'role': role.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', memberId)
          .select('*, profiles:user_id(full_name, email, avatar_url)')
          .single();

      return SellerMemberModel.fromJson(response);
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'A\'zo rolini yangilashda xatolik: $e',
      );
    }
  }

  @override
  Future<void> removeMember(String memberId) async {
    try {
      // Soft delete — set is_active to false
      await _supabase
          .from(ApiEndpoints.sellerMembers)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', memberId);
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'A\'zoni o\'chirishda xatolik: $e',
      );
    }
  }

  @override
  Future<SellerMemberModel?> getCurrentMembership() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return null;

      final response = await _supabase
          .from(ApiEndpoints.sellerMembers)
          .select('*, profiles:user_id(full_name, email, avatar_url)')
          .eq('user_id', currentUser.id)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return SellerMemberModel.fromJson(response);
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'A\'zolikni tekshirishda xatolik: $e',
      );
    }
  }
}
