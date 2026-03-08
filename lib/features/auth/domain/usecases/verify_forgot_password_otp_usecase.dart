import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Verify OTP code for forgot password flow

class VerifyForgotPasswordOtpUseCase
    implements UseCase<void, VerifyForgotPasswordOtpParams> {
  final AuthRepository _repository;

  VerifyForgotPasswordOtpUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(VerifyForgotPasswordOtpParams params) {
    return _repository.verifyForgotPasswordOtp(
      email: params.email,
      otp: params.otp,
    );
  }
}

class VerifyForgotPasswordOtpParams extends Equatable {
  final String email;
  final String otp;

  const VerifyForgotPasswordOtpParams({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}
