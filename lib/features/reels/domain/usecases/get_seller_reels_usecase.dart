import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reel.dart';
import '../repositories/reels_repository.dart';

class GetSellerReelsParams extends Equatable {
  final String sellerId;
  final int page;
  final int pageSize;

  const GetSellerReelsParams({
    required this.sellerId,
    this.page = 1,
    this.pageSize = 12,
  });

  @override
  List<Object?> get props => [sellerId, page, pageSize];
}

class GetSellerReelsUseCase
    implements UseCase<PaginatedResponse<Reel>, GetSellerReelsParams> {
  final ReelsRepository _repository;

  GetSellerReelsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResponse<Reel>>> call(
    GetSellerReelsParams params,
  ) {
    return _repository.getSellerReels(
      sellerId: params.sellerId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}
