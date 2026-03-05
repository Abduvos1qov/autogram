import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/seller_member_repository.dart';

/// Remove (deactivate) a member from a seller organization

class RemoveMemberUseCase implements UseCase<void, IdParams> {
  final SellerMemberRepository _repository;

  RemoveMemberUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(IdParams params) {
    return _repository.removeMember(params.id);
  }
}
