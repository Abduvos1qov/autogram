import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reel.dart';
import '../repositories/reels_repository.dart';

/// Get reels use case

class GetReelsUseCase
    implements UseCase<PaginatedResponse<Reel>, PaginationParams> {
  final ReelsRepository _repository;

  GetReelsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResponse<Reel>>> call(
    PaginationParams params,
  ) {
    return _repository.getReels(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}
