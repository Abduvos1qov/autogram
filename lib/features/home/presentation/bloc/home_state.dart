import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/feed_item.dart';

/// Home BLoC states

enum HomeStatus { initial, loading, loaded, loadingMore, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<FeedItem> items;
  final bool hasMore;
  final int currentPage;
  final Failure? failure;

  const HomeState({
    this.status = HomeStatus.initial,
    this.items = const [],
    this.hasMore = true,
    this.currentPage = 1,
    this.failure,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<FeedItem>? items,
    bool? hasMore,
    int? currentPage,
    Failure? failure,
  }) {
    return HomeState(
      status: status ?? this.status,
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      failure: failure,
    );
  }

  bool get isLoading => status == HomeStatus.loading;
  bool get isLoadingMore => status == HomeStatus.loadingMore;
  bool get hasError => status == HomeStatus.error;
  bool get isEmpty => items.isEmpty && status == HomeStatus.loaded;

  @override
  List<Object?> get props => [status, items, hasMore, currentPage, failure];
}
