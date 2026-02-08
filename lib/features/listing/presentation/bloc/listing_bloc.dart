import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/repositories/listing_repository.dart';
import '../../domain/usecases/get_listing_usecase.dart';
import 'listing_event.dart';
import 'listing_state.dart';

/// Listing BLoC - manages listing detail state

class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final GetListingUseCase _getListingUseCase;
  final ListingRepository _repository;

  ListingBloc({
    required GetListingUseCase getListingUseCase,
    required ListingRepository repository,
  })  : _getListingUseCase = getListingUseCase,
        _repository = repository,
        super(const ListingState()) {
    on<ListingLoadRequested>(_onLoadRequested);
    on<ListingLikeToggled>(_onLikeToggled);
    on<ListingSaveToggled>(_onSaveToggled);
    on<ListingShareRequested>(_onShareRequested);
    on<ListingReportRequested>(_onReportRequested);
    on<ListingSimilarLoadRequested>(_onSimilarLoadRequested);
    on<ListingSellerFollowToggled>(_onSellerFollowToggled);
  }

  Future<void> _onLoadRequested(
    ListingLoadRequested event,
    Emitter<ListingState> emit,
  ) async {
    AppLogger.info('Loading listing: ${event.listingId}');
    emit(state.copyWith(status: ListingStatus.loading));

    final result = await _getListingUseCase(event.listingId);

    result.fold(
      (failure) {
        AppLogger.error('Failed to load listing: ${failure.message}');
        emit(state.copyWith(
          status: ListingStatus.error,
          failure: failure,
        ));
      },
      (listing) {
        AppLogger.info('Listing loaded: ${listing.title}');
        emit(state.copyWith(
          status: ListingStatus.loaded,
          listing: listing,
        ));

        // Record view
        _repository.recordView(listingId: event.listingId);

        // Load similar listings
        add(const ListingSimilarLoadRequested());
      },
    );
  }

  Future<void> _onLikeToggled(
    ListingLikeToggled event,
    Emitter<ListingState> emit,
  ) async {
    if (state.listing == null) return;

    final listing = state.listing!;
    final isLiked = !listing.isLiked;

    // Optimistic update
    emit(state.copyWith(
      listing: listing.copyWith(
        isLiked: isLiked,
        likesCount: isLiked ? listing.likesCount + 1 : listing.likesCount - 1,
      ),
    ));

    // API call
    final result = isLiked
        ? await _repository.likeListing(listing.id)
        : await _repository.unlikeListing(listing.id);

    result.fold(
      (failure) {
        AppLogger.error('Failed to toggle like: ${failure.message}');
        // Revert on error
        emit(state.copyWith(listing: listing));
      },
      (_) {
        AppLogger.info('Like toggled for ${listing.id}');
      },
    );
  }

  Future<void> _onSaveToggled(
    ListingSaveToggled event,
    Emitter<ListingState> emit,
  ) async {
    if (state.listing == null) return;

    final listing = state.listing!;
    final isSaved = !listing.isSaved;

    // Optimistic update
    emit(state.copyWith(
      listing: listing.copyWith(
        isSaved: isSaved,
        savesCount: isSaved ? listing.savesCount + 1 : listing.savesCount - 1,
      ),
    ));

    // API call
    final result = isSaved
        ? await _repository.saveListing(listing.id)
        : await _repository.unsaveListing(listing.id);

    result.fold(
      (failure) {
        AppLogger.error('Failed to toggle save: ${failure.message}');
        // Revert on error
        emit(state.copyWith(listing: listing));
      },
      (_) {
        AppLogger.info('Save toggled for ${listing.id}');
      },
    );
  }

  Future<void> _onShareRequested(
    ListingShareRequested event,
    Emitter<ListingState> emit,
  ) async {
    if (state.listing == null) return;

    await _repository.shareListing(state.listing!.id);

    emit(state.copyWith(
      listing: state.listing!.copyWith(
        sharesCount: state.listing!.sharesCount + 1,
      ),
    ));
  }

  Future<void> _onReportRequested(
    ListingReportRequested event,
    Emitter<ListingState> emit,
  ) async {
    if (state.listing == null) return;

    await _repository.reportListing(
      listingId: state.listing!.id,
      reason: event.reason,
      description: event.description,
    );
  }

  Future<void> _onSimilarLoadRequested(
    ListingSimilarLoadRequested event,
    Emitter<ListingState> emit,
  ) async {
    if (state.listing == null) return;

    emit(state.copyWith(isSimilarLoading: true));

    final result = await _repository.getSimilarListings(state.listing!.id);

    result.fold(
      (failure) {
        AppLogger.error('Failed to load similar: ${failure.message}');
        emit(state.copyWith(isSimilarLoading: false));
      },
      (listings) {
        emit(state.copyWith(
          similarListings: listings,
          isSimilarLoading: false,
        ));
      },
    );
  }

  Future<void> _onSellerFollowToggled(
    ListingSellerFollowToggled event,
    Emitter<ListingState> emit,
  ) async {
    if (state.listing == null) return;

    final seller = state.listing!.seller;
    final isFollowing = !seller.isFollowing;

    // API call (no optimistic update for seller object due to immutability complexity)
    final result = isFollowing
        ? await _repository.followSeller(seller.id)
        : await _repository.unfollowSeller(seller.id);

    result.fold(
      (failure) {
        AppLogger.error('Failed to toggle follow: ${failure.message}');
      },
      (_) {
        AppLogger.info('Follow toggled for seller ${seller.id}');
        // Reload listing to get updated seller info
        add(ListingLoadRequested(state.listing!.id));
      },
    );
  }
}
