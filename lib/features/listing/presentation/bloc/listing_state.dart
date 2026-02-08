import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/listing.dart';

/// Listing BLoC states

enum ListingStatus {
  initial,
  loading,
  loaded,
  error,
}

class ListingState extends Equatable {
  final ListingStatus status;
  final Listing? listing;
  final List<Listing> similarListings;
  final bool isSimilarLoading;
  final Failure? failure;

  const ListingState({
    this.status = ListingStatus.initial,
    this.listing,
    this.similarListings = const [],
    this.isSimilarLoading = false,
    this.failure,
  });

  bool get isLoading => status == ListingStatus.loading;
  bool get hasError => status == ListingStatus.error;
  bool get isLoaded => status == ListingStatus.loaded;

  ListingState copyWith({
    ListingStatus? status,
    Listing? listing,
    List<Listing>? similarListings,
    bool? isSimilarLoading,
    Failure? failure,
  }) {
    return ListingState(
      status: status ?? this.status,
      listing: listing ?? this.listing,
      similarListings: similarListings ?? this.similarListings,
      isSimilarLoading: isSimilarLoading ?? this.isSimilarLoading,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        listing,
        similarListings,
        isSimilarLoading,
        failure,
      ];
}
