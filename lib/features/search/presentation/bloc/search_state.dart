import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/filter.dart';
import '../../domain/entities/search_result.dart';

/// Search BLoC states

enum SearchStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
}

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final SearchFilter filter;
  final List<SearchResult> results;
  final List<String> suggestions;
  final List<String> recentSearches;
  final List<String> popularSearches;
  final List<BrandModel> brands;
  final List<CarModel> models;
  final int currentPage;
  final bool hasMore;
  final Failure? failure;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.filter = const SearchFilter(),
    this.results = const [],
    this.suggestions = const [],
    this.recentSearches = const [],
    this.popularSearches = const [],
    this.brands = const [],
    this.models = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.failure,
  });

  bool get isLoading => status == SearchStatus.loading;
  bool get isLoadingMore => status == SearchStatus.loadingMore;
  bool get hasError => status == SearchStatus.error;
  bool get isEmpty => results.isEmpty && status == SearchStatus.loaded;
  bool get hasResults => results.isNotEmpty;
  bool get hasActiveFilters => filter.hasActiveFilters;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    SearchFilter? filter,
    List<SearchResult>? results,
    List<String>? suggestions,
    List<String>? recentSearches,
    List<String>? popularSearches,
    List<BrandModel>? brands,
    List<CarModel>? models,
    int? currentPage,
    bool? hasMore,
    Failure? failure,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      results: results ?? this.results,
      suggestions: suggestions ?? this.suggestions,
      recentSearches: recentSearches ?? this.recentSearches,
      popularSearches: popularSearches ?? this.popularSearches,
      brands: brands ?? this.brands,
      models: models ?? this.models,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        query,
        filter,
        results,
        suggestions,
        recentSearches,
        popularSearches,
        brands,
        models,
        currentPage,
        hasMore,
        failure,
      ];
}
