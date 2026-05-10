import 'package:equatable/equatable.dart';

abstract class AccountSettingsEvent extends Equatable {
  const AccountSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Reset the bloc back to [AccountSettingsStatus.initial] — used when leaving
/// or re-entering the flow so a stale success/error state doesn't leak across
/// screens.
class AccountSettingsReset extends AccountSettingsEvent {
  const AccountSettingsReset();
}

class AccountEmailChangeRequested extends AccountSettingsEvent {
  final String newEmail;
  final String currentPassword;

  const AccountEmailChangeRequested({
    required this.newEmail,
    required this.currentPassword,
  });

  @override
  List<Object?> get props => [newEmail, currentPassword];
}

class AccountEmailOtpVerified extends AccountSettingsEvent {
  final String otp;

  const AccountEmailOtpVerified({required this.otp});

  @override
  List<Object?> get props => [otp];
}

class AccountPasswordChangeRequested extends AccountSettingsEvent {
  final String currentPassword;
  final String newPassword;

  const AccountPasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class AccountPhoneChangeRequested extends AccountSettingsEvent {
  final String newPhone;
  final String currentPassword;

  const AccountPhoneChangeRequested({
    required this.newPhone,
    required this.currentPassword,
  });

  @override
  List<Object?> get props => [newPhone, currentPassword];
}

class AccountPhoneOtpVerified extends AccountSettingsEvent {
  final String otp;

  const AccountPhoneOtpVerified({required this.otp});

  @override
  List<Object?> get props => [otp];
}
