import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_member.dart';
import '../repositories/seller_member_repository.dart';

/// Get the current authenticated user's membership in any seller organization

class GetCurrentMembershipUseCase
    implements NoParamsUseCase<SellerMember?> {
  final SellerMemberRepository _repository;

  GetCurrentMembershipUseCase(this._repository);

  @override
  Future<Either<Failure, SellerMember?>> call() {
    return _repository.getCurrentMembership();
  }
}
