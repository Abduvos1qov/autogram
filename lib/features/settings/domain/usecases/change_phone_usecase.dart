import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/account_repository.dart';

class RequestPhoneChangeParams extends Equatable {
  final String newPhone;
  final String currentPassword;

  const RequestPhoneChangeParams({
    required this.newPhone,
    required this.currentPassword,
  });

  @override
  List<Object?> get props => [newPhone, currentPassword];
}

class RequestPhoneChangeUseCase implements UseCase<void, RequestPhoneChangeParams> {
  final AccountRepository _repository;

  RequestPhoneChangeUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RequestPhoneChangeParams params) {
    return _repository.requestPhoneChange(
      newPhone: params.newPhone,
      currentPassword: params.currentPassword,
    );
  }
}

class VerifyPhoneChangeParams extends Equatable {
  final String newPhone;
  final String otp;

  const VerifyPhoneChangeParams({
    required this.newPhone,
    required this.otp,
  });

  @override
  List<Object?> get props => [newPhone, otp];
}

class VerifyPhoneChangeUseCase implements UseCase<void, VerifyPhoneChangeParams> {
  final AccountRepository _repository;

  VerifyPhoneChangeUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(VerifyPhoneChangeParams params) {
    return _repository.verifyPhoneChange(
      newPhone: params.newPhone,
      otp: params.otp,
    );
  }
}
