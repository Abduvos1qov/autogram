import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Send password reset email use case

class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return _repository.resetPassword(email: params.email);
  }
}

class ResetPasswordParams extends Equatable {
  final String email;

  const ResetPasswordParams({required this.email});

  @override
  List<Object?> get props => [email];
}
