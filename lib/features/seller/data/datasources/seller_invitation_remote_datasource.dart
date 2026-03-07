import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart' as app_exceptions;
import '../../../../core/services/permission_service.dart';
import '../models/seller_invitation_model.dart';

/// Remote data source interface for seller invitations

abstract class SellerInvitationRemoteDataSource {
  /// Send an invitation
  Future<SellerInvitationModel> sendInvitation({
    required String sellerProfileId,
    required String email,
    required MemberRole role,
  });

  /// Get pending invitations for a seller organization
  Future<List<SellerInvitationModel>> getPendingInvitations(
      String sellerProfileId);

  /// Accept an invitation (also creates SellerMember record)
  Future<SellerInvitationModel> acceptInvitation(String invitationId);

  /// Reject an invitation
  Future<SellerInvitationModel> rejectInvitation(String invitationId);

  /// Cancel (revoke) an invitation
  Future<void> cancelInvitation(String invitationId);

  /// Get invitations for the current user's email
  Future<List<SellerInvitationModel>> getMyInvitations();
}

/// Implementation using Supabase

class SellerInvitationRemoteDataSourceImpl
    implements SellerInvitationRemoteDataSource {
  final supabase.SupabaseClient _supabase;

  SellerInvitationRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  static const _selectWithJoins =
      '*, inviter:invited_by(full_name, avatar_url), seller_profile:seller_profile_id(business_name)';

  @override
  Future<SellerInvitationModel> sendInvitation({
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

      // Check if already a member
      final existingMember = await _supabase
          .from(ApiEndpoints.sellerMembers)
          .select('id')
          .eq('seller_profile_id', sellerProfileId)
          .eq('is_active', true)
          .filter('member_email', 'eq', email)
          .maybeSingle();

      if (existingMember != null) {
        throw app_exceptions.ValidationException(
          message: 'Bu email allaqachon jamoa a\'zosi',
        );
      }

      // Check if pending invitation already exists
      final existingInvitation = await _supabase
          .from(ApiEndpoints.sellerInvitations)
          .select('id')
          .eq('seller_profile_id', sellerProfileId)
          .eq('email', email)
          .eq('status', 'pending')
          .maybeSingle();

      if (existingInvitation != null) {
        throw app_exceptions.ValidationException(
          message: 'Bu email ga allaqachon taklifnoma yuborilgan',
        );
      }

      // Generate token and set expiry
      final token = const Uuid().v4();
      final expiresAt =
          DateTime.now().add(const Duration(days: 7)).toIso8601String();

      final insertData = {
        'seller_profile_id': sellerProfileId,
        'email': email,
        'role': role.value,
        'invited_by': currentUser.id,
        'status': 'pending',
        'token': token,
        'expires_at': expiresAt,
      };

      final response = await _supabase
          .from(ApiEndpoints.sellerInvitations)
          .insert(insertData)
          .select(_selectWithJoins)
          .single();

      return SellerInvitationModel.fromJson(response);
    } on app_exceptions.AuthException {
      rethrow;
    } on app_exceptions.ValidationException {
      rethrow;
    } catch (e) {
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'Taklifnoma yuborishda xatolik',
      );
    }
  }

  @override
  Future<List<SellerInvitationModel>> getPendingInvitations(
      String sellerProfileId) async {
    try {
      final response = await _supabase
          .from(ApiEndpoints.sellerInvitations)
          .select(_selectWithJoins)
          .eq('seller_profile_id', sellerProfileId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SellerInvitationModel.fromJson(json))
          .where((inv) => !inv.isExpired) // Filter expired client-side
          .toList();
    } catch (e) {
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'Taklifnomalarni yuklashda xatolik',
      );
    }
  }

  @override
  Future<SellerInvitationModel> acceptInvitation(String invitationId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw app_exceptions.AuthException(
          message: 'Foydalanuvchi tizimga kirmagan',
        );
      }

      // Get invitation details
      final invitation = await _supabase
          .from(ApiEndpoints.sellerInvitations)
          .select(_selectWithJoins)
          .eq('id', invitationId)
          .single();

      final invitationModel = SellerInvitationModel.fromJson(invitation);

      // Check if expired
      if (invitationModel.isExpired) {
        throw app_exceptions.ValidationException(
          message: 'Taklifnoma muddati o\'tgan',
        );
      }

      // Update invitation status to accepted
      final updatedResponse = await _supabase
          .from(ApiEndpoints.sellerInvitations)
          .update({
            'status': 'accepted',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invitationId)
          .select(_selectWithJoins)
          .single();

      // Get current user profile for denormalized data
      final userProfile = await _supabase
          .from(ApiEndpoints.profiles)
          .select('full_name, email, avatar_url')
          .eq('id', currentUser.id)
          .single();

      // Create SellerMember record
      final now = DateTime.now().toIso8601String();
      await _supabase.from(ApiEndpoints.sellerMembers).insert({
        'seller_profile_id': invitationModel.sellerProfileId,
        'user_id': currentUser.id,
        'role': invitationModel.role.value,
        'invited_by': invitationModel.invitedBy,
        'invited_at': invitationModel.createdAt.toIso8601String(),
        'joined_at': now,
        'is_active': true,
        'member_name': userProfile['full_name'] as String? ?? 'Noma\'lum',
        'member_email': userProfile['email'] as String?,
        'member_avatar_url': userProfile['avatar_url'] as String?,
      });

      return SellerInvitationModel.fromJson(updatedResponse);
    } on app_exceptions.AuthException {
      rethrow;
    } on app_exceptions.ValidationException {
      rethrow;
    } catch (e) {
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'Taklifnomani qabul qilishda xatolik',
      );
    }
  }

  @override
  Future<SellerInvitationModel> rejectInvitation(String invitationId) async {
    try {
      final response = await _supabase
          .from(ApiEndpoints.sellerInvitations)
          .update({
            'status': 'rejected',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invitationId)
          .select(_selectWithJoins)
          .single();

      return SellerInvitationModel.fromJson(response);
    } catch (e) {
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'Taklifnomani rad etishda xatolik',
      );
    }
  }

  @override
  Future<void> cancelInvitation(String invitationId) async {
    try {
      await _supabase
          .from(ApiEndpoints.sellerInvitations)
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invitationId);
    } catch (e) {
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'Taklifnomani bekor qilishda xatolik',
      );
    }
  }

  @override
  Future<List<SellerInvitationModel>> getMyInvitations() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return [];

      // Get current user's email
      final email = currentUser.email;
      if (email == null || email.isEmpty) return [];

      final response = await _supabase
          .from(ApiEndpoints.sellerInvitations)
          .select(_selectWithJoins)
          .eq('email', email)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SellerInvitationModel.fromJson(json))
          .where((inv) => !inv.isExpired)
          .toList();
    } catch (e) {
      if (e is supabase.PostgrestException) ErrorHandler.throwFromPostgrest(e);
      throw app_exceptions.ServerException(
        message: 'Taklifnomalarni yuklashda xatolik',
      );
    }
  }
}
