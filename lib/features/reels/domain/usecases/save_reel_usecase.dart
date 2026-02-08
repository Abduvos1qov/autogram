import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/reels_repository.dart';

/// Save/Unsave reel use case

class SaveReelUseCase implements UseCase<void, SaveReelParams> {
  final ReelsRepository _repository;

  SaveReelUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(SaveReelParams params) {
    if (params.isSaved) {
      return _repository.unsaveReel(params.reelId);
    } else {
      return _repository.saveReel(params.reelId);
    }
  }
}

class SaveReelParams extends Equatable {
  final String reelId;
  final bool isSaved;

  const SaveReelParams({
    required this.reelId,
    required this.isSaved,
  });

  @override
  List<Object?> get props => [reelId, isSaved];
}
