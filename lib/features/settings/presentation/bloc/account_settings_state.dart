import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';

/// Step machine for the account-settings flows. Each "Requesting/OtpSent/
/// Changed" cluster belongs to one of email / password / phone, plus a single
/// terminal `error` we recover from on the next event.
enum AccountSettingsStatus {
  initial,
  emailChangeRequesting,
  emailChangeOtpSent,
  emailChangeVerifying,
  emailChanged,
  passwordChanging,
  passwordChanged,
  phoneChangeRequesting,
  phoneChangeOtpSent,
  phoneChangeVerifying,
  phoneChanged,
  error,
}

class AccountSettingsState extends Equatable {
  final AccountSettingsStatus status;

  /// Email captured from the first step so step 2 (OTP) doesn't need to
  /// re-collect it.
  final String? pendingEmail;
  final String? pendingPhone;
  final Failure? failure;

  const AccountSettingsState({
    this.status = AccountSettingsStatus.initial,
    this.pendingEmail,
    this.pendingPhone,
    this.failure,
  });

  bool get hasError => status == AccountSettingsStatus.error;

  AccountSettingsState copyWith({
    AccountSettingsStatus? status,
    String? pendingEmail,
    String? pendingPhone,
    Failure? failure,
    bool clearFailure = false,
    bool clearPendingEmail = false,
    bool clearPendingPhone = false,
  }) {
    return AccountSettingsState(
      status: status ?? this.status,
      pendingEmail:
          clearPendingEmail ? null : (pendingEmail ?? this.pendingEmail),
      pendingPhone:
          clearPendingPhone ? null : (pendingPhone ?? this.pendingPhone),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, pendingEmail, pendingPhone, failure];
}
