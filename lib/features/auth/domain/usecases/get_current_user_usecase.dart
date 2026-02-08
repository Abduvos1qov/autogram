import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Get current authenticated user use case

class GetCurrentUserUseCase implements NoParamsUseCase<User?> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<Either<Failure, User?>> call() {
    return _repository.getCurrentUser();
  }
}
