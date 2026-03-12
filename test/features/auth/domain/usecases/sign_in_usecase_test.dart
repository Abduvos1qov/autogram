import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/user_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  const tParams = SignInParams(email: 'test@example.com', password: 'Test1234!');

  group('SignInUseCase', () {
    test('should return User on successful sign in', () async {
      when(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(UserFixtures.buyer));

      final result = await useCase(tParams);

      expect(result, Right(UserFixtures.buyer));
      verify(() => mockRepository.signIn(
            email: 'test@example.com',
            password: 'Test1234!',
          )).called(1);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
              (_) async => const Left(AuthFailure(message: 'Invalid credentials')));

      final result = await useCase(tParams);

      expect(result, isA<Left>());
    });
  });

  group('SignInParams', () {
    test('should support value equality', () {
      const params1 = SignInParams(email: 'a@b.com', password: '123');
      const params2 = SignInParams(email: 'a@b.com', password: '123');
      expect(params1, params2);
    });
  });
}
