import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/repository_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/permission_service.dart';
import '../../domain/entities/seller_member.dart';
import '../../domain/repositories/seller_member_repository.dart';
import '../datasources/seller_member_remote_datasource.dart';

/// Seller member repository implementation

class SellerMemberRepositoryImpl
    with RepositoryMixin
    implements SellerMemberRepository {
  final SellerMemberRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  SellerMemberRepositoryImpl({
    required SellerMemberRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<SellerMember>>> getTeamMembers(
          String sellerProfileId) =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.getTeamMembers(sellerProfileId);
      });

  @override
  Future<Either<Failure, SellerMember?>> getMemberByUserId(
    String sellerProfileId,
    String userId,
  ) =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.getMemberByUserId(
            sellerProfileId, userId);
      });

  @override
  Future<Either<Failure, SellerMember>> addMember({
    required String sellerProfileId,
    required String email,
    required MemberRole role,
  }) =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.addMember(
          sellerProfileId: sellerProfileId,
          email: email,
          role: role,
        );
      });

  @override
  Future<Either<Failure, SellerMember>> updateMemberRole({
    required String memberId,
    required MemberRole role,
  }) =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.updateMemberRole(
          memberId: memberId,
          role: role,
        );
      });

  @override
  Future<Either<Failure, void>> removeMember(String memberId) =>
      safeRemoteCall(_networkInfo, () async {
        await _remoteDataSource.removeMember(memberId);
      });

  @override
  Future<Either<Failure, SellerMember?>> getCurrentMembership() =>
      safeRemoteCall(_networkInfo, () async {
        return await _remoteDataSource.getCurrentMembership();
      });
}
