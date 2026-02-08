import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BLoC - manages authentication state

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final RegisterUseCase _registerUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthBloc({
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required RegisterUseCase registerUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _sendOtpUseCase = sendOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _registerUseCase = registerUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpVerified>(_onOtpVerified);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthOtpResendRequested>(_onOtpResendRequested);
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
          AppLogger.info('User is authenticated: ${user.phone}');
          emit(AuthAuthenticated(user));
        } else {
          AppLogger.info('User is not authenticated');
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onOtpRequested(
    AuthOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Sending OTP to ${event.phone}');
    emit(const AuthLoading(message: 'SMS yuborilmoqda...'));

    final result = await _sendOtpUseCase(SendOtpParams(phone: event.phone));

    result.fold(
      (failure) {
        AppLogger.error('Failed to send OTP: ${failure.message}');
        emit(AuthError(failure: failure, previousState: state));
      },
      (_) {
        AppLogger.info('OTP sent successfully');
        emit(AuthOtpSent(event.phone));
      },
    );
  }

  Future<void> _onOtpVerified(
    AuthOtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Verifying OTP for ${event.phone}');
    emit(const AuthLoading(message: 'Tekshirilmoqda...'));

    final result = await _verifyOtpUseCase(
      VerifyOtpParams(phone: event.phone, code: event.code),
    );

    result.fold(
      (failure) {
        AppLogger.error('OTP verification failed: ${failure.message}');
        emit(AuthError(
          failure: failure,
          previousState: AuthOtpSent(event.phone),
        ));
      },
      (user) {
        if (user != null) {
          AppLogger.info('OTP verified, user exists');
          emit(AuthAuthenticated(user));
        } else {
          AppLogger.info('OTP verified, new user needs registration');
          emit(AuthNeedsRegistration(event.phone));
        }
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Registering user: ${event.phone}');
    emit(const AuthLoading(message: 'Ro\'yxatdan o\'tilmoqda...'));

    final result = await _registerUseCase(
      RegisterParams(
        phone: event.phone,
        fullName: event.fullName,
        email: event.email,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error('Registration failed: ${failure.message}');
        emit(AuthError(
          failure: failure,
          previousState: AuthNeedsRegistration(event.phone),
        ));
      },
      (user) {
        AppLogger.info('Registration successful');
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

  Future<void> _onOtpResendRequested(
    AuthOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Resending OTP to ${event.phone}');
    emit(const AuthLoading(message: 'Qayta yuborilmoqda...'));

    final result = await _sendOtpUseCase(SendOtpParams(phone: event.phone));

    result.fold(
      (failure) {
        AppLogger.error('Failed to resend OTP: ${failure.message}');
        emit(AuthError(
          failure: failure,
          previousState: AuthOtpSent(event.phone),
        ));
      },
      (_) {
        AppLogger.info('OTP resent successfully');
        emit(AuthOtpResent(event.phone));
      },
    );
  }
}
