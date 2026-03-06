import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/check_username_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/set_username_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
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

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required SetUsernameUseCase setUsernameUseCase,
    required CheckUsernameUseCase checkUsernameUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _setUsernameUseCase = setUsernameUseCase,
        _checkUsernameUseCase = checkUsernameUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthUsernameSubmitted>(_onUsernameSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
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
        emit(AuthError(failure: failure, previousState: state));
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
        emit(AuthError(failure: failure, previousState: state));
      },
      (_) {
        AppLogger.info('Sign up successful, verification needed');
        emit(AuthSignUpSuccess(event.email));
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
        emit(AuthError(failure: failure, previousState: state));
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
        emit(AuthError(failure: failure, previousState: state));
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
