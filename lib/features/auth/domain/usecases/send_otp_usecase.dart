import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Send OTP to email use case

class SendOtpUseCase implements UseCase<void, SendOtpParams> {
  final AuthRepository _repository;

  SendOtpUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(SendOtpParams params) {
    return _repository.sendOtp(email: params.email);
  }
}

class SendOtpParams extends Equatable {
  final String email;

  const SendOtpParams({required this.email});

  @override
  List<Object?> get props => [email];
}
