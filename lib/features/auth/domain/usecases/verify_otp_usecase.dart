import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Verify OTP code use case
/// Returns User if exists, null if new user needs registration

class VerifyOtpUseCase implements UseCase<User?, VerifyOtpParams> {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  @override
  Future<Either<Failure, User?>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(
      email: params.email,
      code: params.code,
    );
  }
}

class VerifyOtpParams extends Equatable {
  final String email;
  final String code;

  const VerifyOtpParams({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [email, code];
}
