import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/errors/error_handler.dart';
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
  Future<UserModel> verifyOtp({required String email, required String otp});
  Future<void> resendSignUpOtp({required String email});
  Future<void> sendForgotPasswordOtp({required String email});
  Future<void> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  });
  Future<void> resetPasswordWithNew({
    required String email,
    required String newPassword,
  });
  Future<UserModel> setUsername({required String username});
  Future<bool> checkUsernameAvailability({required String username});
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient _supabase;

  AuthRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  /// Build a [UserModel] that mirrors the activated `MockData` test
  /// profile. Call **after** `MockData.activateTestAccount(email)` so the
  /// returned User and the in-memory profile are in sync.
  UserModel _buildMockUserModel(String email) {
    final profile = MockData.currentUserProfile;
    return UserModel(
      id: profile.id,
      phone: profile.phone,
      email: profile.email ?? email,
      fullName: profile.fullName,
      avatarUrl: profile.avatarUrl,
      username: email.split('@').first,
      role: profile.role == 'seller' ? UserRole.seller : UserRole.buyer,
      isVerified: profile.isVerified,
      isActive: profile.isActive,
      language: profile.language,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

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
    } on supabase.AuthException catch (e) {
      AppLogger.error('Sign up failed', e);
      if (e.message.contains('already registered')) {
        throw const AuthException(
          message: 'Bu email allaqachon ro\'yxatdan o\'tgan',
        );
      }
      ErrorHandler.throwFromSupabaseAuth(e);
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error during sign up', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is ServerException || e is AuthException) rethrow;
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

      // Test mode — mock all emails (no Supabase required)
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating sign in for $email');
        await Future.delayed(const Duration(milliseconds: 500));

        // Predefined test credentials still validate password
        if (TestConfig.isTestEmail(email)) {
          final testPassword = TestConfig.getTestPassword(email);
          if (password != testPassword) {
            throw const AuthException(
              message: 'Noto\'g\'ri email yoki parol',
            );
          }
        }

        // Wire mock state (UserProfile + SellerProfile) to the email used.
        // Seller emails activate the storefront fixture; everything else
        // flows through the buyer profile.
        MockData.activateTestAccount(email);
        return _buildMockUserModel(email);
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException(message: 'Kirish amalga oshmadi');
      }

      // Fetch profile
      final userData = await _supabase
          .from(ApiEndpoints.profiles)
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (userData == null) {
        throw const NotFoundException(message: 'Profil topilmadi');
      }

      AppLogger.info('Sign in successful');
      return UserModel.fromJson(userData);
    } on supabase.AuthException catch (e) {
      AppLogger.error('Sign in failed', e);
      throw const AuthException(
        message: 'Noto\'g\'ri email yoki parol',
      );
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error during sign in', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException || e is NotFoundException) rethrow;
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
    } on supabase.AuthException catch (e) {
      AppLogger.error('Password reset failed', e);
      ErrorHandler.throwFromSupabaseAuth(e);
    } catch (e) {
      AppLogger.error('Unexpected error during password reset', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      AppLogger.info('Verifying OTP for $email');

      // Test mode
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Verifying OTP for $email');
        await Future.delayed(const Duration(milliseconds: 500));

        final testOtp = TestConfig.getTestOTP(email) ?? '123456';
        if (otp != testOtp) {
          throw const AuthException(
            message: 'Noto\'g\'ri tasdiqlash kodi',
          );
        }

        // Same activation path as `signIn` — keep the two flows in sync so a
        // user who registered with `seller@autogram.uz` lands in the
        // storefront just like a sign-in would.
        MockData.activateTestAccount(email);
        return _buildMockUserModel(email);
      }

      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: supabase.OtpType.signup,
      );

      if (response.user == null) {
        throw const AuthException(
          message: 'Tasdiqlash amalga oshmadi',
        );
      }

      // Fetch profile
      final userData = await _supabase
          .from(ApiEndpoints.profiles)
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (userData == null) {
        throw const NotFoundException(message: 'Profil topilmadi');
      }

      AppLogger.info('OTP verified successfully');
      return UserModel.fromJson(userData);
    } on supabase.AuthException catch (e) {
      AppLogger.error('OTP verification failed', e);
      throw const AuthException(
        message: 'Noto\'g\'ri tasdiqlash kodi',
      );
    } catch (e) {
      if (e is AuthException || e is NotFoundException) rethrow;
      AppLogger.error('Unexpected error during OTP verification', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resendSignUpOtp({required String email}) async {
    try {
      AppLogger.info('Resending sign-up OTP to $email');

      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Resending OTP for $email');
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }

      await _supabase.auth.resend(
        type: supabase.OtpType.signup,
        email: email,
      );

      AppLogger.info('Sign-up OTP resent');
    } on supabase.AuthException catch (e) {
      AppLogger.error('Resend OTP failed', e);
      ErrorHandler.throwFromSupabaseAuth(e);
    } catch (e) {
      AppLogger.error('Unexpected error resending OTP', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> sendForgotPasswordOtp({required String email}) async {
    try {
      AppLogger.info('Sending forgot password OTP to $email');

      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Sending forgot password OTP for $email');
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }

      await _supabase.auth.resetPasswordForEmail(email);

      AppLogger.info('Forgot password OTP sent');
    } on supabase.AuthException catch (e) {
      AppLogger.error('Send forgot password OTP failed', e);
      ErrorHandler.throwFromSupabaseAuth(e);
    } catch (e) {
      AppLogger.error('Unexpected error sending forgot password OTP', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) async {
    try {
      AppLogger.info('Verifying forgot password OTP for $email');

      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Verifying forgot password OTP for $email');
        await Future.delayed(const Duration(milliseconds: 500));

        final testOtp = TestConfig.getTestOTP(email) ?? '123456';
        if (otp != testOtp) {
          throw const AuthException(
            message: 'Noto\'g\'ri tasdiqlash kodi',
          );
        }
        return;
      }

      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: supabase.OtpType.recovery,
      );

      if (response.user == null) {
        throw const AuthException(
          message: 'Tasdiqlash amalga oshmadi',
        );
      }

      AppLogger.info('Forgot password OTP verified');
    } on supabase.AuthException catch (e) {
      AppLogger.error('Forgot password OTP verification failed', e);
      throw const AuthException(
        message: 'Noto\'g\'ri tasdiqlash kodi',
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('Unexpected error verifying forgot password OTP', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resetPasswordWithNew({
    required String email,
    required String newPassword,
  }) async {
    try {
      AppLogger.info('Resetting password for $email');

      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Resetting password for $email');
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }

      await _supabase.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );

      AppLogger.info('Password reset successful');
    } on supabase.AuthException catch (e) {
      AppLogger.error('Password reset failed', e);
      ErrorHandler.throwFromSupabaseAuth(e);
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

        // Mirror the canonical mock user so downstream profile lookups match.
        final mockUser = MockData.mockUsers.first;
        return UserModel.fromEntity(mockUser).copyWith(
          username: username,
          isVerified: true,
          updatedAt: DateTime.now(),
        );
      }

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const AuthException(message: 'Tizimga kirilmagan');
      }

      final response = await _supabase
          .from(ApiEndpoints.profiles)
          .update({'username': username})
          .eq('id', currentUser.id)
          .select()
          .single();

      AppLogger.info('Username set successfully');
      return UserModel.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error setting username', e);
      if (e.code == '23505') {
        throw const ValidationException(
          message: 'Bu username allaqachon band',
        );
      }
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
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
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error checking username', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      AppLogger.error('Error checking username availability', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // Test mode — repository falls back to local cache.
      if (TestConfig.isTestMode) {
        return null;
      }

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
  Future<void> logout() async {
    try {
      if (TestConfig.isTestMode) {
        AppLogger.info('TEST MODE: Simulating logout');
        // Reset mock state so the next sign-in starts from a clean buyer
        // profile (otherwise a seller → logout → sign-in-as-buyer would
        // still show seller storefront data).
        MockData.resetMutableState();
        return;
      }
      await _supabase.auth.signOut();
      AppLogger.info('User logged out');
    } on supabase.AuthException catch (e) {
      AppLogger.error('Error during logout', e);
      ErrorHandler.throwFromSupabaseAuth(e);
    } catch (e) {
      AppLogger.error('Error during logout', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    // Test mode — no Supabase listener, repository drives state via cache.
    if (TestConfig.isTestMode) {
      return const Stream<UserModel?>.empty();
    }
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
