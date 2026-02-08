import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';

/// Remote data source for auth operations using Supabase

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phone);
  Future<UserModel?> verifyOtp({required String phone, required String code});
  Future<UserModel> register({
    required String phone,
    required String fullName,
    String? email,
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
  Future<void> sendOtp(String phone) async {
    try {
      AppLogger.info('Sending OTP to $phone');

      // Check if test mode and test phone
      if (TestConfig.isTestMode && TestConfig.isTestPhone(phone)) {
        AppLogger.info('TEST MODE: Bypassing OTP send for test phone');
        // In test mode, just return success without calling Supabase
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        AppLogger.info('TEST MODE: OTP "sent" successfully');
        return;
      }

      await _supabase.auth.signInWithOtp(
        phone: phone,
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
    required String phone,
    required String code,
  }) async {
    try {
      AppLogger.info('Verifying OTP for $phone');

      // Check if test mode and test phone
      if (TestConfig.isTestMode && TestConfig.isTestPhone(phone)) {
        AppLogger.info('TEST MODE: Verifying OTP for test phone');

        final expectedOtp = TestConfig.getTestOTP(phone);
        if (code != expectedOtp) {
          AppLogger.error('TEST MODE: Invalid OTP code');
          throw const AuthException(
            message: 'Noto\'g\'ri yoki muddati o\'tgan kod',
            code: 'invalid_otp',
          );
        }

        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 500));

        // Return mock user based on phone
        final mockUser = MockData.getUserByPhone(phone);
        if (mockUser == null) {
          AppLogger.info('TEST MODE: New user, needs registration');
          return null;
        }

        AppLogger.info('TEST MODE: User verified successfully');
        return UserModel.fromEntity(mockUser);
      }

      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: code,
        type: OtpType.sms,
      );

      if (response.user == null) {
        throw const AuthException(message: 'Verification failed');
      }

      // Check if user exists in our users table
      final userData = await _supabase
          .from(ApiEndpoints.users)
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (userData == null) {
        // New user, needs registration
        AppLogger.info('New user, needs registration');
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
  Future<UserModel> register({
    required String phone,
    required String fullName,
    String? email,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const AuthException(message: 'Not authenticated');
      }

      AppLogger.info('Registering user: $phone');

      final now = DateTime.now().toIso8601String();
      final userData = {
        'id': currentUser.id,
        'phone': phone,
        'full_name': fullName,
        'email': email,
        'role': 'buyer',
        'is_verified': false,
        'is_active': true,
        'language': 'uz',
        'created_at': now,
        'updated_at': now,
      };

      final response = await _supabase
          .from(ApiEndpoints.users)
          .insert(userData)
          .select()
          .single();

      AppLogger.info('User registered successfully');
      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Database error during registration', e);
      throw ServerException(message: e.message);
    } catch (e) {
      AppLogger.error('Unexpected error during registration', e);
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
          .from(ApiEndpoints.users)
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

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (email != null) updates['email'] = email;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (language != null) updates['language'] = language;

      final response = await _supabase
          .from(ApiEndpoints.users)
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
          .from(ApiEndpoints.users)
          .update({
            'role': 'seller',
            'updated_at': DateTime.now().toIso8601String(),
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
            .from(ApiEndpoints.users)
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
