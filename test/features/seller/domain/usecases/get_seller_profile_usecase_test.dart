import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/core/usecases/usecase.dart';
import 'package:autogram/features/seller/domain/usecases/get_seller_profile_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/profile_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late GetSellerProfileUseCase usecase;
  late MockSellerRepository mockRepo;

  setUp(() {
    mockRepo = MockSellerRepository();
    usecase = GetSellerProfileUseCase(mockRepo);
  });

  test('returns Right(SellerProfile) when repository succeeds', () async {
    when(() => mockRepo.getSellerProfile())
        .thenAnswer((_) async => Right(ProfileFixtures.sellerProfile));

    final result = await usecase(const NoParams());

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected Right'),
      (sp) => expect(sp, ProfileFixtures.sellerProfile),
    );
  });

  test('returns Right(null) when user is not yet a seller', () async {
    when(() => mockRepo.getSellerProfile())
        .thenAnswer((_) async => const Right(null));

    final result = await usecase(const NoParams());

    expect(result, const Right(null));
  });

  test('returns Left(Failure) on repository error', () async {
    when(() => mockRepo.getSellerProfile()).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'server')),
    );

    final result = await usecase(const NoParams());

    expect(result, const Left(ServerFailure(message: 'server')));
  });
}
