import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class GetSellerListingsParams extends Equatable {
  final String sellerId;
  final int page;
  final int pageSize;
  final ListingStatus? status;

  const GetSellerListingsParams({
    required this.sellerId,
    this.page = 1,
    this.pageSize = 20,
    this.status,
  });

  @override
  List<Object?> get props => [sellerId, page, pageSize, status];
}

class GetSellerListingsUseCase
    implements
        UseCase<PaginatedResponse<Listing>, GetSellerListingsParams> {
  final ListingRepository _repository;

  GetSellerListingsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResponse<Listing>>> call(
    GetSellerListingsParams params,
  ) {
    return _repository.getSellerListings(
      sellerId: params.sellerId,
      page: params.page,
      pageSize: params.pageSize,
      status: params.status,
    );
  }
}
