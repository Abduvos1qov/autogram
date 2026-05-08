import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/profile_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late UpdateProfileUseCase usecase;
  late MockProfileRepository mockRepo;

  setUp(() {
    mockRepo = MockProfileRepository();
    usecase = UpdateProfileUseCase(mockRepo);
  });

  test('forwards every field to the repository', () async {
    when(() => mockRepo.updateProfile(
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
          language: any(named: 'language'),
        )).thenAnswer((_) async => Right(ProfileFixtures.buyer));

    final result = await usecase(
      const UpdateProfileParams(
        fullName: 'New',
        email: 'new@example.com',
        language: 'en',
      ),
    );

    expect(result.isRight(), isTrue);
    verify(() => mockRepo.updateProfile(
          fullName: 'New',
          email: 'new@example.com',
          language: 'en',
        )).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(() => mockRepo.updateProfile(
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
          language: any(named: 'language'),
        )).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'fail')),
    );

    final result = await usecase(
      const UpdateProfileParams(fullName: 'X'),
    );

    expect(result, const Left(ServerFailure(message: 'fail')));
  });

  test('UpdateProfileParams equality', () {
    const a = UpdateProfileParams(fullName: 'X');
    const b = UpdateProfileParams(fullName: 'X');
    const c = UpdateProfileParams(fullName: 'Y');
    expect(a, equals(b));
    expect(a, isNot(equals(c)));
  });
}
