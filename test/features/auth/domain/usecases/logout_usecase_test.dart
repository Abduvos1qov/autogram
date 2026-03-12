import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/auth/domain/usecases/logout_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  group('LogoutUseCase', () {
    test('should return void on success', () async {
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right(null));
      verify(() => mockRepository.logout()).called(1);
    });

    test('should return Failure on error', () async {
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed')));

      final result = await useCase();

      expect(result, isA<Left>());
    });
  });
}
