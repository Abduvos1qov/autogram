import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Sign in with email and password use case

class SignInUseCase implements UseCase<User, SignInParams> {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) {
    return _repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
