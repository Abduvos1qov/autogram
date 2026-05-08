import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_profile.dart';
import '../repositories/seller_repository.dart';

class GetSellerProfileUseCase implements UseCase<SellerProfile?, NoParams> {
  final SellerRepository _repository;

  GetSellerProfileUseCase(this._repository);

  @override
  Future<Either<Failure, SellerProfile?>> call(NoParams params) {
    return _repository.getSellerProfile();
  }
}
