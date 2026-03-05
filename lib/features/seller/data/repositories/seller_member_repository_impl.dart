import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/permission_service.dart';
import '../../domain/entities/seller_member.dart';
import '../../domain/repositories/seller_member_repository.dart';
import '../datasources/seller_member_remote_datasource.dart';

/// Seller member repository implementation

class SellerMemberRepositoryImpl implements SellerMemberRepository {
  final SellerMemberRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  SellerMemberRepositoryImpl({
    required SellerMemberRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<SellerMember>>> getTeamMembers(
      String sellerProfileId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      final members =
          await _remoteDataSource.getTeamMembers(sellerProfileId);
      return Right(members);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, SellerMember?>> getMemberByUserId(
    String sellerProfileId,
    String userId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      final member =
          await _remoteDataSource.getMemberByUserId(sellerProfileId, userId);
      return Right(member);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, SellerMember>> addMember({
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
      final member = await _remoteDataSource.addMember(
        sellerProfileId: sellerProfileId,
        email: email,
        role: role,
      );
      return Right(member);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, SellerMember>> updateMemberRole({
    required String memberId,
    required MemberRole role,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      final member = await _remoteDataSource.updateMemberRole(
        memberId: memberId,
        role: role,
      );
      return Right(member);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(String memberId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      await _remoteDataSource.removeMember(memberId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, SellerMember?>> getCurrentMembership() async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet aloqasi yo\'q'),
      );
    }
    try {
      final member = await _remoteDataSource.getCurrentMembership();
      return Right(member);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
