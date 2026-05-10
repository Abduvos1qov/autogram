import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/change_email_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/change_phone_usecase.dart';
import 'account_settings_event.dart';
import 'account_settings_state.dart';

/// Drives the email / password / phone change flows. Each flow is a small
/// state machine — the screen reads [state.status] to decide which step to
/// render, and listens for terminal `*Changed` / `error` to navigate or show
/// snackbars.
class AccountSettingsBloc
    extends Bloc<AccountSettingsEvent, AccountSettingsState> {
  final RequestEmailChangeUseCase _requestEmailChangeUseCase;
  final VerifyEmailChangeUseCase _verifyEmailChangeUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final RequestPhoneChangeUseCase _requestPhoneChangeUseCase;
  final VerifyPhoneChangeUseCase _verifyPhoneChangeUseCase;

  AccountSettingsBloc({
    required RequestEmailChangeUseCase requestEmailChangeUseCase,
    required VerifyEmailChangeUseCase verifyEmailChangeUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required RequestPhoneChangeUseCase requestPhoneChangeUseCase,
    required VerifyPhoneChangeUseCase verifyPhoneChangeUseCase,
  })  : _requestEmailChangeUseCase = requestEmailChangeUseCase,
        _verifyEmailChangeUseCase = verifyEmailChangeUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _requestPhoneChangeUseCase = requestPhoneChangeUseCase,
        _verifyPhoneChangeUseCase = verifyPhoneChangeUseCase,
        super(const AccountSettingsState()) {
    on<AccountSettingsReset>(_onReset);
    on<AccountEmailChangeRequested>(_onEmailChangeRequested);
    on<AccountEmailOtpVerified>(_onEmailOtpVerified);
    on<AccountPasswordChangeRequested>(_onPasswordChangeRequested);
    on<AccountPhoneChangeRequested>(_onPhoneChangeRequested);
    on<AccountPhoneOtpVerified>(_onPhoneOtpVerified);
  }

  void _onReset(AccountSettingsReset event, Emitter<AccountSettingsState> emit) {
    emit(const AccountSettingsState());
  }

  Future<void> _onEmailChangeRequested(
    AccountEmailChangeRequested event,
    Emitter<AccountSettingsState> emit,
  ) async {
    AppLogger.info('Requesting email change');
    emit(state.copyWith(
      status: AccountSettingsStatus.emailChangeRequesting,
      pendingEmail: event.newEmail,
      clearFailure: true,
    ));

    final result = await _requestEmailChangeUseCase(
      RequestEmailChangeParams(
        newEmail: event.newEmail,
        currentPassword: event.currentPassword,
      ),
    );

    result.fold(
      (failure) => _emitFailure(emit, failure),
      (_) => emit(state.copyWith(status: AccountSettingsStatus.emailChangeOtpSent)),
    );
  }

  Future<void> _onEmailOtpVerified(
    AccountEmailOtpVerified event,
    Emitter<AccountSettingsState> emit,
  ) async {
    final pending = state.pendingEmail;
    if (pending == null) {
      AppLogger.warning('Email OTP verify dispatched without pending email');
      return;
    }
    emit(state.copyWith(
      status: AccountSettingsStatus.emailChangeVerifying,
      clearFailure: true,
    ));

    final result = await _verifyEmailChangeUseCase(
      VerifyEmailChangeParams(newEmail: pending, otp: event.otp),
    );

    result.fold(
      (failure) => _emitFailure(emit, failure),
      (_) => emit(state.copyWith(
        status: AccountSettingsStatus.emailChanged,
        clearPendingEmail: true,
      )),
    );
  }

  Future<void> _onPasswordChangeRequested(
    AccountPasswordChangeRequested event,
    Emitter<AccountSettingsState> emit,
  ) async {
    AppLogger.info('Changing password');
    emit(state.copyWith(
      status: AccountSettingsStatus.passwordChanging,
      clearFailure: true,
    ));

    final result = await _changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) => _emitFailure(emit, failure),
      (_) => emit(state.copyWith(status: AccountSettingsStatus.passwordChanged)),
    );
  }

  Future<void> _onPhoneChangeRequested(
    AccountPhoneChangeRequested event,
    Emitter<AccountSettingsState> emit,
  ) async {
    AppLogger.info('Requesting phone change');
    emit(state.copyWith(
      status: AccountSettingsStatus.phoneChangeRequesting,
      pendingPhone: event.newPhone,
      clearFailure: true,
    ));

    final result = await _requestPhoneChangeUseCase(
      RequestPhoneChangeParams(
        newPhone: event.newPhone,
        currentPassword: event.currentPassword,
      ),
    );

    result.fold(
      (failure) => _emitFailure(emit, failure),
      (_) => emit(state.copyWith(status: AccountSettingsStatus.phoneChangeOtpSent)),
    );
  }

  Future<void> _onPhoneOtpVerified(
    AccountPhoneOtpVerified event,
    Emitter<AccountSettingsState> emit,
  ) async {
    final pending = state.pendingPhone;
    if (pending == null) {
      AppLogger.warning('Phone OTP verify dispatched without pending phone');
      return;
    }
    emit(state.copyWith(
      status: AccountSettingsStatus.phoneChangeVerifying,
      clearFailure: true,
    ));

    final result = await _verifyPhoneChangeUseCase(
      VerifyPhoneChangeParams(newPhone: pending, otp: event.otp),
    );

    result.fold(
      (failure) => _emitFailure(emit, failure),
      (_) => emit(state.copyWith(
        status: AccountSettingsStatus.phoneChanged,
        clearPendingPhone: true,
      )),
    );
  }

  void _emitFailure(Emitter<AccountSettingsState> emit, Failure failure) {
    AppLogger.error('Account settings flow failed: ${failure.message}');
    emit(state.copyWith(
      status: AccountSettingsStatus.error,
      failure: failure,
    ));
  }
}
