import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/repository_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/permission_service.dart';
import '../../domain/entities/seller_invitation.dart';
import '../../domain/repositories/seller_invitation_repository.dart';
import '../datasources/seller_invitation_remote_datasource.dart';

/// Seller invitation repository implementation

class SellerInvitationRepositoryImpl
    with RepositoryMixin
    implements SellerInvitationRepository {
  final SellerInvitationRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  SellerInvitationRepositoryImpl({
    required SellerInvitationRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, SellerInvitation>> sendInvitation({
    required String sellerProfileId,
    required String email,
    required MemberRole role,
  }) =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.sendInvitation(
          sellerProfileId: sellerProfileId,
          email: email,
          role: role,
        );
      });

  @override
  Future<Either<Failure, List<SellerInvitation>>> getPendingInvitations(
          String sellerProfileId) =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.getPendingInvitations(sellerProfileId);
      });

  @override
  Future<Either<Failure, SellerInvitation>> acceptInvitation(
          String invitationId) =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.acceptInvitation(invitationId);
      });

  @override
  Future<Either<Failure, SellerInvitation>> rejectInvitation(
          String invitationId) =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.rejectInvitation(invitationId);
      });

  @override
  Future<Either<Failure, void>> cancelInvitation(String invitationId) =>
      safeRemoteCall(_networkInfo, () async {
        await _remoteDataSource.cancelInvitation(invitationId);
      });

  @override
  Future<Either<Failure, List<SellerInvitation>>> getMyInvitations() =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.getMyInvitations();
      });
}
