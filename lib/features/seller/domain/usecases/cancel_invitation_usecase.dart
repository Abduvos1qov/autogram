import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/seller_invitation_repository.dart';

/// Cancel (revoke) a pending invitation

class CancelInvitationUseCase implements UseCase<void, IdParams> {
  final SellerInvitationRepository _repository;

  CancelInvitationUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(IdParams params) {
    return _repository.cancelInvitation(params.id);
  }
}
