import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

/// Remote data source for auth operations using Supabase

abstract class AuthRemoteDataSource {
  Future<void> sendOtp({required String email});
  Future<UserModel?> verifyOtp({required String email, required String code});
  Future<UserModel> completeProfile({
    required String fullName,
    String? phone,
  });
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? avatarUrl,
    String? language,
  });
  Future<UserModel> upgradeToSeller();
  Future<void> logout();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSourceImpl({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<void> sendOtp({required String email}) async {
    try {
      AppLogger.info('Sending OTP to $email');

      // Check if test mode and test email
      if (TestConfig.isTestMode && TestConfig.isTestEmail(email)) {
        AppLogger.info('TEST MODE: Bypassing OTP send for test email');
        await Future.delayed(const Duration(milliseconds: 500));
        AppLogger.info('TEST MODE: OTP "sent" successfully');
        return;
      }

      await _supabase.auth.signInWithOtp(
        email: email,
      );

      AppLogger.info('OTP sent successfully');
    } on AuthException catch (e) {
      AppLogger.error('Failed to send OTP', e);
      throw ServerException(message: e.message);
    } catch (e) {
      AppLogger.error('Unexpected error sending OTP', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      AppLogger.info('Verifying OTP for $email');

      // Check if test mode and test email
      if (TestConfig.isTestMode && TestConfig.isTestEmail(email)) {
        AppLogger.info('TEST MODE: Verifying OTP for test email');

        final expectedOtp = TestConfig.getTestOTP(email);
        if (code != expectedOtp) {
          AppLogger.error('TEST MODE: Invalid OTP code');
          throw const AuthException(
            message: 'Noto\'g\'ri yoki muddati o\'tgan kod',
            code: 'invalid_otp',
          );
        }

        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 500));

        // Return mock user based on email
        final mockUser = MockData.getUserByEmail(email);
        if (mockUser == null) {
          AppLogger.info('TEST MODE: New user, needs registration');
          return null;
        }

        AppLogger.info('TEST MODE: User verified successfully');
        return UserModel.fromEntity(mockUser);
      }

      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.email,
      );

      if (response.user == null) {
        throw const AuthException(message: 'Verification failed');
      }

      // Check if user exists in our profiles table
      final userData = await _supabase
          .from(ApiEndpoints.profiles)
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (userData == null) {
        // New user, needs registration
        AppLogger.info('New user, needs registration');
        return null;
      }

      // Check if profile is complete (has full_name)
      final fullName = userData['full_name'] as String? ?? '';
      if (fullName.isEmpty) {
        AppLogger.info('User profile incomplete, needs registration');
        return null;
      }

      AppLogger.info('User verified successfully');
      return UserModel.fromJson(userData);
    } on AuthException catch (e) {
      AppLogger.error('Failed to verify OTP', e);
      if (e.message.contains('Invalid') || e.message.contains('expired')) {
        throw const AuthException(
          message: 'Noto\'g\'ri yoki muddati o\'tgan kod',
          code: 'invalid_otp',
        );
      }
      throw ServerException(message: e.message);
    } catch (e) {
      AppLogger.error('Unexpected error verifying OTP', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> completeProfile({
    required String fullName,
    String? phone,
  }) async {
    try {
      // Test mode: return mock user with updated name
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Completing profile for $fullName');
        await Future.delayed(const Duration(milliseconds: 500));

        final now = DateTime.now();
        return UserModel(
          id: 'new_user_${now.millisecondsSinceEpoch}',
          email: null,
          phone: phone,
          fullName: fullName,
          role: UserRole.buyer,
          isVerified: false,
          isActive: true,
          language: 'uz',
          createdAt: now,
          updatedAt: now,
        );
      }

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const AuthException(message: 'Not authenticated');
      }

      AppLogger.info('Completing profile for ${currentUser.email}');

      final updates = <String, dynamic>{
        'full_name': fullName,
      };
      if (phone != null && phone.isNotEmpty) {
        updates['phone'] = phone;
      }

      final response = await _supabase
          .from(ApiEndpoints.profiles)
          .update(updates)
          .eq('id', currentUser.id)
          .select()
          .single();

      AppLogger.info('Profile completed successfully');
      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Database error during profile completion', e);
      throw ServerException(message: e.message);
    } catch (e) {
      AppLogger.error('Unexpected error during profile completion', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      final userData = await _supabase
          .from(ApiEndpoints.profiles)
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      if (userData == null) {
        return null;
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      AppLogger.error('Error getting current user', e);
      return null;
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? avatarUrl,
    String? language,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const AuthException(message: 'Not authenticated');
      }

      final updates = <String, dynamic>{};

      if (fullName != null) updates['full_name'] = fullName;
      if (email != null) updates['email'] = email;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (language != null) updates['language'] = language;

      final response = await _supabase
          .from(ApiEndpoints.profiles)
          .update(updates)
          .eq('id', currentUser.id)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error updating profile', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> upgradeToSeller() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const AuthException(message: 'Not authenticated');
      }

      final response = await _supabase
          .from(ApiEndpoints.profiles)
          .update({
            'role': 'seller',
          })
          .eq('id', currentUser.id)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error upgrading to seller', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      AppLogger.info('User logged out');
    } catch (e) {
      AppLogger.error('Error during logout', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((event) async {
      if (event.session?.user == null) {
        return null;
      }

      try {
        final userData = await _supabase
            .from(ApiEndpoints.profiles)
            .select()
            .eq('id', event.session!.user.id)
            .maybeSingle();

        if (userData == null) {
          return null;
        }

        return UserModel.fromJson(userData);
      } catch (e) {
        return null;
      }
    });
  }
}
