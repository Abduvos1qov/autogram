import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_member.dart';
import '../repositories/seller_member_repository.dart';

/// Update a member's role within a seller organization

class UpdateMemberRoleUseCase
    implements UseCase<SellerMember, UpdateMemberRoleParams> {
  final SellerMemberRepository _repository;

  UpdateMemberRoleUseCase(this._repository);

  @override
  Future<Either<Failure, SellerMember>> call(
      UpdateMemberRoleParams params) {
    return _repository.updateMemberRole(
      memberId: params.memberId,
      role: params.role,
    );
  }
}

class UpdateMemberRoleParams extends Equatable {
  final String memberId;
  final MemberRole role;

  const UpdateMemberRoleParams({
    required this.memberId,
    required this.role,
  });

  @override
  List<Object?> get props => [memberId, role];
}
