import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Send OTP to phone number use case

class SendOtpUseCase implements UseCase<void, SendOtpParams> {
  final AuthRepository _repository;

  SendOtpUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(SendOtpParams params) {
    return _repository.sendOtp(params.phone);
  }
}

class SendOtpParams extends Equatable {
  final String phone;

  const SendOtpParams({required this.phone});

  @override
  List<Object?> get props => [phone];
}
