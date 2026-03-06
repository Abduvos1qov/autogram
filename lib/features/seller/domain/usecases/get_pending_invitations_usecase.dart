import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_invitation.dart';
import '../repositories/seller_invitation_repository.dart';

/// Get all pending invitations for a seller organization

class GetPendingInvitationsUseCase
    implements UseCase<List<SellerInvitation>, IdParams> {
  final SellerInvitationRepository _repository;

  GetPendingInvitationsUseCase(this._repository);

  @override
  Future<Either<Failure, List<SellerInvitation>>> call(IdParams params) {
    return _repository.getPendingInvitations(params.id);
  }
}
