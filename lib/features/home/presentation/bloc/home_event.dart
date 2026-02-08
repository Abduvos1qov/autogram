import 'package:equatable/equatable.dart';

/// Home BLoC events

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial feed
class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

/// Load more feed items
class HomeLoadMoreRequested extends HomeEvent {
  const HomeLoadMoreRequested();
}

/// Refresh feed
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

/// Like a listing
class HomeLikeToggled extends HomeEvent {
  final String listingId;

  const HomeLikeToggled(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

/// Save a listing
class HomeSaveToggled extends HomeEvent {
  final String listingId;

  const HomeSaveToggled(this.listingId);

  @override
  List<Object?> get props => [listingId];
}
