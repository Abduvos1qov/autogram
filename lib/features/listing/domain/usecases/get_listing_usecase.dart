import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

/// Get listing by ID use case

class GetListingUseCase implements UseCase<Listing, String> {
  final ListingRepository repository;

  GetListingUseCase(this.repository);

  @override
  Future<Either<Failure, Listing>> call(String listingId) {
    return repository.getListing(listingId);
  }
}
