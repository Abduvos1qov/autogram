import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/permission_service.dart';
import '../entities/seller_invitation.dart';

/// Seller invitation repository interface

abstract class SellerInvitationRepository {
  /// Send an invitation to join a seller organization
  Future<Either<Failure, SellerInvitation>> sendInvitation({
    required String sellerProfileId,
    required String email,
    required MemberRole role,
  });

  /// Get all pending invitations for a seller organization
  Future<Either<Failure, List<SellerInvitation>>> getPendingInvitations(
      String sellerProfileId);

  /// Accept an invitation
  Future<Either<Failure, SellerInvitation>> acceptInvitation(
      String invitationId);

  /// Reject an invitation
  Future<Either<Failure, SellerInvitation>> rejectInvitation(
      String invitationId);

  /// Cancel (revoke) an invitation
  Future<Either<Failure, void>> cancelInvitation(String invitationId);

  /// Get invitations sent to the current user's email
  Future<Either<Failure, List<SellerInvitation>>> getMyInvitations();
}
