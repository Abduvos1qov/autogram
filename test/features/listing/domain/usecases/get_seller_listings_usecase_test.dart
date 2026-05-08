import 'package:autogram/core/errors/failures.dart';
import 'package:autogram/core/network/api_response.dart';
import 'package:autogram/features/listing/domain/entities/listing.dart';
import 'package:autogram/features/listing/domain/usecases/get_seller_listings_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/profile_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late GetSellerListingsUseCase usecase;
  late MockListingRepository mockRepo;

  setUp(() {
    mockRepo = MockListingRepository();
    usecase = GetSellerListingsUseCase(mockRepo);
  });

  test('forwards every parameter to the repository', () async {
    when(() => mockRepo.getSellerListings(
          sellerId: any(named: 'sellerId'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => Right(
          PaginatedResponse(
            data: ProfileFixtures.activeListings(3),
            page: 1,
            pageSize: 12,
            total: 3,
            hasMore: false,
          ),
        ));

    final result = await usecase(
      const GetSellerListingsParams(
        sellerId: 'seller-001',
        page: 2,
        pageSize: 10,
        status: ListingStatus.sold,
      ),
    );

    expect(result.isRight(), isTrue);
    verify(() => mockRepo.getSellerListings(
          sellerId: 'seller-001',
          page: 2,
          pageSize: 10,
          status: ListingStatus.sold,
        )).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(() => mockRepo.getSellerListings(
          sellerId: any(named: 'sellerId'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        )).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'fail')),
    );

    final result = await usecase(
      const GetSellerListingsParams(sellerId: 'seller-001'),
    );

    expect(result, const Left(ServerFailure(message: 'fail')));
  });

  test('GetSellerListingsParams equality', () {
    const a = GetSellerListingsParams(
      sellerId: 's',
      page: 1,
      pageSize: 12,
      status: ListingStatus.active,
    );
    const b = GetSellerListingsParams(
      sellerId: 's',
      page: 1,
      pageSize: 12,
      status: ListingStatus.active,
    );
    const c = GetSellerListingsParams(
      sellerId: 's',
      page: 2,
      pageSize: 12,
      status: ListingStatus.active,
    );
    expect(a, equals(b));
    expect(a, isNot(equals(c)));
  });
}
