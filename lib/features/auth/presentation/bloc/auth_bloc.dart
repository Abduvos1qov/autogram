import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/usecases/complete_profile_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BLoC - manages authentication state

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final CompleteProfileUseCase _completeProfileUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthBloc({
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required CompleteProfileUseCase completeProfileUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _sendOtpUseCase = sendOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _completeProfileUseCase = completeProfileUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpVerified>(_onOtpVerified);
    on<AuthCompleteProfileRequested>(_onCompleteProfileRequested);
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
          AppLogger.info('User is authenticated: ${user.email}');
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
    AppLogger.info('Sending OTP to ${event.email}');
    emit(const AuthLoading(message: 'Kod yuborilmoqda...'));

    final result = await _sendOtpUseCase(SendOtpParams(email: event.email));

    result.fold(
      (failure) {
        AppLogger.error('Failed to send OTP: ${failure.message}');
        emit(AuthError(failure: failure, previousState: state));
      },
      (_) {
        AppLogger.info('OTP sent successfully');
        emit(AuthOtpSent(event.email));
      },
    );
  }

  Future<void> _onOtpVerified(
    AuthOtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Verifying OTP for ${event.email}');
    emit(const AuthLoading(message: 'Tekshirilmoqda...'));

    final result = await _verifyOtpUseCase(
      VerifyOtpParams(email: event.email, code: event.code),
    );

    result.fold(
      (failure) {
        AppLogger.error('OTP verification failed: ${failure.message}');
        emit(AuthError(
          failure: failure,
          previousState: AuthOtpSent(event.email),
        ));
      },
      (user) {
        if (user != null) {
          AppLogger.info('OTP verified, user exists');
          emit(AuthAuthenticated(user));
        } else {
          AppLogger.info('OTP verified, new user needs registration');
          emit(AuthNeedsRegistration(event.email));
        }
      },
    );
  }

  Future<void> _onCompleteProfileRequested(
    AuthCompleteProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Completing profile for: ${event.email}');
    emit(const AuthLoading(message: 'Ro\'yxatdan o\'tilmoqda...'));

    final result = await _completeProfileUseCase(
      CompleteProfileParams(
        fullName: event.fullName,
        phone: event.phone,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error('Profile completion failed: ${failure.message}');
        emit(AuthError(
          failure: failure,
          previousState: AuthNeedsRegistration(event.email),
        ));
      },
      (user) {
        AppLogger.info('Profile completed successfully');
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
    AppLogger.info('Resending OTP to ${event.email}');
    emit(const AuthLoading(message: 'Qayta yuborilmoqda...'));

    final result = await _sendOtpUseCase(SendOtpParams(email: event.email));

    result.fold(
      (failure) {
        AppLogger.error('Failed to resend OTP: ${failure.message}');
        emit(AuthError(
          failure: failure,
          previousState: AuthOtpSent(event.email),
        ));
      },
      (_) {
        AppLogger.info('OTP resent successfully');
        emit(AuthOtpResent(event.email));
      },
    );
  }
}
