import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/domain/entities/user.dart';
import 'package:autogram/features/auth/domain/usecases/check_username_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/resend_signup_otp_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/reset_password_with_new_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/send_forgot_password_otp_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/set_username_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/verify_forgot_password_otp_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:autogram/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:autogram/features/auth/presentation/bloc/auth_event.dart';
import 'package:autogram/features/auth/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/user_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockSignInUseCase mockSignIn;
  late MockSignUpUseCase mockSignUp;
  late MockResetPasswordUseCase mockResetPassword;
  late MockSetUsernameUseCase mockSetUsername;
  late MockCheckUsernameUseCase mockCheckUsername;
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockLogoutUseCase mockLogout;
  late MockVerifyOtpUseCase mockVerifyOtp;
  late MockVerifyForgotPasswordOtpUseCase mockVerifyForgotPasswordOtp;
  late MockResetPasswordWithNewUseCase mockResetPasswordWithNew;
  late MockResendSignUpOtpUseCase mockResendSignUpOtp;
  late MockSendForgotPasswordOtpUseCase mockSendForgotPasswordOtp;

  setUp(() {
    mockSignIn = MockSignInUseCase();
    mockSignUp = MockSignUpUseCase();
    mockResetPassword = MockResetPasswordUseCase();
    mockSetUsername = MockSetUsernameUseCase();
    mockCheckUsername = MockCheckUsernameUseCase();
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockLogout = MockLogoutUseCase();
    mockVerifyOtp = MockVerifyOtpUseCase();
    mockVerifyForgotPasswordOtp = MockVerifyForgotPasswordOtpUseCase();
    mockResetPasswordWithNew = MockResetPasswordWithNewUseCase();
    mockResendSignUpOtp = MockResendSignUpOtpUseCase();
    mockSendForgotPasswordOtp = MockSendForgotPasswordOtpUseCase();

    authBloc = AuthBloc(
      signInUseCase: mockSignIn,
      signUpUseCase: mockSignUp,
      resetPasswordUseCase: mockResetPassword,
      setUsernameUseCase: mockSetUsername,
      checkUsernameUseCase: mockCheckUsername,
      getCurrentUserUseCase: mockGetCurrentUser,
      logoutUseCase: mockLogout,
      verifyOtpUseCase: mockVerifyOtp,
      verifyForgotPasswordOtpUseCase: mockVerifyForgotPasswordOtp,
      resetPasswordWithNewUseCase: mockResetPasswordWithNew,
      resendSignUpOtpUseCase: mockResendSignUpOtp,
      sendForgotPasswordOtpUseCase: mockSendForgotPasswordOtp,
    );
  });

  setUpAll(() {
    registerFallbackValue(const SignInParams(email: '', password: ''));
    registerFallbackValue(const SignUpParams(
        email: '', password: '', fullName: ''));
    registerFallbackValue(const ResetPasswordParams(email: ''));
    registerFallbackValue(const SetUsernameParams(username: ''));
    registerFallbackValue(const CheckUsernameParams(username: ''));
    registerFallbackValue(const VerifyOtpParams(email: '', otp: ''));
    registerFallbackValue(
        const VerifyForgotPasswordOtpParams(email: '', otp: ''));
    registerFallbackValue(
        const ResetPasswordWithNewParams(email: '', newPassword: ''));
    registerFallbackValue(const ResendSignUpOtpParams(email: ''));
    registerFallbackValue(const SendForgotPasswordOtpParams(email: ''));
  });

  tearDown(() {
    authBloc.close();
  });

  final tUser = UserFixtures.buyer.copyWith(username: 'testuser');
  final tUserNoUsername = User(
    id: 'user-123',
    fullName: 'Test User',
    role: UserRole.buyer,
    isVerified: true,
    isActive: true,
    language: 'uz',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  test('initial state is AuthInitial', () {
    expect(authBloc.state, const AuthInitial());
  });

  // ── AuthCheckRequested ──────────────────────────────────────────

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when user has username',
      build: () {
        when(() => mockGetCurrentUser()).thenAnswer(
          (_) async => Right(tUser),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthNeedsUsername] when user has no username',
      build: () {
        when(() => mockGetCurrentUser()).thenAnswer(
          (_) async => Right(tUserNoUsername),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        AuthNeedsUsername(tUserNoUsername),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when user is null',
      build: () {
        when(() => mockGetCurrentUser()).thenAnswer(
          (_) async => const Right(null),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on failure',
      build: () {
        when(() => mockGetCurrentUser()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'error')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });

  // ── AuthSignInRequested ─────────────────────────────────────────

  group('AuthSignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when sign in succeeds with username',
      build: () {
        when(() => mockSignIn(any())).thenAnswer(
          (_) async => Right(tUser),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'test@test.com',
        password: 'pass',
      )),
      expect: () => [
        isA<AuthLoading>(),
        AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthNeedsUsername] when user has no username',
      build: () {
        when(() => mockSignIn(any())).thenAnswer(
          (_) async => Right(tUserNoUsername),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'test@test.com',
        password: 'pass',
      )),
      expect: () => [
        isA<AuthLoading>(),
        AuthNeedsUsername(tUserNoUsername),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockSignIn(any())).thenAnswer(
          (_) async => const Left(AuthFailure(message: 'Invalid')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'test@test.com',
        password: 'pass',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // ── AuthSignUpRequested ─────────────────────────────────────────

  group('AuthSignUpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSignUpSuccess] on success',
      build: () {
        when(() => mockSignUp(any())).thenAnswer(
          (_) async => const Right(null),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignUpRequested(
        email: 'test@test.com',
        password: 'pass',
        fullName: 'Test',
      )),
      expect: () => [
        isA<AuthLoading>(),
        const AuthSignUpSuccess('test@test.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockSignUp(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'exists')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignUpRequested(
        email: 'test@test.com',
        password: 'pass',
        fullName: 'Test',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // ── AuthVerifyOtpRequested ──────────────────────────────────────

  group('AuthVerifyOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthNeedsUsername] on success',
      build: () {
        when(() => mockVerifyOtp(any())).thenAnswer(
          (_) async => Right(tUserNoUsername),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthVerifyOtpRequested(
        email: 'test@test.com',
        otp: '123456',
      )),
      expect: () => [
        isA<AuthLoading>(),
        AuthNeedsUsername(tUserNoUsername),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockVerifyOtp(any())).thenAnswer(
          (_) async => const Left(AuthFailure(message: 'Invalid')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthVerifyOtpRequested(
        email: 'test@test.com',
        otp: '000000',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // ── AuthResendOtpRequested ──────────────────────────────────────

  group('AuthResendOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthSignUpSuccess] on success',
      build: () {
        when(() => mockResendSignUpOtp(any()))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthResendOtpRequested('test@test.com')),
      expect: () => [
        const AuthSignUpSuccess('test@test.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthError] on failure',
      build: () {
        when(() => mockResendSignUpOtp(any()))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'error')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthResendOtpRequested('test@test.com')),
      expect: () => [
        isA<AuthError>(),
      ],
    );
  });

  // ── AuthForgotPasswordOtpRequested ──────────────────────────────

  group('AuthForgotPasswordOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthForgotPasswordOtpSent] on success',
      build: () {
        when(() => mockSendForgotPasswordOtp(any()))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const AuthForgotPasswordOtpRequested('test@test.com')),
      expect: () => [
        isA<AuthLoading>(),
        const AuthForgotPasswordOtpSent('test@test.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockSendForgotPasswordOtp(any()))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'error')));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const AuthForgotPasswordOtpRequested('test@test.com')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // ── AuthVerifyForgotPasswordOtpRequested ────────────────────────

  group('AuthVerifyForgotPasswordOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthForgotPasswordOtpVerified] on success',
      build: () {
        when(() => mockVerifyForgotPasswordOtp(any())).thenAnswer(
          (_) async => const Right(null),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthVerifyForgotPasswordOtpRequested(
        email: 'test@test.com',
        otp: '123456',
      )),
      expect: () => [
        isA<AuthLoading>(),
        const AuthForgotPasswordOtpVerified('test@test.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockVerifyForgotPasswordOtp(any())).thenAnswer(
          (_) async => const Left(AuthFailure(message: 'Invalid')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthVerifyForgotPasswordOtpRequested(
        email: 'test@test.com',
        otp: '000000',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // ── AuthResetPasswordWithNewPassword ────────────────────────────

  group('AuthResetPasswordWithNewPassword', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSuccess] on success',
      build: () {
        when(() => mockResetPasswordWithNew(any())).thenAnswer(
          (_) async => const Right(null),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthResetPasswordWithNewPassword(
        email: 'test@test.com',
        newPassword: 'NewPass1!',
      )),
      expect: () => [
        isA<AuthLoading>(),
        const AuthPasswordResetSuccess(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockResetPasswordWithNew(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'error')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthResetPasswordWithNewPassword(
        email: 'test@test.com',
        newPassword: 'NewPass1!',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // ── AuthResetPasswordRequested ──────────────────────────────────

  group('AuthResetPasswordRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSent] on success',
      build: () {
        when(() => mockResetPassword(any())).thenAnswer(
          (_) async => const Right(null),
        );
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const AuthResetPasswordRequested('test@test.com')),
      expect: () => [
        isA<AuthLoading>(),
        const AuthPasswordResetSent('test@test.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockResetPassword(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'not found')),
        );
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const AuthResetPasswordRequested('test@test.com')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // ── AuthUsernameSubmitted ───────────────────────────────────────

  group('AuthUsernameSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when available and set succeeds',
      build: () {
        when(() => mockCheckUsername(any())).thenAnswer(
          (_) async => const Right(true),
        );
        when(() => mockSetUsername(any())).thenAnswer(
          (_) async => Right(tUser),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthUsernameSubmitted('testuser')),
      expect: () => [
        isA<AuthLoading>(),
        AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when username is not available',
      build: () {
        when(() => mockCheckUsername(any())).thenAnswer(
          (_) async => const Right(false),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthUsernameSubmitted('taken')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when check fails',
      build: () {
        when(() => mockCheckUsername(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'error')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthUsernameSubmitted('testuser')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when set username fails',
      build: () {
        when(() => mockCheckUsername(any())).thenAnswer(
          (_) async => const Right(true),
        );
        when(() => mockSetUsername(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'error')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthUsernameSubmitted('testuser')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // ── AuthLogoutRequested ─────────────────────────────────────────

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on success',
      build: () {
        when(() => mockLogout()).thenAnswer(
          (_) async => const Right(null),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockLogout()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'error')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });
}
