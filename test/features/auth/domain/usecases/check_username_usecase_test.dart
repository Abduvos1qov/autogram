import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/domain/usecases/check_username_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late CheckUsernameUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = CheckUsernameUseCase(mockRepository);
  });

  const tParams = CheckUsernameParams(username: 'testuser');

  group('CheckUsernameUseCase', () {
    test('should return true when username is available', () async {
      when(() => mockRepository.checkUsernameAvailability(
            username: any(named: 'username'),
          )).thenAnswer((_) async => const Right(true));

      final result = await useCase(tParams);

      expect(result, const Right(true));
      verify(() => mockRepository.checkUsernameAvailability(
            username: 'testuser',
          )).called(1);
    });

    test('should return false when username is taken', () async {
      when(() => mockRepository.checkUsernameAvailability(
            username: any(named: 'username'),
          )).thenAnswer((_) async => const Right(false));

      final result = await useCase(tParams);

      expect(result, const Right(false));
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.checkUsernameAvailability(
            username: any(named: 'username'),
          )).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Failed')));

      final result = await useCase(tParams);

      expect(result, isA<Left>());
    });
  });
}
