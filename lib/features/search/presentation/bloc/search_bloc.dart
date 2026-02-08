import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import '../../domain/usecases/search_listings_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

/// Search BLoC - manages search state

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchListingsUseCase _searchListingsUseCase;
  final GetBrandsUseCase _getBrandsUseCase;
  final SearchRepository _repository;

  SearchBloc({
    required SearchListingsUseCase searchListingsUseCase,
    required GetBrandsUseCase getBrandsUseCase,
    required SearchRepository repository,
  })  : _searchListingsUseCase = searchListingsUseCase,
        _getBrandsUseCase = getBrandsUseCase,
        _repository = repository,
        super(const SearchState()) {
    on<SearchInitialized>(_onInitialized);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchSubmitted>(_onSubmitted);
    on<SearchLoadMore>(_onLoadMore);
    on<SearchFilterChanged>(_onFilterChanged);
    on<SearchFilterCleared>(_onFilterCleared);
    on<SearchBrandSelected>(_onBrandSelected);
    on<SearchRecentCleared>(_onRecentCleared);
    on<SearchSortChanged>(_onSortChanged);
  }

  Future<void> _onInitialized(
    SearchInitialized event,
    Emitter<SearchState> emit,
  ) async {
    AppLogger.info('Initializing search');

    // Load brands, recent searches, and popular searches in parallel
    final brandsResult = await _getBrandsUseCase(const NoParams());
    final recentResult = await _repository.getRecentSearches();
    final popularResult = await _repository.getPopularSearches();

    emit(state.copyWith(
      brands: brandsResult.fold((_) => [], (brands) => brands),
      recentSearches: recentResult.fold((_) => [], (searches) => searches),
      popularSearches: popularResult.fold((_) => [], (searches) => searches),
    ));
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(query: event.query));

    if (event.query.length >= 2) {
      final result = await _repository.getSuggestions(event.query);
      result.fold(
        (_) {},
        (suggestions) => emit(state.copyWith(suggestions: suggestions)),
      );
    } else {
      emit(state.copyWith(suggestions: []));
    }
  }

  Future<void> _onSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query ?? state.query;
    if (state.status == SearchStatus.loading) return;

    AppLogger.info('Searching for: $query');
    emit(state.copyWith(
      status: SearchStatus.loading,
      query: query,
      currentPage: 1,
    ));

    final result = await _searchListingsUseCase(
      SearchParams(
        query: query.isEmpty ? null : query,
        filter: state.filter,
        page: 1,
        pageSize: AppConfig.searchPageSize,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error('Search failed: ${failure.message}');
        emit(state.copyWith(
          status: SearchStatus.error,
          failure: failure,
        ));
      },
      (response) {
        AppLogger.info('Found ${response.data.length} results');
        emit(state.copyWith(
          status: SearchStatus.loaded,
          results: response.data,
          hasMore: response.hasMore,
          currentPage: 1,
        ));
      },
    );
  }

  Future<void> _onLoadMore(
    SearchLoadMore event,
    Emitter<SearchState> emit,
  ) async {
    if (state.status == SearchStatus.loadingMore || !state.hasMore) return;

    AppLogger.info('Loading more search results');
    emit(state.copyWith(status: SearchStatus.loadingMore));

    final nextPage = state.currentPage + 1;
    final result = await _searchListingsUseCase(
      SearchParams(
        query: state.query.isEmpty ? null : state.query,
        filter: state.filter,
        page: nextPage,
        pageSize: AppConfig.searchPageSize,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error('Load more failed: ${failure.message}');
        emit(state.copyWith(status: SearchStatus.loaded));
      },
      (response) {
        AppLogger.info('Loaded ${response.data.length} more results');
        emit(state.copyWith(
          status: SearchStatus.loaded,
          results: [...state.results, ...response.data],
          hasMore: response.hasMore,
          currentPage: nextPage,
        ));
      },
    );
  }

  Future<void> _onFilterChanged(
    SearchFilterChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter));

    // Re-search with new filter
    add(const SearchSubmitted());
  }

  Future<void> _onFilterCleared(
    SearchFilterCleared event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(filter: state.filter.clear()));

    // Re-search without filter
    add(const SearchSubmitted());
  }

  Future<void> _onBrandSelected(
    SearchBrandSelected event,
    Emitter<SearchState> emit,
  ) async {
    AppLogger.info('Loading models for brand: ${event.brandId}');

    final result = await _repository.getModels(event.brandId);

    result.fold(
      (failure) {
        AppLogger.error('Failed to load models: ${failure.message}');
      },
      (models) {
        emit(state.copyWith(models: models));
      },
    );
  }

  Future<void> _onRecentCleared(
    SearchRecentCleared event,
    Emitter<SearchState> emit,
  ) async {
    await _repository.clearRecentSearches();
    emit(state.copyWith(recentSearches: []));
  }

  Future<void> _onSortChanged(
    SearchSortChanged event,
    Emitter<SearchState> emit,
  ) async {
    final newFilter = state.filter.copyWith(sortBy: event.sortOption);
    add(SearchFilterChanged(newFilter));
  }
}