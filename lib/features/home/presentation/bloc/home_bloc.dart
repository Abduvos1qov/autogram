import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Home BLoC - manages home feed state

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetFeedUseCase _getFeedUseCase;
  final HomeRepository _repository;

  HomeBloc({
    required GetFeedUseCase getFeedUseCase,
    required HomeRepository repository,
  })  : _getFeedUseCase = getFeedUseCase,
        _repository = repository,
        super(const HomeState()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeLoadMoreRequested>(_onLoadMoreRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomeLikeToggled>(_onLikeToggled);
    on<HomeSaveToggled>(_onSaveToggled);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.status == HomeStatus.loading) return;

    AppLogger.info('Loading home feed');
    emit(state.copyWith(status: HomeStatus.loading));

    final result = await _getFeedUseCase(
      const PaginationParams(page: 1, pageSize: AppConfig.defaultPageSize),
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to load feed: ${failure.message}');
        emit(state.copyWith(
          status: HomeStatus.error,
          failure: failure,
        ));
      },
      (response) {
        AppLogger.info('Loaded ${response.data.length} feed items');
        emit(state.copyWith(
          status: HomeStatus.loaded,
          items: response.data,
          hasMore: response.hasMore,
          currentPage: 1,
        ));
      },
    );
  }

  Future<void> _onLoadMoreRequested(
    HomeLoadMoreRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.status == HomeStatus.loadingMore || !state.hasMore) return;

    AppLogger.info('Loading more feed items');
    emit(state.copyWith(status: HomeStatus.loadingMore));

    final nextPage = state.currentPage + 1;
    final result = await _getFeedUseCase(
      PaginationParams(page: nextPage, pageSize: AppConfig.defaultPageSize),
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to load more: ${failure.message}');
        emit(state.copyWith(status: HomeStatus.loaded));
      },
      (response) {
        AppLogger.info('Loaded ${response.data.length} more items');
        emit(state.copyWith(
          status: HomeStatus.loaded,
          items: [...state.items, ...response.data],
          hasMore: response.hasMore,
          currentPage: nextPage,
        ));
      },
    );
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    AppLogger.info('Refreshing home feed');

    final result = await _getFeedUseCase(
      const PaginationParams(page: 1, pageSize: AppConfig.defaultPageSize),
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to refresh feed: ${failure.message}');
        emit(state.copyWith(failure: failure));
      },
      (response) {
        AppLogger.info('Refreshed ${response.data.length} feed items');
        emit(state.copyWith(
          status: HomeStatus.loaded,
          items: response.data,
          hasMore: response.hasMore,
          currentPage: 1,
        ));
      },
    );
  }

  Future<void> _onLikeToggled(
    HomeLikeToggled event,
    Emitter<HomeState> emit,
  ) async {
    final itemIndex = state.items.indexWhere((i) => i.id == event.listingId);
    if (itemIndex == -1) return;

    final item = state.items[itemIndex];
    final isLiked = !item.isLiked;

    // Optimistic update
    final updatedItems = List.of(state.items);
    updatedItems[itemIndex] = item.copyWith(
      isLiked: isLiked,
      likesCount: isLiked ? item.likesCount + 1 : item.likesCount - 1,
    );
    emit(state.copyWith(items: updatedItems));

    // API call
    final result = isLiked
        ? await _repository.likeListing(event.listingId)
        : await _repository.unlikeListing(event.listingId);

    result.fold(
      (failure) {
        // Revert on error
        AppLogger.error('Failed to toggle like: ${failure.message}');
        final revertedItems = List.of(state.items);
        revertedItems[itemIndex] = item;
        emit(state.copyWith(items: revertedItems));
      },
      (_) {
        AppLogger.info('Like toggled for ${event.listingId}');
      },
    );
  }

  Future<void> _onSaveToggled(
    HomeSaveToggled event,
    Emitter<HomeState> emit,
  ) async {
    final itemIndex = state.items.indexWhere((i) => i.id == event.listingId);
    if (itemIndex == -1) return;

    final item = state.items[itemIndex];
    final isSaved = !item.isSaved;

    // Optimistic update
    final updatedItems = List.of(state.items);
    updatedItems[itemIndex] = item.copyWith(
      isSaved: isSaved,
      savesCount: isSaved ? item.savesCount + 1 : item.savesCount - 1,
    );
    emit(state.copyWith(items: updatedItems));

    // API call
    final result = isSaved
        ? await _repository.saveListing(event.listingId)
        : await _repository.unsaveListing(event.listingId);

    result.fold(
      (failure) {
        // Revert on error
        AppLogger.error('Failed to toggle save: ${failure.message}');
        final revertedItems = List.of(state.items);
        revertedItems[itemIndex] = item;
        emit(state.copyWith(items: revertedItems));
      },
      (_) {
        AppLogger.info('Save toggled for ${event.listingId}');
      },
    );
  }
}
