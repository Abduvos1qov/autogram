import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_invitation.dart';
import '../repositories/seller_invitation_repository.dart';

/// Send an invitation to join a seller organization

class SendInvitationUseCase
    implements UseCase<SellerInvitation, SendInvitationParams> {
  final SellerInvitationRepository _repository;

  SendInvitationUseCase(this._repository);

  @override
  Future<Either<Failure, SellerInvitation>> call(
      SendInvitationParams params) {
    return _repository.sendInvitation(
      sellerProfileId: params.sellerProfileId,
      email: params.email,
      role: params.role,
    );
  }
}

class SendInvitationParams extends Equatable {
  final String sellerProfileId;
  final String email;
  final MemberRole role;

  const SendInvitationParams({
    required this.sellerProfileId,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [sellerProfileId, email, role];
}
