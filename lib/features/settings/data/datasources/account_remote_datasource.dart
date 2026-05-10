import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/test_config.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Thin wrapper around Supabase's auth API for credential management. Each
/// method is paired with a test-mode short-circuit that simulates 500ms of
/// latency and treats `123456` as a valid OTP — same convention as the rest
/// of the auth feature.
abstract class AccountRemoteDataSource {
  Future<void> requestEmailChange({
    required String newEmail,
    required String currentPassword,
  });

  Future<void> verifyEmailChange({
    required String newEmail,
    required String otp,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> requestPhoneChange({
    required String newPhone,
    required String currentPassword,
  });

  Future<void> verifyPhoneChange({
    required String newPhone,
    required String otp,
  });
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final supabase.SupabaseClient _supabase;

  AccountRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  /// Re-authenticates the active session with the user's current credentials —
  /// this is how we verify the password before any sensitive change. Supabase
  /// has no `verifyPassword` endpoint, so calling `signInWithPassword` while
  /// already authenticated rotates the token but keeps the session intact;
  /// failure throws `AuthApiException` which is caught and surfaced as
  /// [AuthException].
  Future<void> _verifyCurrentPassword(String currentPassword) async {
    final email = _supabase.auth.currentUser?.email;
    if (email == null) {
      throw const AuthException(
        message: 'Cannot verify password without an email on the session',
      );
    }
    await _supabase.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );
  }

  @override
  Future<void> requestEmailChange({
    required String newEmail,
    required String currentPassword,
  }) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Requesting email change → $newEmail');
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    try {
      await _verifyCurrentPassword(currentPassword);
      await _supabase.auth.updateUser(
        supabase.UserAttributes(email: newEmail),
      );
      AppLogger.info('Email change requested for $newEmail');
    } on supabase.AuthException catch (e) {
      AppLogger.error('Email change request failed', e);
      ErrorHandler.throwFromSupabaseAuth(e);
    } catch (e) {
      AppLogger.error('Unexpected error during email change request', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> verifyEmailChange({
    required String newEmail,
    required String otp,
  }) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Verifying email change OTP');
      await Future.delayed(const Duration(milliseconds: 500));
      if (otp != '123456') {
        throw const AuthException(message: 'Invalid OTP');
      }
      return;
    }

    try {
      await _supabase.auth.verifyOTP(
        email: newEmail,
        token: otp,
        type: supabase.OtpType.emailChange,
      );
      AppLogger.info('Email change verified');
    } on supabase.AuthException catch (e) {
      AppLogger.error('Email change verification failed', e);
      ErrorHandler.throwFromSupabaseAuth(e);
    } catch (e) {
      AppLogger.error('Unexpected error during email change verification', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Changing password');
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    try {
      await _verifyCurrentPassword(currentPassword);
      await _supabase.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
      AppLogger.info('Password changed');
    } on supabase.AuthException catch (e) {
      AppLogger.error('Password change failed', e);
      ErrorHandler.throwFromSupabaseAuth(e);
    } catch (e) {
      AppLogger.error('Unexpected error during password change', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> requestPhoneChange({
    required String newPhone,
    required String currentPassword,
  }) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Requesting phone change → $newPhone');
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    try {
      await _verifyCurrentPassword(currentPassword);
      await _supabase.auth.updateUser(
        supabase.UserAttributes(phone: newPhone),
      );
      AppLogger.info('Phone change requested for $newPhone');
    } on supabase.AuthException catch (e) {
      AppLogger.error('Phone change request failed', e);
      ErrorHandler.throwFromSupabaseAuth(e);
    } catch (e) {
      AppLogger.error('Unexpected error during phone change request', e);
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> verifyPhoneChange({
    required String newPhone,
    required String otp,
  }) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Verifying phone change OTP');
      await Future.delayed(const Duration(milliseconds: 500));
      if (otp != '123456') {
        throw const AuthException(message: 'Invalid OTP');
      }
      return;
    }

    try {
      await _supabase.auth.verifyOTP(
        phone: newPhone,
        token: otp,
        type: supabase.OtpType.phoneChange,
      );
      AppLogger.info('Phone change verified');
    } on supabase.AuthException catch (e) {
      AppLogger.error('Phone change verification failed', e);
      ErrorHandler.throwFromSupabaseAuth(e);
    } catch (e) {
      AppLogger.error('Unexpected error during phone change verification', e);
      throw ServerException(message: e.toString());
    }
  }
}
