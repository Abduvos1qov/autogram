import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// Base UseCase class for Clean Architecture
///
/// Type - the return type of the use case
/// Params - the parameters required by the use case

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case that doesn't require parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Use case that returns a Stream
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Use case that returns a Stream without parameters
abstract class NoParamsStreamUseCase<Type> {
  Stream<Either<Failure, Type>> call();
}

/// Empty parameters class for use cases that don't require parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Pagination parameters
class PaginationParams extends Equatable {
  final int page;
  final int pageSize;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [page, pageSize];

  PaginationParams copyWith({
    int? page,
    int? pageSize,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  PaginationParams nextPage() {
    return copyWith(page: page + 1);
  }

  int get offset => (page - 1) * pageSize;
}

/// ID parameter for single entity operations
class IdParams extends Equatable {
  final String id;

  const IdParams(this.id);

  @override
  List<Object?> get props => [id];
}
