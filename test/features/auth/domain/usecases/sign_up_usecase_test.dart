import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late SignUpUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpUseCase(mockRepository);
  });

  const tParams = SignUpParams(
    email: 'test@example.com',
    password: 'Test1234!',
    fullName: 'Test User',
    phone: '+998901234567',
  );

  group('SignUpUseCase', () {
    test('should return void on successful sign up', () async {
      when(() => mockRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            dateOfBirth: any(named: 'dateOfBirth'),
          )).thenAnswer((_) async => const Right(null));

      final result = await useCase(tParams);

      expect(result, const Right(null));
      verify(() => mockRepository.signUp(
            email: 'test@example.com',
            password: 'Test1234!',
            fullName: 'Test User',
            phone: '+998901234567',
            dateOfBirth: null,
          )).called(1);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            dateOfBirth: any(named: 'dateOfBirth'),
          )).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Email already exists')));

      final result = await useCase(tParams);

      expect(result, isA<Left>());
    });
  });

  group('SignUpParams', () {
    test('should support value equality', () {
      const params1 = SignUpParams(
          email: 'a@b.com', password: '123', fullName: 'Test');
      const params2 = SignUpParams(
          email: 'a@b.com', password: '123', fullName: 'Test');
      expect(params1, params2);
    });
  });
}
