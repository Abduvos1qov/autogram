import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Register new user use case

class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) {
    return _repository.register(
      phone: params.phone,
      fullName: params.fullName,
      email: params.email,
    );
  }
}

class RegisterParams extends Equatable {
  final String phone;
  final String fullName;
  final String? email;

  const RegisterParams({
    required this.phone,
    required this.fullName,
    this.email,
  });

  @override
  List<Object?> get props => [phone, fullName, email];
}
