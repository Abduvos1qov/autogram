import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileParams extends Equatable {
  final String? fullName;
  final String? email;
  final String? username;
  final String? language;

  const UpdateProfileParams({
    this.fullName,
    this.email,
    this.username,
    this.language,
  });

  @override
  List<Object?> get props => [fullName, email, username, language];
}

class UpdateProfileUseCase implements UseCase<UserProfile, UpdateProfileParams> {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      fullName: params.fullName,
      email: params.email,
      username: params.username,
      language: params.language,
    );
  }
}
