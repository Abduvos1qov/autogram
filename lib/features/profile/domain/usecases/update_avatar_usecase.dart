import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateAvatarParams extends Equatable {
  final File imageFile;

  const UpdateAvatarParams(this.imageFile);

  @override
  List<Object?> get props => [imageFile.path];
}

class UpdateAvatarUseCase implements UseCase<String, UpdateAvatarParams> {
  final ProfileRepository _repository;

  UpdateAvatarUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call(UpdateAvatarParams params) {
    return _repository.updateAvatar(params.imageFile);
  }
}
