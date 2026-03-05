import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_member.dart';
import '../repositories/seller_member_repository.dart';

/// Add a new member to a seller organization

class AddMemberUseCase implements UseCase<SellerMember, AddMemberParams> {
  final SellerMemberRepository _repository;

  AddMemberUseCase(this._repository);

  @override
  Future<Either<Failure, SellerMember>> call(AddMemberParams params) {
    return _repository.addMember(
      sellerProfileId: params.sellerProfileId,
      email: params.email,
      role: params.role,
    );
  }
}

class AddMemberParams extends Equatable {
  final String sellerProfileId;
  final String email;
  final MemberRole role;

  const AddMemberParams({
    required this.sellerProfileId,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [sellerProfileId, email, role];
}
