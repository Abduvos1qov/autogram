import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/user_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockRepository);
  });

  group('GetCurrentUserUseCase', () {
    test('should return User when authenticated', () async {
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => Right(UserFixtures.buyer));

      final result = await useCase();

      expect(result, Right(UserFixtures.buyer));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('should return null when not authenticated', () async {
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase();

      result.fold(
        (failure) => fail('should not return failure'),
        (user) => expect(user, isNull),
      );
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed')));

      final result = await useCase();

      expect(result, isA<Left>());
    });
  });
}
