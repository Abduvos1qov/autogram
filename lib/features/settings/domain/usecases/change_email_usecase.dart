import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/account_repository.dart';

class RequestEmailChangeParams extends Equatable {
  final String newEmail;
  final String currentPassword;

  const RequestEmailChangeParams({
    required this.newEmail,
    required this.currentPassword,
  });

  @override
  List<Object?> get props => [newEmail, currentPassword];
}

class RequestEmailChangeUseCase implements UseCase<void, RequestEmailChangeParams> {
  final AccountRepository _repository;

  RequestEmailChangeUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RequestEmailChangeParams params) {
    return _repository.requestEmailChange(
      newEmail: params.newEmail,
      currentPassword: params.currentPassword,
    );
  }
}

class VerifyEmailChangeParams extends Equatable {
  final String newEmail;
  final String otp;

  const VerifyEmailChangeParams({
    required this.newEmail,
    required this.otp,
  });

  @override
  List<Object?> get props => [newEmail, otp];
}

class VerifyEmailChangeUseCase implements UseCase<void, VerifyEmailChangeParams> {
  final AccountRepository _repository;

  VerifyEmailChangeUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(VerifyEmailChangeParams params) {
    return _repository.verifyEmailChange(
      newEmail: params.newEmail,
      otp: params.otp,
    );
  }
}
