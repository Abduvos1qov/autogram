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
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    DateTime? dateOfBirth,
  });
  Future<UserModel> signIn({required String email, required String password});
  Future<void> resetPassword({required String email});
  Future<UserModel> setUsername({required String username});
  Future<bool> checkUsernameAvailability({required String username});
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
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    DateTime? dateOfBirth,
  }) async {
    try {
      AppLogger.info('Signing up user: $email');

      // Test mode
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating sign up for $email');
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          if (phone != null) 'phone': phone,
          if (dateOfBirth != null)
            'date_of_birth': dateOfBirth.toIso8601String(),
        },
      );

      if (response.user == null) {
        throw const ServerException(
            message: 'Ro\'yxatdan o\'tish amalga oshmadi');
      }

      // Insert profile data
      await _supabase.from(ApiEndpoints.profiles).upsert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (dateOfBirth != null)
          'date_of_birth': dateOfBirth.toIso8601String(),
      });

      AppLogger.info('Sign up successful');
    } on AuthException catch (e) {
      AppLogger.error('Sign up failed', e);
      if (e.message.contains('already registered')) {
        throw const ServerException(
          message: 'Bu email allaqachon ro\'yxatdan o\'tgan',
        );
      }
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is ServerException) rethrow;
      AppLogger.error('Unexpected error during sign up', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Signing in user: $email');

      // Test mode
      if (TestConfig.isTestMode && TestConfig.isTestEmail(email)) {
        AppLogger.info('TEST MODE: Simulating sign in for $email');
        await Future.delayed(const Duration(milliseconds: 500));

        final testPassword = TestConfig.getTestPassword(email);
        if (password != testPassword) {
          throw const ServerException(
            message: 'Noto\'g\'ri email yoki parol',
          );
        }

        final mockUser = MockData.getUserByEmail(email);
        if (mockUser == null) {
          throw const ServerException(message: 'Foydalanuvchi topilmadi');
        }

        return UserModel.fromEntity(mockUser);
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerException(message: 'Kirish amalga oshmadi');
      }

      // Fetch profile
      final userData = await _supabase
          .from(ApiEndpoints.profiles)
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (userData == null) {
        throw const ServerException(message: 'Profil topilmadi');
      }

      AppLogger.info('Sign in successful');
      return UserModel.fromJson(userData);
    } on AuthException catch (e) {
      AppLogger.error('Sign in failed', e);
      throw const ServerException(
        message: 'Noto\'g\'ri email yoki parol',
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      AppLogger.error('Unexpected error during sign in', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      AppLogger.info('Sending password reset to $email');

      // Test mode
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating password reset for $email');
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }

      await _supabase.auth.resetPasswordForEmail(email);

      AppLogger.info('Password reset email sent');
    } on AuthException catch (e) {
      AppLogger.error('Password reset failed', e);
      throw ServerException(message: e.message);
    } catch (e) {
      AppLogger.error('Unexpected error during password reset', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> setUsername({required String username}) async {
    try {
      AppLogger.info('Setting username: $username');

      // Test mode
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Setting username to $username');
        await Future.delayed(const Duration(milliseconds: 500));

        final now = DateTime.now();
        return UserModel(
          id: 'test_user_id',
          email: 'test@autogram.uz',
          fullName: 'Test User',
          username: username,
          role: UserRole.buyer,
          isVerified: true,
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

      final response = await _supabase
          .from(ApiEndpoints.profiles)
          .update({'username': username})
          .eq('id', currentUser.id)
          .select()
          .single();

      AppLogger.info('Username set successfully');
      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Database error setting username', e);
      if (e.message.contains('unique') || e.message.contains('duplicate')) {
        throw const ServerException(
          message: 'Bu username allaqachon band',
        );
      }
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is ServerException) rethrow;
      AppLogger.error('Unexpected error setting username', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> checkUsernameAvailability({required String username}) async {
    try {
      AppLogger.info('Checking username availability: $username');

      // Test mode
      if (TestConfig.isTestMode) {
        await Future.delayed(const Duration(milliseconds: 300));
        return MockData.isUsernameAvailable(username);
      }

      final result = await _supabase
          .from(ApiEndpoints.profiles)
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return result == null;
    } catch (e) {
      AppLogger.error('Error checking username availability', e);
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
