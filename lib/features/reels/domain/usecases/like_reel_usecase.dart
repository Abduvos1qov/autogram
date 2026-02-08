import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/reels_repository.dart';

/// Like/Unlike reel use case

class LikeReelUseCase implements UseCase<void, LikeReelParams> {
  final ReelsRepository _repository;

  LikeReelUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(LikeReelParams params) {
    if (params.isLiked) {
      return _repository.unlikeReel(params.reelId);
    } else {
      return _repository.likeReel(params.reelId);
    }
  }
}

class LikeReelParams extends Equatable {
  final String reelId;
  final bool isLiked;

  const LikeReelParams({
    required this.reelId,
    required this.isLiked,
  });

  @override
  List<Object?> get props => [reelId, isLiked];
}
