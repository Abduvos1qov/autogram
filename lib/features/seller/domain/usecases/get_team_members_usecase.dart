import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_member.dart';
import '../repositories/seller_member_repository.dart';

/// Get all team members for a seller organization

class GetTeamMembersUseCase
    implements UseCase<List<SellerMember>, IdParams> {
  final SellerMemberRepository _repository;

  GetTeamMembersUseCase(this._repository);

  @override
  Future<Either<Failure, List<SellerMember>>> call(IdParams params) {
    return _repository.getTeamMembers(params.id);
  }
}
