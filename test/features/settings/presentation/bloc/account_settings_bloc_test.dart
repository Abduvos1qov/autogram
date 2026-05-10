import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/settings/domain/usecases/change_email_usecase.dart';
import 'package:autogram/features/settings/domain/usecases/change_password_usecase.dart';
import 'package:autogram/features/settings/domain/usecases/change_phone_usecase.dart';
import 'package:autogram/features/settings/presentation/bloc/account_settings_bloc.dart';
import 'package:autogram/features/settings/presentation/bloc/account_settings_event.dart';
import 'package:autogram/features/settings/presentation/bloc/account_settings_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mock_usecases.dart';

void main() {
  late MockRequestEmailChangeUseCase requestEmailChange;
  late MockVerifyEmailChangeUseCase verifyEmailChange;
  late MockChangePasswordUseCase changePassword;
  late MockRequestPhoneChangeUseCase requestPhoneChange;
  late MockVerifyPhoneChangeUseCase verifyPhoneChange;

  setUpAll(() {
    registerFallbackValue(const RequestEmailChangeParams(
      newEmail: 'x@y.z',
      currentPassword: 'pwd',
    ));
    registerFallbackValue(const VerifyEmailChangeParams(
      newEmail: 'x@y.z',
      otp: '123456',
    ));
    registerFallbackValue(const ChangePasswordParams(
      currentPassword: 'old',
      newPassword: 'new',
    ));
    registerFallbackValue(const RequestPhoneChangeParams(
      newPhone: '+998901234567',
      currentPassword: 'pwd',
    ));
    registerFallbackValue(const VerifyPhoneChangeParams(
      newPhone: '+998901234567',
      otp: '123456',
    ));
  });

  setUp(() {
    requestEmailChange = MockRequestEmailChangeUseCase();
    verifyEmailChange = MockVerifyEmailChangeUseCase();
    changePassword = MockChangePasswordUseCase();
    requestPhoneChange = MockRequestPhoneChangeUseCase();
    verifyPhoneChange = MockVerifyPhoneChangeUseCase();
  });

  AccountSettingsBloc buildBloc() => AccountSettingsBloc(
        requestEmailChangeUseCase: requestEmailChange,
        verifyEmailChangeUseCase: verifyEmailChange,
        changePasswordUseCase: changePassword,
        requestPhoneChangeUseCase: requestPhoneChange,
        verifyPhoneChangeUseCase: verifyPhoneChange,
      );

  group('email change', () {
    blocTest<AccountSettingsBloc, AccountSettingsState>(
      'request → otpSent on success',
      build: () {
        when(() => requestEmailChange(any()))
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AccountEmailChangeRequested(
        newEmail: 'new@example.com',
        currentPassword: 'pwd',
      )),
      expect: () => [
        isA<AccountSettingsState>().having(
          (s) => s.status,
          'status',
          AccountSettingsStatus.emailChangeRequesting,
        ),
        isA<AccountSettingsState>()
            .having((s) => s.status, 'status',
                AccountSettingsStatus.emailChangeOtpSent)
            .having((s) => s.pendingEmail, 'pendingEmail', 'new@example.com'),
      ],
    );

    blocTest<AccountSettingsBloc, AccountSettingsState>(
      'verify → emailChanged clears pendingEmail',
      build: () {
        when(() => verifyEmailChange(any()))
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      seed: () => const AccountSettingsState(
        status: AccountSettingsStatus.emailChangeOtpSent,
        pendingEmail: 'new@example.com',
      ),
      act: (bloc) =>
          bloc.add(const AccountEmailOtpVerified(otp: '123456')),
      expect: () => [
        isA<AccountSettingsState>().having((s) => s.status, 'status',
            AccountSettingsStatus.emailChangeVerifying),
        isA<AccountSettingsState>()
            .having((s) => s.status, 'status',
                AccountSettingsStatus.emailChanged)
            .having((s) => s.pendingEmail, 'pendingEmail', isNull),
      ],
    );

    blocTest<AccountSettingsBloc, AccountSettingsState>(
      'failure surfaces as error state',
      build: () {
        when(() => requestEmailChange(any()))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'nope')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AccountEmailChangeRequested(
        newEmail: 'x@y.z',
        currentPassword: 'pwd',
      )),
      skip: 1, // skip the requesting state
      expect: () => [
        isA<AccountSettingsState>()
            .having((s) => s.status, 'status', AccountSettingsStatus.error)
            .having((s) => s.failure, 'failure', isA<ServerFailure>()),
      ],
    );
  });

  group('password change', () {
    blocTest<AccountSettingsBloc, AccountSettingsState>(
      'transitions changing → changed on success',
      build: () {
        when(() => changePassword(any()))
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AccountPasswordChangeRequested(
        currentPassword: 'old',
        newPassword: 'newSecurePass8',
      )),
      expect: () => [
        isA<AccountSettingsState>().having(
            (s) => s.status, 'status', AccountSettingsStatus.passwordChanging),
        isA<AccountSettingsState>().having(
            (s) => s.status, 'status', AccountSettingsStatus.passwordChanged),
      ],
    );
  });

  group('phone change', () {
    blocTest<AccountSettingsBloc, AccountSettingsState>(
      'request → otpSent on success',
      build: () {
        when(() => requestPhoneChange(any()))
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AccountPhoneChangeRequested(
        newPhone: '+998901234567',
        currentPassword: 'pwd',
      )),
      expect: () => [
        isA<AccountSettingsState>().having((s) => s.status, 'status',
            AccountSettingsStatus.phoneChangeRequesting),
        isA<AccountSettingsState>()
            .having((s) => s.status, 'status',
                AccountSettingsStatus.phoneChangeOtpSent)
            .having(
                (s) => s.pendingPhone, 'pendingPhone', '+998901234567'),
      ],
    );

    blocTest<AccountSettingsBloc, AccountSettingsState>(
      'verify with no pending phone is a no-op',
      build: () => buildBloc(),
      act: (bloc) =>
          bloc.add(const AccountPhoneOtpVerified(otp: '123456')),
      expect: () => const <AccountSettingsState>[],
    );
  });

  group('reset', () {
    blocTest<AccountSettingsBloc, AccountSettingsState>(
      'returns state to initial',
      build: () => buildBloc(),
      seed: () => const AccountSettingsState(
        status: AccountSettingsStatus.emailChanged,
      ),
      act: (bloc) => bloc.add(const AccountSettingsReset()),
      expect: () => [const AccountSettingsState()],
    );
  });
}
