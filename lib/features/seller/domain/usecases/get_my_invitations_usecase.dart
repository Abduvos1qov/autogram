import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_invitation.dart';
import '../repositories/seller_invitation_repository.dart';

/// Get invitations sent to the current user's email

class GetMyInvitationsUseCase
    implements NoParamsUseCase<List<SellerInvitation>> {
  final SellerInvitationRepository _repository;

  GetMyInvitationsUseCase(this._repository);

  @override
  Future<Either<Failure, List<SellerInvitation>>> call() {
    return _repository.getMyInvitations();
  }
}
