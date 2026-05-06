# Reference: AuthBloc (autogram)

This is the canonical BLoC pattern for the Autogram project. Every new BLoC should match this structure exactly.

Source: `lib/features/auth/presentation/bloc/`

## File 1 — `auth_bloc.dart`

```dart
import 'package:autogram/core/utils/app_logger.dart';
import 'package:autogram/features/auth/domain/usecases/check_username_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/logout_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:autogram/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final CheckUsernameUseCase _checkUsernameUseCase;
  // ... more use cases

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required CheckUsernameUseCase checkUsernameUseCase,
    // ... more required named params
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _checkUsernameUseCase = checkUsernameUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    // ...
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
        if (user == null) {
          emit(const AuthUnauthenticated());
        } else if (!user.hasUsername) {
          emit(AuthNeedsUsername(user));
        } else {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(
        user.hasUsername ? AuthAuthenticated(user) : AuthNeedsUsername(user),
      ),
    );
  }
}
```

## File 2 — `auth_event.dart`

```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? phone;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, fullName, phone];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
```

## File 3 — `auth_state.dart`

```dart
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthNeedsUsername extends AuthState {
  final User user;
  const AuthNeedsUsername(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
```

## Pattern observations

- **Three independent files.** No `part` / `part of`. Each file imports `equatable` and any entities it needs. The bloc imports the event + state files explicitly.
- **Equatable event base.** `abstract class <Feature>Event extends Equatable { const <Feature>Event(); @override List<Object?> get props => []; }`. Concrete events extend it with `final` fields and a `props` list.
- **State class hierarchy.** Multiple state subclasses (`AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthNeedsUsername`, `AuthError`), NOT a single class with a `status` enum. The page distinguishes via `if (state is AuthLoading)` etc.
- **Constructor injection of use cases.** Every use case dependency is a `required` named parameter. They're assigned to private `final` fields via the colon-initializer-list, then `super(<Feature>Initial())` is called. The Bloc class itself never calls `sl<...>()`.
- **`Either.fold` for async work.** Repos and use cases return `Either<Failure, T>`. Inside an event handler:
  ```dart
  final result = await _useCase(params);
  result.fold(
    (failure) => emit(<Feature>Error(failure.message)),
    (data) => emit(<Feature>Loaded(data)),
  );
  ```
  Never `try / catch` — `RepositoryMixin.safeRemoteCall` inside the repo already converts exceptions into `Left(Failure)`.
- **`AppLogger` for diagnostic logs.** `AppLogger.info`, `AppLogger.warning`, `AppLogger.error`. Never `print` / `debugPrint`.
- **Loading state can carry a message** (`AuthLoading({this.message})`) — useful for "Checking…", "Signing in…" captions in the UI.
- **Feature-specific state subclasses are encouraged.** `AuthNeedsUsername(user)` carries the user object so the username screen can prefill. Don't squeeze every state into a generic `<Feature>Loaded` if the feature has distinct UX phases.
- **Initial state is `const <Feature>Initial()`** — passed via `super(const <Feature>Initial())`.
