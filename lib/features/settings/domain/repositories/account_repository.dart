import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

/// Account-credential management — separate from user profile editing. Owns
/// flows for changing email / phone / password on the underlying Supabase auth
/// row. Each "request" call sends an OTP and the corresponding "verify" call
/// finalises the change.
abstract class AccountRepository {
  /// Step 1 of email change: validates the current password and asks Supabase
  /// to send a verification link/OTP to [newEmail].
  Future<Either<Failure, void>> requestEmailChange({
    required String newEmail,
    required String currentPassword,
  });

  /// Step 2 of email change: confirms the OTP that was sent to [newEmail].
  /// On success, [auth.users.email] is updated.
  Future<Either<Failure, void>> verifyEmailChange({
    required String newEmail,
    required String otp,
  });

  /// Single-step password change. Verifies [currentPassword] before swapping
  /// in [newPassword]; the active session token rotates.
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Step 1 of phone change: validates the current password and asks Supabase
  /// to send an SMS OTP to [newPhone].
  Future<Either<Failure, void>> requestPhoneChange({
    required String newPhone,
    required String currentPassword,
  });

  /// Step 2 of phone change: confirms the SMS OTP. On success,
  /// [auth.users.phone] is updated.
  Future<Either<Failure, void>> verifyPhoneChange({
    required String newPhone,
    required String otp,
  });
}
