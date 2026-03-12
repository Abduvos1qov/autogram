import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late ResetPasswordUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ResetPasswordUseCase(mockRepository);
  });

  const tParams = ResetPasswordParams(email: 'test@example.com');

  group('ResetPasswordUseCase', () {
    test('should return void on success', () async {
      when(() => mockRepository.resetPassword(
            email: any(named: 'email'),
          )).thenAnswer((_) async => const Right(null));

      final result = await useCase(tParams);

      expect(result, const Right(null));
      verify(() => mockRepository.resetPassword(email: 'test@example.com'))
          .called(1);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.resetPassword(
            email: any(named: 'email'),
          )).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'User not found')));

      final result = await useCase(tParams);

      expect(result, isA<Left>());
    });
  });
}
