import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/filter.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

/// Search listings use case

class SearchListingsUseCase
    implements UseCase<PaginatedResponse<SearchResult>, SearchParams> {
  final SearchRepository repository;

  SearchListingsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<SearchResult>>> call(
    SearchParams params,
  ) {
    return repository.searchListings(
      query: params.query,
      filter: params.filter,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class SearchParams extends Equatable {
  final String? query;
  final SearchFilter? filter;
  final int page;
  final int pageSize;

  const SearchParams({
    this.query,
    this.filter,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [query, filter, page, pageSize];
}
