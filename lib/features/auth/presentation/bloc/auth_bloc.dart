import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/check_username_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/reset_password_with_new_usecase.dart';
import '../../domain/usecases/set_username_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/verify_forgot_password_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BLoC - manages authentication state

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final SetUsernameUseCase _setUsernameUseCase;
  final CheckUsernameUseCase _checkUsernameUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final VerifyForgotPasswordOtpUseCase _verifyForgotPasswordOtpUseCase;
  final ResetPasswordWithNewUseCase _resetPasswordWithNewUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required SetUsernameUseCase setUsernameUseCase,
    required CheckUsernameUseCase checkUsernameUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required VerifyForgotPasswordOtpUseCase verifyForgotPasswordOtpUseCase,
    required ResetPasswordWithNewUseCase resetPasswordWithNewUseCase,
    required AuthRepository authRepository,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _setUsernameUseCase = setUsernameUseCase,
        _checkUsernameUseCase = checkUsernameUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _verifyForgotPasswordOtpUseCase = verifyForgotPasswordOtpUseCase,
        _resetPasswordWithNewUseCase = resetPasswordWithNewUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthUsernameSubmitted>(_onUsernameSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthResendOtpRequested>(_onResendOtpRequested);
    on<AuthForgotPasswordOtpRequested>(_onForgotPasswordOtpRequested);
    on<AuthVerifyForgotPasswordOtpRequested>(
        _onVerifyForgotPasswordOtpRequested);
    on<AuthResetPasswordWithNewPassword>(_onResetPasswordWithNewPassword);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Checking authentication status');
    emit(const AuthLoading());

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) {
        AppLogger.warning('Auth check failed: ${failure.message}');
        emit(const AuthUnauthenticated());
      },
      (user) {
        if (user != null) {
          AppLogger.info('User is authenticated: ${user.email}');
          if (!user.hasUsername) {
            emit(AuthNeedsUsername(user));
          } else {
            emit(AuthAuthenticated(user));
          }
        } else {
          AppLogger.info('User is not authenticated');
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Signing in: ${event.email}');
    emit(const AuthLoading(message: 'Kirilmoqda...'));

    final result = await _signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) {
        AppLogger.error('Sign in failed: ${failure.message}');
        emit(AuthError(failure: failure));
      },
      (user) {
        AppLogger.info('Sign in successful');
        if (!user.hasUsername) {
          emit(AuthNeedsUsername(user));
        } else {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Signing up: ${event.email}');
    emit(const AuthLoading(message: 'Ro\'yxatdan o\'tilmoqda...'));

    final result = await _signUpUseCase(
      SignUpParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phone: event.phone,
        dateOfBirth: event.dateOfBirth,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error('Sign up failed: ${failure.message}');
        emit(AuthError(failure: failure));
      },
      (_) {
        AppLogger.info('Sign up successful, OTP verification needed');
        emit(AuthSignUpSuccess(event.email));
      },
    );
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Verifying OTP for: ${event.email}');
    emit(const AuthLoading(message: 'Tekshirilmoqda...'));

    final result = await _verifyOtpUseCase(
      VerifyOtpParams(email: event.email, otp: event.otp),
    );

    result.fold(
      (failure) {
        AppLogger.error('OTP verification failed: ${failure.message}');
        emit(AuthError(failure: failure));
      },
      (user) {
        AppLogger.info('OTP verified, proceeding to username');
        emit(AuthNeedsUsername(user));
      },
    );
  }

  Future<void> _onResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Resending OTP to: ${event.email}');

    final result = await _authRepository.resendSignUpOtp(email: event.email);

    result.fold(
      (failure) {
        AppLogger.error('Resend OTP failed: ${failure.message}');
        emit(AuthError(failure: failure));
      },
      (_) {
        AppLogger.info('OTP resent successfully');
        emit(AuthSignUpSuccess(event.email));
      },
    );
  }

  Future<void> _onForgotPasswordOtpRequested(
    AuthForgotPasswordOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Sending forgot password OTP to: ${event.email}');
    emit(const AuthLoading(message: 'Yuborilmoqda...'));

    final result =
        await _authRepository.sendForgotPasswordOtp(email: event.email);

    result.fold(
      (failure) {
        AppLogger.error('Send forgot password OTP failed: ${failure.message}');
        emit(AuthError(failure: failure));
      },
      (_) {
        AppLogger.info('Forgot password OTP sent');
        emit(AuthForgotPasswordOtpSent(event.email));
      },
    );
  }

  Future<void> _onVerifyForgotPasswordOtpRequested(
    AuthVerifyForgotPasswordOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Verifying forgot password OTP for: ${event.email}');
    emit(const AuthLoading(message: 'Tekshirilmoqda...'));

    final result = await _verifyForgotPasswordOtpUseCase(
      VerifyForgotPasswordOtpParams(email: event.email, otp: event.otp),
    );

    result.fold(
      (failure) {
        AppLogger.error(
            'Forgot password OTP verification failed: ${failure.message}');
        emit(AuthError(failure: failure));
      },
      (_) {
        AppLogger.info('Forgot password OTP verified');
        emit(AuthForgotPasswordOtpVerified(event.email));
      },
    );
  }

  Future<void> _onResetPasswordWithNewPassword(
    AuthResetPasswordWithNewPassword event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Setting new password for: ${event.email}');
    emit(const AuthLoading(message: 'Saqlanmoqda...'));

    final result = await _resetPasswordWithNewUseCase(
      ResetPasswordWithNewParams(
        email: event.email,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error('Password reset failed: ${failure.message}');
        emit(AuthError(failure: failure));
      },
      (_) {
        AppLogger.info('Password reset successful');
        emit(const AuthPasswordResetSuccess());
      },
    );
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Resetting password for: ${event.email}');
    emit(const AuthLoading(message: 'Yuborilmoqda...'));

    final result = await _resetPasswordUseCase(
      ResetPasswordParams(email: event.email),
    );

    result.fold(
      (failure) {
        AppLogger.error('Password reset failed: ${failure.message}');
        emit(AuthError(failure: failure));
      },
      (_) {
        AppLogger.info('Password reset email sent');
        emit(AuthPasswordResetSent(event.email));
      },
    );
  }

  Future<void> _onUsernameSubmitted(
    AuthUsernameSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Setting username: ${event.username}');
    emit(const AuthLoading(message: 'Saqlanmoqda...'));

    // First check availability
    final checkResult = await _checkUsernameUseCase(
      CheckUsernameParams(username: event.username),
    );

    final isAvailable = checkResult.fold(
      (failure) => false,
      (available) => available,
    );

    if (!isAvailable) {
      AppLogger.warning('Username not available: ${event.username}');
      emit(const AuthError(
        failure: ServerFailure(
          message: 'Bu username allaqachon band',
        ),
      ));
      return;
    }

    final result = await _setUsernameUseCase(
      SetUsernameParams(username: event.username),
    );

    result.fold(
      (failure) {
        AppLogger.error('Setting username failed: ${failure.message}');
        emit(AuthError(failure: failure));
      },
      (user) {
        AppLogger.info('Username set successfully');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Logging out');
    emit(const AuthLoading(message: 'Chiqilmoqda...'));

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        AppLogger.error('Logout failed: ${failure.message}');
        emit(AuthError(failure: failure));
      },
      (_) {
        AppLogger.info('Logged out successfully');
        emit(const AuthUnauthenticated());
      },
    );
  }
}
