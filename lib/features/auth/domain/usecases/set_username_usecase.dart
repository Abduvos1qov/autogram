import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Set username for current user use case

class SetUsernameUseCase implements UseCase<User, SetUsernameParams> {
  final AuthRepository _repository;

  SetUsernameUseCase(this._repository);

  @override
  Future<Either<Failure, User>> call(SetUsernameParams params) {
    return _repository.setUsername(username: params.username);
  }
}

class SetUsernameParams extends Equatable {
  final String username;

  const SetUsernameParams({required this.username});

  @override
  List<Object?> get props => [username];
}
