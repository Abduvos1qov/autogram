import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/domain/usecases/reset_password_with_new_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late ResetPasswordWithNewUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ResetPasswordWithNewUseCase(mockRepository);
  });

  const tParams = ResetPasswordWithNewParams(
    email: 'test@example.com',
    newPassword: 'NewPass1234!',
  );

  group('ResetPasswordWithNewUseCase', () {
    test('should return void on success', () async {
      when(() => mockRepository.resetPasswordWithNew(
            email: any(named: 'email'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => const Right(null));

      final result = await useCase(tParams);

      expect(result, const Right(null));
      verify(() => mockRepository.resetPasswordWithNew(
            email: 'test@example.com',
            newPassword: 'NewPass1234!',
          )).called(1);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.resetPasswordWithNew(
            email: any(named: 'email'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Failed')));

      final result = await useCase(tParams);

      expect(result, isA<Left>());
    });
  });
}
