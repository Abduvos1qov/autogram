import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Reset password with new password after OTP verification

class ResetPasswordWithNewUseCase
    implements UseCase<void, ResetPasswordWithNewParams> {
  final AuthRepository _repository;

  ResetPasswordWithNewUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordWithNewParams params) {
    return _repository.resetPasswordWithNew(
      email: params.email,
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordWithNewParams extends Equatable {
  final String email;
  final String newPassword;

  const ResetPasswordWithNewParams({
    required this.email,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, newPassword];
}
