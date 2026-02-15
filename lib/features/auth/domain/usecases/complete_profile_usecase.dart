import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Complete profile after OTP verification use case

class CompleteProfileUseCase implements UseCase<User, CompleteProfileParams> {
  final AuthRepository _repository;

  CompleteProfileUseCase(this._repository);

  @override
  Future<Either<Failure, User>> call(CompleteProfileParams params) {
    return _repository.completeProfile(
      fullName: params.fullName,
      phone: params.phone,
    );
  }
}

class CompleteProfileParams extends Equatable {
  final String fullName;
  final String? phone;

  const CompleteProfileParams({
    required this.fullName,
    this.phone,
  });

  @override
  List<Object?> get props => [fullName, phone];
}
