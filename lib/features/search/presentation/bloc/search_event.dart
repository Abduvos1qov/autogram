import 'package:equatable/equatable.dart';

import '../../domain/entities/filter.dart';

/// Search BLoC events

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load event
class SearchInitialized extends SearchEvent {
  const SearchInitialized();
}

/// Search query changed
class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Execute search
class SearchSubmitted extends SearchEvent {
  final String? query;

  const SearchSubmitted({this.query});

  @override
  List<Object?> get props => [query];
}

/// Load more results
class SearchLoadMore extends SearchEvent {
  const SearchLoadMore();
}

/// Filter changed
class SearchFilterChanged extends SearchEvent {
  final SearchFilter filter;

  const SearchFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Filter cleared
class SearchFilterCleared extends SearchEvent {
  const SearchFilterCleared();
}

/// Brand selected - load models
class SearchBrandSelected extends SearchEvent {
  final String brandId;

  const SearchBrandSelected(this.brandId);

  @override
  List<Object?> get props => [brandId];
}

/// Clear recent searches
class SearchRecentCleared extends SearchEvent {
  const SearchRecentCleared();
}

/// Sort option changed
class SearchSortChanged extends SearchEvent {
  final SortOption sortOption;

  const SearchSortChanged(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}
