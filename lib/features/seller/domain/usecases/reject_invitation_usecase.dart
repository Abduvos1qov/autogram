import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_invitation.dart';
import '../repositories/seller_invitation_repository.dart';

/// Reject an invitation to join a seller organization

class RejectInvitationUseCase
    implements UseCase<SellerInvitation, IdParams> {
  final SellerInvitationRepository _repository;

  RejectInvitationUseCase(this._repository);

  @override
  Future<Either<Failure, SellerInvitation>> call(IdParams params) {
    return _repository.rejectInvitation(params.id);
  }
}
