import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Send forgot password OTP use case

class SendForgotPasswordOtpUseCase
    implements UseCase<void, SendForgotPasswordOtpParams> {
  final AuthRepository _repository;

  SendForgotPasswordOtpUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(SendForgotPasswordOtpParams params) {
    return _repository.sendForgotPasswordOtp(email: params.email);
  }
}

class SendForgotPasswordOtpParams extends Equatable {
  final String email;

  const SendForgotPasswordOtpParams({required this.email});

  @override
  List<Object?> get props => [email];
}
