import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/permission_service.dart';
import '../../domain/entities/seller_invitation.dart';
import '../../domain/repositories/seller_invitation_repository.dart';
import '../datasources/seller_invitation_remote_datasource.dart';

/// Seller invitation repository implementation

class SellerInvitationRepositoryImpl implements SellerInvitationRepository {
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
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      final invitation = await _remoteDataSource.sendInvitation(
        sellerProfileId: sellerProfileId,
        email: email,
        role: role,
      );
      return Right(invitation);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<SellerInvitation>>> getPendingInvitations(
      String sellerProfileId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      final invitations =
          await _remoteDataSource.getPendingInvitations(sellerProfileId);
      return Right(invitations);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, SellerInvitation>> acceptInvitation(
      String invitationId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      final invitation =
          await _remoteDataSource.acceptInvitation(invitationId);
      return Right(invitation);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, SellerInvitation>> rejectInvitation(
      String invitationId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      final invitation =
          await _remoteDataSource.rejectInvitation(invitationId);
      return Right(invitation);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> cancelInvitation(String invitationId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      await _remoteDataSource.cancelInvitation(invitationId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<SellerInvitation>>> getMyInvitations() async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      final invitations = await _remoteDataSource.getMyInvitations();
      return Right(invitations);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
