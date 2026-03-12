import 'package:autogram/core/errors/exceptions.dart';
import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/data/models/user_model.dart';
import 'package:autogram/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/user_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemote;
  late MockAuthLocalDataSource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  final tUserModel = UserModel.fromEntity(UserFixtures.buyer);

  setUpAll(() {
    registerFallbackValue(tUserModel);
  });

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockLocal = MockAuthLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      networkInfo: mockNetworkInfo,
    );
  });

  void setUpNetworkConnected() {
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
  }

  void setUpNetworkDisconnected() {
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
  }

  group('signUp', () {
    test('should return NetworkFailure when not connected', () async {
      setUpNetworkDisconnected();

      final result = await repository.signUp(
        email: 'test@test.com',
        password: 'pass',
        fullName: 'Test',
      );

      expect(result, const Left(NetworkFailure()));
    });

    test('should return Right(void) on success', () async {
      setUpNetworkConnected();
      when(() => mockRemote.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            dateOfBirth: any(named: 'dateOfBirth'),
          )).thenAnswer((_) async {});

      final result = await repository.signUp(
        email: 'test@test.com',
        password: 'pass',
        fullName: 'Test',
      );

      expect(result, isA<Right>());
    });

    test('should return Failure when remote throws exception', () async {
      setUpNetworkConnected();
      when(() => mockRemote.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            dateOfBirth: any(named: 'dateOfBirth'),
          )).thenThrow(const AuthException(message: 'Email taken'));

      final result = await repository.signUp(
        email: 'test@test.com',
        password: 'pass',
        fullName: 'Test',
      );

      expect(result, isA<Left>());
    });
  });

  group('signIn', () {
    test('should return NetworkFailure when not connected', () async {
      setUpNetworkDisconnected();

      final result = await repository.signIn(
        email: 'test@test.com',
        password: 'pass',
      );

      expect(result, const Left(NetworkFailure()));
    });

    test('should return User and cache on success', () async {
      setUpNetworkConnected();
      when(() => mockRemote.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tUserModel);
      when(() => mockLocal.cacheUser(any())).thenAnswer((_) async {});

      final result = await repository.signIn(
        email: 'test@test.com',
        password: 'pass',
      );

      expect(result, isA<Right>());
      verify(() => mockLocal.cacheUser(tUserModel)).called(1);
    });

    test('should return Failure when remote throws', () async {
      setUpNetworkConnected();
      when(() => mockRemote.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const AuthException(message: 'Invalid'));

      final result = await repository.signIn(
        email: 'test@test.com',
        password: 'pass',
      );

      expect(result, isA<Left>());
    });
  });

  group('verifyOtp', () {
    test('should return NetworkFailure when not connected', () async {
      setUpNetworkDisconnected();

      final result = await repository.verifyOtp(
        email: 'test@test.com',
        otp: '123456',
      );

      expect(result, const Left(NetworkFailure()));
    });

    test('should return User and cache on success', () async {
      setUpNetworkConnected();
      when(() => mockRemote.verifyOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => tUserModel);
      when(() => mockLocal.cacheUser(any())).thenAnswer((_) async {});

      final result = await repository.verifyOtp(
        email: 'test@test.com',
        otp: '123456',
      );

      expect(result, isA<Right>());
      verify(() => mockLocal.cacheUser(tUserModel)).called(1);
    });
  });

  group('resetPassword', () {
    test('should return NetworkFailure when not connected', () async {
      setUpNetworkDisconnected();

      final result = await repository.resetPassword(email: 'test@test.com');

      expect(result, const Left(NetworkFailure()));
    });

    test('should return Right(void) on success', () async {
      setUpNetworkConnected();
      when(() => mockRemote.resetPassword(email: any(named: 'email')))
          .thenAnswer((_) async {});

      final result = await repository.resetPassword(email: 'test@test.com');

      expect(result, isA<Right>());
    });
  });

  group('resendSignUpOtp', () {
    test('should return NetworkFailure when not connected', () async {
      setUpNetworkDisconnected();

      final result = await repository.resendSignUpOtp(email: 'test@test.com');

      expect(result, const Left(NetworkFailure()));
    });

    test('should return Right(void) on success', () async {
      setUpNetworkConnected();
      when(() => mockRemote.resendSignUpOtp(email: any(named: 'email')))
          .thenAnswer((_) async {});

      final result = await repository.resendSignUpOtp(email: 'test@test.com');

      expect(result, isA<Right>());
    });
  });

  group('sendForgotPasswordOtp', () {
    test('should return NetworkFailure when not connected', () async {
      setUpNetworkDisconnected();

      final result =
          await repository.sendForgotPasswordOtp(email: 'test@test.com');

      expect(result, const Left(NetworkFailure()));
    });

    test('should return Right(void) on success', () async {
      setUpNetworkConnected();
      when(() => mockRemote.sendForgotPasswordOtp(email: any(named: 'email')))
          .thenAnswer((_) async {});

      final result =
          await repository.sendForgotPasswordOtp(email: 'test@test.com');

      expect(result, isA<Right>());
    });
  });

  group('verifyForgotPasswordOtp', () {
    test('should return NetworkFailure when not connected', () async {
      setUpNetworkDisconnected();

      final result = await repository.verifyForgotPasswordOtp(
        email: 'test@test.com',
        otp: '123456',
      );

      expect(result, const Left(NetworkFailure()));
    });

    test('should return Right(void) on success', () async {
      setUpNetworkConnected();
      when(() => mockRemote.verifyForgotPasswordOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async {});

      final result = await repository.verifyForgotPasswordOtp(
        email: 'test@test.com',
        otp: '123456',
      );

      expect(result, isA<Right>());
    });
  });

  group('resetPasswordWithNew', () {
    test('should return NetworkFailure when not connected', () async {
      setUpNetworkDisconnected();

      final result = await repository.resetPasswordWithNew(
        email: 'test@test.com',
        newPassword: 'new123',
      );

      expect(result, const Left(NetworkFailure()));
    });

    test('should return Right(void) on success', () async {
      setUpNetworkConnected();
      when(() => mockRemote.resetPasswordWithNew(
            email: any(named: 'email'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async {});

      final result = await repository.resetPasswordWithNew(
        email: 'test@test.com',
        newPassword: 'new123',
      );

      expect(result, isA<Right>());
    });
  });

  group('setUsername', () {
    test('should return NetworkFailure when not connected', () async {
      setUpNetworkDisconnected();

      final result = await repository.setUsername(username: 'testuser');

      expect(result, const Left(NetworkFailure()));
    });

    test('should return User and cache on success', () async {
      setUpNetworkConnected();
      when(() => mockRemote.setUsername(username: any(named: 'username')))
          .thenAnswer((_) async => tUserModel);
      when(() => mockLocal.cacheUser(any())).thenAnswer((_) async {});

      final result = await repository.setUsername(username: 'testuser');

      expect(result, isA<Right>());
      verify(() => mockLocal.cacheUser(tUserModel)).called(1);
    });
  });

  group('checkUsernameAvailability', () {
    test('should return NetworkFailure when not connected', () async {
      setUpNetworkDisconnected();

      final result =
          await repository.checkUsernameAvailability(username: 'testuser');

      expect(result, const Left(NetworkFailure()));
    });

    test('should return bool on success', () async {
      setUpNetworkConnected();
      when(() => mockRemote.checkUsernameAvailability(
            username: any(named: 'username'),
          )).thenAnswer((_) async => true);

      final result =
          await repository.checkUsernameAvailability(username: 'testuser');

      expect(result, const Right(true));
    });
  });

  group('getCurrentUser', () {
    test('should return remote user and cache when connected', () async {
      setUpNetworkConnected();
      when(() => mockRemote.getCurrentUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockLocal.cacheUser(any())).thenAnswer((_) async {});

      final result = await repository.getCurrentUser();

      result.fold(
        (failure) => fail('should not return failure'),
        (user) => expect(user, tUserModel),
      );
      verify(() => mockLocal.cacheUser(tUserModel)).called(1);
    });

    test('should fall back to cache when remote returns null', () async {
      setUpNetworkConnected();
      when(() => mockRemote.getCurrentUser()).thenAnswer((_) async => null);
      when(() => mockLocal.getCachedUser())
          .thenAnswer((_) async => tUserModel);

      final result = await repository.getCurrentUser();

      result.fold(
        (failure) => fail('should not return failure'),
        (user) => expect(user, tUserModel),
      );
    });

    test('should fall back to cache when not connected', () async {
      setUpNetworkDisconnected();
      when(() => mockLocal.getCachedUser())
          .thenAnswer((_) async => tUserModel);

      final result = await repository.getCurrentUser();

      result.fold(
        (failure) => fail('should not return failure'),
        (user) => expect(user, tUserModel),
      );
    });

    test('should return null when no cached user and not connected', () async {
      setUpNetworkDisconnected();
      when(() => mockLocal.getCachedUser()).thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      result.fold(
        (failure) => fail('should not return failure'),
        (user) => expect(user, isNull),
      );
    });

    test('should fall back to cache on remote exception', () async {
      setUpNetworkConnected();
      when(() => mockRemote.getCurrentUser())
          .thenThrow(const ServerException(message: 'error'));
      when(() => mockLocal.getCachedUser())
          .thenAnswer((_) async => tUserModel);

      final result = await repository.getCurrentUser();

      result.fold(
        (failure) => fail('should not return failure'),
        (user) => expect(user, tUserModel),
      );
    });

    test('should return Failure when both remote and cache fail', () async {
      setUpNetworkConnected();
      when(() => mockRemote.getCurrentUser())
          .thenThrow(const ServerException(message: 'error'));
      when(() => mockLocal.getCachedUser()).thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result, isA<Left>());
    });
  });

  group('logout', () {
    test('should call remote and clear cache on success', () async {
      when(() => mockRemote.logout()).thenAnswer((_) async {});
      when(() => mockLocal.clearUserCache()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, const Right(null));
      verify(() => mockRemote.logout()).called(1);
      verify(() => mockLocal.clearUserCache()).called(1);
    });

    test('should return Failure when remote throws', () async {
      when(() => mockRemote.logout())
          .thenThrow(const ServerException(message: 'error'));

      final result = await repository.logout();

      expect(result, isA<Left>());
    });
  });

  group('isAuthenticated', () {
    test('should return true when user exists', () async {
      setUpNetworkConnected();
      when(() => mockRemote.getCurrentUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockLocal.cacheUser(any())).thenAnswer((_) async {});

      final result = await repository.isAuthenticated();

      expect(result, true);
    });

    test('should return false when user is null', () async {
      setUpNetworkDisconnected();
      when(() => mockLocal.getCachedUser()).thenAnswer((_) async => null);

      final result = await repository.isAuthenticated();

      expect(result, false);
    });
  });

  group('authStateChanges', () {
    test('should delegate to remote data source', () {
      when(() => mockRemote.authStateChanges)
          .thenAnswer((_) => Stream.value(tUserModel));

      final stream = repository.authStateChanges;

      expect(stream, isA<Stream>());
    });
  });
}
