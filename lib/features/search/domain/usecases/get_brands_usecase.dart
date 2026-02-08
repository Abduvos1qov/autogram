import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/filter.dart';
import '../repositories/search_repository.dart';

/// Get available car brands use case

class GetBrandsUseCase implements UseCase<List<BrandModel>, NoParams> {
  final SearchRepository repository;

  GetBrandsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BrandModel>>> call(NoParams params) {
    return repository.getBrands();
  }
}
