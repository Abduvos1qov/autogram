import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/domain/usecases/set_username_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/user_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late SetUsernameUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SetUsernameUseCase(mockRepository);
  });

  const tParams = SetUsernameParams(username: 'newuser');

  group('SetUsernameUseCase', () {
    test('should return User on success', () async {
      final tUser = UserFixtures.buyer.copyWith(username: 'newuser');
      when(() => mockRepository.setUsername(
            username: any(named: 'username'),
          )).thenAnswer((_) async => Right(tUser));

      final result = await useCase(tParams);

      expect(result, Right(tUser));
      verify(() => mockRepository.setUsername(username: 'newuser')).called(1);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.setUsername(
            username: any(named: 'username'),
          )).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Failed')));

      final result = await useCase(tParams);

      expect(result, isA<Left>());
    });
  });
}
