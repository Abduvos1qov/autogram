import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/core/usecases/usecase.dart';
import 'package:autogram/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/profile_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late GetProfileUseCase usecase;
  late MockProfileRepository mockRepo;

  setUp(() {
    mockRepo = MockProfileRepository();
    usecase = GetProfileUseCase(mockRepo);
  });

  test('returns Right(UserProfile) when repository succeeds', () async {
    when(() => mockRepo.getProfile())
        .thenAnswer((_) async => Right(ProfileFixtures.buyer));

    final result = await usecase(const NoParams());

    expect(result, Right(ProfileFixtures.buyer));
    verify(() => mockRepo.getProfile()).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(() => mockRepo.getProfile())
        .thenAnswer((_) async => const Left(ServerFailure(message: 'oops')));

    final result = await usecase(const NoParams());

    expect(result, const Left(ServerFailure(message: 'oops')));
  });
}
