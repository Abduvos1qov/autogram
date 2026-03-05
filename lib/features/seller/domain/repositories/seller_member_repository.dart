import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/permission_service.dart';
import '../entities/seller_member.dart';

/// Seller member repository interface

abstract class SellerMemberRepository {
  /// Get all team members for a seller organization
  Future<Either<Failure, List<SellerMember>>> getTeamMembers(
      String sellerProfileId);

  /// Get a specific member by user ID within a seller organization
  Future<Either<Failure, SellerMember?>> getMemberByUserId(
    String sellerProfileId,
    String userId,
  );

  /// Add a new member to a seller organization
  Future<Either<Failure, SellerMember>> addMember({
    required String sellerProfileId,
    required String email,
    required MemberRole role,
  });

  /// Update a member's role
  Future<Either<Failure, SellerMember>> updateMemberRole({
    required String memberId,
    required MemberRole role,
  });

  /// Remove (deactivate) a member from the organization
  Future<Either<Failure, void>> removeMember(String memberId);

  /// Get the current authenticated user's membership (if any)
  Future<Either<Failure, SellerMember?>> getCurrentMembership();
}
