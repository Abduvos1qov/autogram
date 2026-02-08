import 'package:equatable/equatable.dart';

/// Listing BLoC events

sealed class ListingEvent extends Equatable {
  const ListingEvent();

  @override
  List<Object?> get props => [];
}

/// Load listing details
class ListingLoadRequested extends ListingEvent {
  final String listingId;

  const ListingLoadRequested(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

/// Toggle like on listing
class ListingLikeToggled extends ListingEvent {
  const ListingLikeToggled();
}

/// Toggle save on listing
class ListingSaveToggled extends ListingEvent {
  const ListingSaveToggled();
}

/// Share listing
class ListingShareRequested extends ListingEvent {
  const ListingShareRequested();
}

/// Report listing
class ListingReportRequested extends ListingEvent {
  final String reason;
  final String? description;

  const ListingReportRequested({
    required this.reason,
    this.description,
  });

  @override
  List<Object?> get props => [reason, description];
}

/// Load similar listings
class ListingSimilarLoadRequested extends ListingEvent {
  const ListingSimilarLoadRequested();
}

/// Follow seller
class ListingSellerFollowToggled extends ListingEvent {
  const ListingSellerFollowToggled();
}
