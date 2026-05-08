import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Resend sign-up OTP use case

class ResendSignUpOtpUseCase implements UseCase<void, ResendSignUpOtpParams> {
  final AuthRepository _repository;

  ResendSignUpOtpUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ResendSignUpOtpParams params) {
    return _repository.resendSignUpOtp(email: params.email);
  }
}

class ResendSignUpOtpParams extends Equatable {
  final String email;

  const ResendSignUpOtpParams({required this.email});

  @override
  List<Object?> get props => [email];
}
