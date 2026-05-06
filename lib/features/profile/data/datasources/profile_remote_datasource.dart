import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/test_config.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();

  Future<UserProfileModel> updateProfile({
    String? fullName,
    String? email,
    String? language,
  });

  Future<String> updateAvatar(File imageFile);

  Future<void> deleteAccount();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final supabase.SupabaseClient _supabase;

  ProfileRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  UserProfileModel _modelFrom(UserProfile profile) => UserProfileModel(
        id: profile.id,
        phone: profile.phone,
        email: profile.email,
        fullName: profile.fullName,
        avatarUrl: profile.avatarUrl,
        role: profile.role,
        isVerified: profile.isVerified,
        isActive: profile.isActive,
        language: profile.language,
        sellerProfileId: profile.sellerProfileId,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
      );

  @override
  Future<UserProfileModel> getProfile() async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Returning mock profile');
      await Future.delayed(const Duration(milliseconds: 500));
      return _modelFrom(MockData.currentUserProfile);
    }

    // TODO(backend): wire to Supabase user_profiles table
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfileModel.fromJson(response);
  }

  @override
  Future<UserProfileModel> updateProfile({
    String? fullName,
    String? email,
    String? language,
  }) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Updating mock profile');
      await Future.delayed(const Duration(milliseconds: 500));
      MockData.currentUserProfile = MockData.currentUserProfile.copyWith(
        fullName: fullName,
        email: email,
        language: language,
        updatedAt: DateTime.now(),
      );
      return _modelFrom(MockData.currentUserProfile);
    }

    // TODO(backend): wire to Supabase user_profiles table
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (email != null) updates['email'] = email;
    if (language != null) updates['language'] = language;
    updates['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('user_profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();
    return UserProfileModel.fromJson(response);
  }

  @override
  Future<String> updateAvatar(File imageFile) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Mock avatar update');
      await Future.delayed(const Duration(milliseconds: 500));
      const avatarUrl = 'https://example.com/avatars/mock-avatar.jpg';
      MockData.currentUserProfile = MockData.currentUserProfile.copyWith(
        avatarUrl: avatarUrl,
        updatedAt: DateTime.now(),
      );
      return avatarUrl;
    }

    // TODO(backend): wire to Supabase Storage avatars bucket
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final fileName = 'avatar_$userId.${imageFile.path.split('.').last}';
    await _supabase.storage.from('avatars').upload(fileName, imageFile);
    final url = _supabase.storage.from('avatars').getPublicUrl(fileName);

    await _supabase
        .from('user_profiles')
        .update({'avatar_url': url})
        .eq('id', userId);
    return url;
  }

  @override
  Future<void> deleteAccount() async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Mock account delete');
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    // TODO(backend): wire to Supabase RPC delete_account + signOut
    await _supabase.rpc('delete_account');
    await _supabase.auth.signOut();
  }
}
