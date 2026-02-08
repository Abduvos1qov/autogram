import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed_item.dart';
import '../repositories/home_repository.dart';

/// Get feed use case

class GetFeedUseCase
    implements UseCase<PaginatedResponse<FeedItem>, PaginationParams> {
  final HomeRepository _repository;

  GetFeedUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResponse<FeedItem>>> call(
    PaginationParams params,
  ) {
    return _repository.getFeed(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}
