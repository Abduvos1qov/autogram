import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart' as app_exceptions;
import '../../../../core/services/permission_service.dart';
import '../../../../core/utils/logger.dart';
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
  final supabase.SupabaseClient _supabase;

  SellerMemberRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<List<SellerMemberModel>> getTeamMembers(
      String sellerProfileId) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info(
            'TEST MODE: Returning mock team members for $sellerProfileId');
        await Future.delayed(const Duration(milliseconds: 300));
        return MockData.getMembersBySellerProfileId(sellerProfileId)
            .map((m) => SellerMemberModel(
                  id: m.id,
                  sellerProfileId: m.sellerProfileId,
                  userId: m.userId,
                  role: m.role,
                  customPermissions: m.customPermissions,
                  invitedBy: m.invitedBy,
                  invitedAt: m.invitedAt,
                  joinedAt: m.joinedAt,
                  isActive: m.isActive,
                  memberName: m.memberName,
                  memberEmail: m.memberEmail,
                  memberAvatarUrl: m.memberAvatarUrl,
                  createdAt: m.createdAt,
                  updatedAt: m.updatedAt,
                ))
            .toList();
      }

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
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'Jamoa a\'zolarini yuklashda xatolik',
      );
    }
  }

  @override
  Future<SellerMemberModel?> getMemberByUserId(
    String sellerProfileId,
    String userId,
  ) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Looking up member by userId');
        await Future.delayed(const Duration(milliseconds: 200));
        final m = MockData.getMemberByUserId(sellerProfileId, userId);
        if (m == null) return null;
        return SellerMemberModel(
          id: m.id,
          sellerProfileId: m.sellerProfileId,
          userId: m.userId,
          role: m.role,
          customPermissions: m.customPermissions,
          invitedBy: m.invitedBy,
          invitedAt: m.invitedAt,
          joinedAt: m.joinedAt,
          isActive: m.isActive,
          memberName: m.memberName,
          memberEmail: m.memberEmail,
          memberAvatarUrl: m.memberAvatarUrl,
          createdAt: m.createdAt,
          updatedAt: m.updatedAt,
        );
      }

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
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'A\'zoni topishda xatolik',
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
      if (TestConfig.isTestMode) {
        AppLogger.info(
            'TEST MODE: Simulating addMember $email role=${role.value}');
        await Future.delayed(const Duration(milliseconds: 400));
        final now = DateTime.now();
        return SellerMemberModel(
          id: 'mock_member_${now.millisecondsSinceEpoch}',
          sellerProfileId: sellerProfileId,
          userId: 'mock_user_${email.hashCode.abs()}',
          role: role,
          invitedBy: 'mock_inviter',
          invitedAt: now,
          joinedAt: now,
          isActive: true,
          memberName: email.split('@').first,
          memberEmail: email,
          createdAt: now,
          updatedAt: now,
        );
      }

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
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'Jamoa a\'zosini qo\'shishda xatolik',
      );
    }
  }

  @override
  Future<SellerMemberModel> updateMemberRole({
    required String memberId,
    required MemberRole role,
  }) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info(
            'TEST MODE: Simulating updateMemberRole $memberId -> ${role.value}');
        await Future.delayed(const Duration(milliseconds: 300));
        final now = DateTime.now();
        // Find existing mock member if available
        final existing = MockData.mockSellerMembers
            .where((m) => m.id == memberId)
            .toList();
        if (existing.isNotEmpty) {
          final m = existing.first;
          return SellerMemberModel(
            id: m.id,
            sellerProfileId: m.sellerProfileId,
            userId: m.userId,
            role: role,
            customPermissions: m.customPermissions,
            invitedBy: m.invitedBy,
            invitedAt: m.invitedAt,
            joinedAt: m.joinedAt,
            isActive: m.isActive,
            memberName: m.memberName,
            memberEmail: m.memberEmail,
            memberAvatarUrl: m.memberAvatarUrl,
            createdAt: m.createdAt,
            updatedAt: now,
          );
        }
        return SellerMemberModel(
          id: memberId,
          sellerProfileId: 'seller1',
          userId: 'mock_user',
          role: role,
          isActive: true,
          memberName: 'Mock Member',
          createdAt: now,
          updatedAt: now,
        );
      }

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
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'A\'zo rolini yangilashda xatolik',
      );
    }
  }

  @override
  Future<void> removeMember(String memberId) async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating removeMember $memberId');
        await Future.delayed(const Duration(milliseconds: 300));
        return;
      }

      // Soft delete — set is_active to false
      await _supabase
          .from(ApiEndpoints.sellerMembers)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', memberId);
    } catch (e) {
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'A\'zoni o\'chirishda xatolik',
      );
    }
  }

  @override
  Future<SellerMemberModel?> getCurrentMembership() async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: getCurrentMembership returning null');
        await Future.delayed(const Duration(milliseconds: 200));
        return null;
      }

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
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'A\'zolikni tekshirishda xatolik',
      );
    }
  }
}
