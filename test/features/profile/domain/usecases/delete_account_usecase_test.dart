import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/core/usecases/usecase.dart';
import 'package:autogram/features/profile/domain/usecases/delete_account_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late DeleteAccountUseCase usecase;
  late MockProfileRepository mockRepo;

  setUp(() {
    mockRepo = MockProfileRepository();
    usecase = DeleteAccountUseCase(mockRepo);
  });

  test('returns Right(void) on success', () async {
    when(() => mockRepo.deleteAccount())
        .thenAnswer((_) async => const Right(null));

    final result = await usecase(const NoParams());

    expect(result.isRight(), isTrue);
    verify(() => mockRepo.deleteAccount()).called(1);
  });

  test('returns Left(Failure) on failure', () async {
    when(() => mockRepo.deleteAccount()).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'cannot delete')),
    );

    final result = await usecase(const NoParams());

    expect(result, const Left(ServerFailure(message: 'cannot delete')));
  });
}
