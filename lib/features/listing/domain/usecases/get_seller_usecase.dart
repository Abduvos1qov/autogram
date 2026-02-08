import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

/// Get seller by ID use case

class GetSellerUseCase implements UseCase<Seller, String> {
  final ListingRepository repository;

  GetSellerUseCase(this.repository);

  @override
  Future<Either<Failure, Seller>> call(String sellerId) {
    return repository.getSeller(sellerId);
  }
}
