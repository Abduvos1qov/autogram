import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Check if username is available use case

class CheckUsernameUseCase implements UseCase<bool, CheckUsernameParams> {
  final AuthRepository _repository;

  CheckUsernameUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(CheckUsernameParams params) {
    return _repository.checkUsernameAvailability(username: params.username);
  }
}

class CheckUsernameParams extends Equatable {
  final String username;

  const CheckUsernameParams({required this.username});

  @override
  List<Object?> get props => [username];
}
