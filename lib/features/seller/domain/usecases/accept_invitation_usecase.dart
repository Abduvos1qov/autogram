import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_invitation.dart';
import '../repositories/seller_invitation_repository.dart';

/// Accept an invitation to join a seller organization

class AcceptInvitationUseCase
    implements UseCase<SellerInvitation, IdParams> {
  final SellerInvitationRepository _repository;

  AcceptInvitationUseCase(this._repository);

  @override
  Future<Either<Failure, SellerInvitation>> call(IdParams params) {
    return _repository.acceptInvitation(params.id);
  }
}
