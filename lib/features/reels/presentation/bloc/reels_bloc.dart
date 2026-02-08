import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/reels_repository.dart';
import '../../domain/usecases/get_reels_usecase.dart';
import '../../domain/usecases/like_reel_usecase.dart';
import '../../domain/usecases/save_reel_usecase.dart';
import 'reels_event.dart';
import 'reels_state.dart';

/// Reels BLoC - manages reels state

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  final GetReelsUseCase _getReelsUseCase;
  final LikeReelUseCase _likeReelUseCase;
  final SaveReelUseCase _saveReelUseCase;
  final ReelsRepository _repository;

  ReelsBloc({
    required GetReelsUseCase getReelsUseCase,
    required LikeReelUseCase likeReelUseCase,
    required SaveReelUseCase saveReelUseCase,
    required ReelsRepository repository,
  })  : _getReelsUseCase = getReelsUseCase,
        _likeReelUseCase = likeReelUseCase,
        _saveReelUseCase = saveReelUseCase,
        _repository = repository,
        super(const ReelsState()) {
    on<ReelsLoadRequested>(_onLoadRequested);
    on<ReelsLoadMoreRequested>(_onLoadMoreRequested);
    on<ReelsCurrentChanged>(_onCurrentChanged);
    on<ReelsLikeToggled>(_onLikeToggled);
    on<ReelsSaveToggled>(_onSaveToggled);
    on<ReelsShareRequested>(_onShareRequested);
    on<ReelsViewRecorded>(_onViewRecorded);
  }

  Future<void> _onLoadRequested(
    ReelsLoadRequested event,
    Emitter<ReelsState> emit,
  ) async {
    if (state.status == ReelsStatus.loading) return;

    AppLogger.info('Loading reels');
    emit(state.copyWith(status: ReelsStatus.loading));

    final result = await _getReelsUseCase(
      const PaginationParams(page: 1, pageSize: AppConfig.reelsPageSize),
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to load reels: ${failure.message}');
        emit(state.copyWith(
          status: ReelsStatus.error,
          failure: failure,
        ));
      },
      (response) {
        AppLogger.info('Loaded ${response.data.length} reels');
        emit(state.copyWith(
          status: ReelsStatus.loaded,
          reels: response.data,
          hasMore: response.hasMore,
          currentPage: 1,
          currentIndex: 0,
        ));
      },
    );
  }

  Future<void> _onLoadMoreRequested(
    ReelsLoadMoreRequested event,
    Emitter<ReelsState> emit,
  ) async {
    if (state.status == ReelsStatus.loadingMore || !state.hasMore) return;

    AppLogger.info('Loading more reels');
    emit(state.copyWith(status: ReelsStatus.loadingMore));

    final nextPage = state.currentPage + 1;
    final result = await _getReelsUseCase(
      PaginationParams(page: nextPage, pageSize: AppConfig.reelsPageSize),
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to load more reels: ${failure.message}');
        emit(state.copyWith(status: ReelsStatus.loaded));
      },
      (response) {
        AppLogger.info('Loaded ${response.data.length} more reels');
        emit(state.copyWith(
          status: ReelsStatus.loaded,
          reels: [...state.reels, ...response.data],
          hasMore: response.hasMore,
          currentPage: nextPage,
        ));
      },
    );
  }

  void _onCurrentChanged(
    ReelsCurrentChanged event,
    Emitter<ReelsState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));

    // Check if we need to load more
    if (state.shouldLoadMore) {
      add(const ReelsLoadMoreRequested());
    }
  }

  Future<void> _onLikeToggled(
    ReelsLikeToggled event,
    Emitter<ReelsState> emit,
  ) async {
    final reelIndex = state.reels.indexWhere((r) => r.id == event.reelId);
    if (reelIndex == -1) return;

    final reel = state.reels[reelIndex];
    final isLiked = !reel.isLiked;

    // Optimistic update
    final updatedReels = List.of(state.reels);
    updatedReels[reelIndex] = reel.copyWith(
      isLiked: isLiked,
      likesCount: isLiked ? reel.likesCount + 1 : reel.likesCount - 1,
    );
    emit(state.copyWith(reels: updatedReels));

    // API call
    final result = await _likeReelUseCase(
      LikeReelParams(reelId: event.reelId, isLiked: reel.isLiked),
    );

    result.fold(
      (failure) {
        // Revert on error
        AppLogger.error('Failed to toggle like: ${failure.message}');
        final revertedReels = List.of(state.reels);
        revertedReels[reelIndex] = reel;
        emit(state.copyWith(reels: revertedReels));
      },
      (_) {
        AppLogger.info('Like toggled for ${event.reelId}');
      },
    );
  }

  Future<void> _onSaveToggled(
    ReelsSaveToggled event,
    Emitter<ReelsState> emit,
  ) async {
    final reelIndex = state.reels.indexWhere((r) => r.id == event.reelId);
    if (reelIndex == -1) return;

    final reel = state.reels[reelIndex];
    final isSaved = !reel.isSaved;

    // Optimistic update
    final updatedReels = List.of(state.reels);
    updatedReels[reelIndex] = reel.copyWith(
      isSaved: isSaved,
      savesCount: isSaved ? reel.savesCount + 1 : reel.savesCount - 1,
    );
    emit(state.copyWith(reels: updatedReels));

    // API call
    final result = await _saveReelUseCase(
      SaveReelParams(reelId: event.reelId, isSaved: reel.isSaved),
    );

    result.fold(
      (failure) {
        // Revert on error
        AppLogger.error('Failed to toggle save: ${failure.message}');
        final revertedReels = List.of(state.reels);
        revertedReels[reelIndex] = reel;
        emit(state.copyWith(reels: revertedReels));
      },
      (_) {
        AppLogger.info('Save toggled for ${event.reelId}');
      },
    );
  }

  Future<void> _onShareRequested(
    ReelsShareRequested event,
    Emitter<ReelsState> emit,
  ) async {
    await _repository.shareReel(event.reelId);

    final reelIndex = state.reels.indexWhere((r) => r.id == event.reelId);
    if (reelIndex != -1) {
      final reel = state.reels[reelIndex];
      final updatedReels = List.of(state.reels);
      updatedReels[reelIndex] = reel.copyWith(
        sharesCount: reel.sharesCount + 1,
      );
      emit(state.copyWith(reels: updatedReels));
    }
  }

  Future<void> _onViewRecorded(
    ReelsViewRecorded event,
    Emitter<ReelsState> emit,
  ) async {
    await _repository.recordView(
      reelId: event.reelId,
      duration: event.duration,
    );
  }
}
