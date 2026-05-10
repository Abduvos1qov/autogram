import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../../listing/domain/entities/listing.dart';
import '../../../listing/domain/usecases/get_seller_listings_usecase.dart';
import '../../../reels/domain/entities/reel.dart';
import '../../../reels/domain/usecases/get_seller_reels_usecase.dart';
import '../../../seller/domain/entities/seller_profile.dart';
import '../../../seller/domain/usecases/get_seller_profile_usecase.dart';
import '../../../seller/domain/usecases/update_seller_profile_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Default page size for storefront listing pagination — chosen to fill 4–5
/// rows of the 3-column grid before the user has to scroll for more.
const int _kListingsPageSize = 12;

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdateAvatarUseCase _updateAvatarUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final GetSellerProfileUseCase _getSellerProfileUseCase;
  final GetSellerListingsUseCase _getSellerListingsUseCase;
  final GetSellerReelsUseCase _getSellerReelsUseCase;
  final UpdateSellerProfileUseCase _updateSellerProfileUseCase;

  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UpdateAvatarUseCase updateAvatarUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required GetSellerProfileUseCase getSellerProfileUseCase,
    required GetSellerListingsUseCase getSellerListingsUseCase,
    required GetSellerReelsUseCase getSellerReelsUseCase,
    required UpdateSellerProfileUseCase updateSellerProfileUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _updateAvatarUseCase = updateAvatarUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        _getSellerProfileUseCase = getSellerProfileUseCase,
        _getSellerListingsUseCase = getSellerListingsUseCase,
        _getSellerReelsUseCase = getSellerReelsUseCase,
        _updateSellerProfileUseCase = updateSellerProfileUseCase,
        super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileRefreshRequested>(_onRefreshRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileAvatarUpdateRequested>(_onAvatarUpdateRequested);
    on<ProfileDeleteRequested>(_onDeleteRequested);
    on<ProfileTabChanged>(_onTabChanged);
    on<ProfileLoadMoreListings>(_onLoadMoreListings);
    on<ProfileSellerInfoUpdateRequested>(_onSellerInfoUpdateRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.info('Loading profile');
    emit(state.copyWith(status: ProfileStatus.loading, clearFailure: true));
    await _loadAll(emit);
  }

  Future<void> _onRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.info('Refreshing profile');
    // Toggle to `loading` so the state stream is guaranteed to emit. Without
    // this, mock-data refreshes (where every field of the new state equals
    // the old one) emit nothing and the RefreshIndicator's `firstWhere`
    // await never resolves. ProfileScreen's loading-view guard checks
    // `profile == null` so the existing data stays on screen during the
    // intermediate `loading` state.
    emit(state.copyWith(status: ProfileStatus.loading, clearFailure: true));
    await _loadAll(emit);
  }

  Future<void> _loadAll(Emitter<ProfileState> emit) async {
    final profileResult = await _getProfileUseCase(const NoParams());

    final profile = profileResult.fold(
      (failure) {
        AppLogger.error('Failed to load profile: ${failure.message}');
        emit(state.copyWith(
          status: ProfileStatus.error,
          failure: failure,
        ));
        return null;
      },
      (p) => p,
    );

    if (profile == null) return;

    final sellerId = profile.sellerProfileId;
    if (!profile.isSeller || sellerId == null) {
      // Buyer flow (or `role=seller` with a missing FK — treated the same so
      // we never show a broken storefront). Clear any leftover storefront
      // data so a downgrade from seller → buyer doesn't leak stale state.
      if (profile.isSeller && sellerId == null) {
        AppLogger.warning(
          'Seller flag set but sellerProfileId is null — falling back to buyer view',
        );
      }
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        clearSellerProfile: true,
        activeListings: const [],
        soldListings: const [],
        reels: const [],
        activePage: 1,
        soldPage: 1,
        reelsPage: 1,
        activeHasMore: true,
        soldHasMore: true,
        reelsHasMore: true,
      ));
      return;
    }

    // Seller flow — fan out four calls in parallel via `Future.wait` so
    // total latency is `max(s, a, s, r)` rather than `s + a + s + r`.
    final results = await Future.wait([
      _getSellerProfileUseCase(const NoParams()),
      _getSellerListingsUseCase(GetSellerListingsParams(
        sellerId: sellerId,
        page: 1,
        pageSize: _kListingsPageSize,
        status: ListingStatus.active,
      )),
      _getSellerListingsUseCase(GetSellerListingsParams(
        sellerId: sellerId,
        page: 1,
        pageSize: _kListingsPageSize,
        status: ListingStatus.sold,
      )),
      _getSellerReelsUseCase(GetSellerReelsParams(
        sellerId: sellerId,
        page: 1,
        pageSize: _kListingsPageSize,
      )),
    ]);

    final sellerResult =
        results[0] as Either<Failure, SellerProfile?>;
    final activeResult =
        results[1] as Either<Failure, PaginatedResponse<Listing>>;
    final soldResult =
        results[2] as Either<Failure, PaginatedResponse<Listing>>;
    final reelsResult =
        results[3] as Either<Failure, PaginatedResponse<Reel>>;

    SellerProfile? sellerProfile;
    sellerResult.fold(
      (failure) {
        AppLogger.warning(
          'Seller profile fetch failed: ${failure.message} — falling back to buyer view',
        );
      },
      (sp) {
        sellerProfile = sp;
      },
    );

    List<Listing> active = const [];
    bool activeHasMore = false;
    activeResult.fold(
      (failure) {
        AppLogger.warning('Active listings load failed: ${failure.message}');
      },
      (response) {
        active = response.data;
        activeHasMore = response.hasMore;
      },
    );

    List<Listing> sold = const [];
    bool soldHasMore = false;
    soldResult.fold(
      (failure) {
        AppLogger.warning('Sold listings load failed: ${failure.message}');
      },
      (response) {
        sold = response.data;
        soldHasMore = response.hasMore;
      },
    );

    List<Reel> reels = const [];
    bool reelsHasMore = false;
    reelsResult.fold(
      (failure) {
        AppLogger.warning('Seller reels load failed: ${failure.message}');
      },
      (response) {
        reels = response.data;
        reelsHasMore = response.hasMore;
      },
    );

    emit(state.copyWith(
      status: ProfileStatus.loaded,
      profile: profile,
      sellerProfile: sellerProfile,
      clearSellerProfile: sellerProfile == null,
      activeListings: active,
      soldListings: sold,
      reels: reels,
      activePage: 1,
      soldPage: 1,
      reelsPage: 1,
      activeHasMore: activeHasMore,
      soldHasMore: soldHasMore,
      reelsHasMore: reelsHasMore,
      isLoadingMoreActive: false,
      isLoadingMoreSold: false,
      isLoadingMoreReels: false,
    ));
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.info('Updating profile');
    emit(state.copyWith(status: ProfileStatus.updating, clearFailure: true));

    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        fullName: event.fullName,
        email: event.email,
        username: event.username,
        language: event.language,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to update profile: ${failure.message}');
        emit(state.copyWith(
          status: ProfileStatus.error,
          failure: failure,
        ));
      },
      (profile) {
        AppLogger.info('Profile updated');
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
        ));
      },
    );
  }

  Future<void> _onSellerInfoUpdateRequested(
    ProfileSellerInfoUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (!event.hasChanges) return;
    if (state.sellerProfile == null) {
      // Buyer or seller-flagged user without a SellerProfile row — nothing
      // to update; silently no-op so the UI doesn't have to gate the
      // dispatch.
      AppLogger.warning(
        'Seller info update requested without a SellerProfile — ignoring',
      );
      return;
    }

    AppLogger.info('Updating seller profile (social/bio)');
    emit(state.copyWith(status: ProfileStatus.updating, clearFailure: true));

    final result = await _updateSellerProfileUseCase(
      UpdateSellerProfileParams(
        username: event.username,
        description: event.description,
        website: event.website,
        telegram: event.telegram,
        instagram: event.instagram,
        facebook: event.facebook,
        youtube: event.youtube,
        address: event.address,
        city: event.city,
        district: event.district,
        contactPersonName: event.contactPersonName,
        contactPersonRole: event.contactPersonRole,
        contactPhones: event.contactPhones,
        workingHours: event.workingHours,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'Failed to update seller profile: ${failure.message}',
        );
        emit(state.copyWith(
          status: ProfileStatus.error,
          failure: failure,
        ));
      },
      (sellerProfile) {
        AppLogger.info('Seller profile updated');
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          sellerProfile: sellerProfile,
        ));
      },
    );
  }

  Future<void> _onAvatarUpdateRequested(
    ProfileAvatarUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.info('Updating avatar');
    emit(state.copyWith(status: ProfileStatus.updating, clearFailure: true));

    final result = await _updateAvatarUseCase(
      UpdateAvatarParams(event.imageFile),
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to update avatar: ${failure.message}');
        emit(state.copyWith(
          status: ProfileStatus.error,
          failure: failure,
        ));
      },
      (avatarUrl) {
        AppLogger.info('Avatar updated');
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          profile: state.profile?.copyWith(avatarUrl: avatarUrl),
        ));
      },
    );
  }

  Future<void> _onDeleteRequested(
    ProfileDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.info('Deleting account');
    emit(state.copyWith(status: ProfileStatus.updating, clearFailure: true));

    final result = await _deleteAccountUseCase(const NoParams());

    result.fold(
      (failure) {
        AppLogger.error('Failed to delete account: ${failure.message}');
        emit(state.copyWith(
          status: ProfileStatus.error,
          failure: failure,
        ));
      },
      (_) {
        AppLogger.info('Account deleted');
        // Emit `deleted` so the UI layer knows to navigate to login. The
        // datasource has already called `auth.signOut()` on the live
        // SupabaseClient, which in turn fires the `AuthBloc` listener and
        // transitions to `AuthUnauthenticated`. The router redirect picks
        // it up and pushes to `/login`. **Load-bearing assumption:** the
        // `deleteAccount` datasource MUST sign out the Supabase session,
        // not just clear local storage; otherwise the auth listener never
        // fires.
        emit(state.copyWith(status: ProfileStatus.deleted));
      },
    );
  }

  void _onTabChanged(
    ProfileTabChanged event,
    Emitter<ProfileState> emit,
  ) {
    if (event.tab == state.currentTab) return;
    emit(state.copyWith(currentTab: event.tab));
  }

  Future<void> _onLoadMoreListings(
    ProfileLoadMoreListings event,
    Emitter<ProfileState> emit,
  ) async {
    final profile = state.profile;
    final sellerId = profile?.sellerProfileId;
    if (profile == null || sellerId == null) return;

    switch (state.currentTab) {
      case SellerStorefrontTab.active:
        await _loadMoreListings(
          emit,
          sellerId: sellerId,
          status: ListingStatus.active,
        );
        return;
      case SellerStorefrontTab.sold:
        await _loadMoreListings(
          emit,
          sellerId: sellerId,
          status: ListingStatus.sold,
        );
        return;
      case SellerStorefrontTab.reels:
        await _loadMoreReels(emit, sellerId: sellerId);
        return;
    }
  }

  Future<void> _loadMoreListings(
    Emitter<ProfileState> emit, {
    required String sellerId,
    required ListingStatus status,
  }) async {
    final isActive = status == ListingStatus.active;
    final hasMore = isActive ? state.activeHasMore : state.soldHasMore;
    final isLoading =
        isActive ? state.isLoadingMoreActive : state.isLoadingMoreSold;

    if (!hasMore || isLoading) return;

    final nextPage = (isActive ? state.activePage : state.soldPage) + 1;

    emit(state.copyWith(
      isLoadingMoreActive: isActive ? true : state.isLoadingMoreActive,
      isLoadingMoreSold: !isActive ? true : state.isLoadingMoreSold,
    ));

    final result = await _getSellerListingsUseCase(
      GetSellerListingsParams(
        sellerId: sellerId,
        page: nextPage,
        pageSize: _kListingsPageSize,
        status: status,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.warning(
          'Load more (${status.name}) failed: ${failure.message}',
        );
        emit(state.copyWith(
          isLoadingMoreActive: isActive ? false : state.isLoadingMoreActive,
          isLoadingMoreSold: !isActive ? false : state.isLoadingMoreSold,
        ));
      },
      (response) {
        if (isActive) {
          emit(state.copyWith(
            activeListings: [...state.activeListings, ...response.data],
            activePage: nextPage,
            activeHasMore: response.hasMore,
            isLoadingMoreActive: false,
          ));
        } else {
          emit(state.copyWith(
            soldListings: [...state.soldListings, ...response.data],
            soldPage: nextPage,
            soldHasMore: response.hasMore,
            isLoadingMoreSold: false,
          ));
        }
      },
    );
  }

  Future<void> _loadMoreReels(
    Emitter<ProfileState> emit, {
    required String sellerId,
  }) async {
    if (!state.reelsHasMore || state.isLoadingMoreReels) return;

    final nextPage = state.reelsPage + 1;
    emit(state.copyWith(isLoadingMoreReels: true));

    final result = await _getSellerReelsUseCase(
      GetSellerReelsParams(
        sellerId: sellerId,
        page: nextPage,
        pageSize: _kListingsPageSize,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.warning('Load more reels failed: ${failure.message}');
        emit(state.copyWith(isLoadingMoreReels: false));
      },
      (response) {
        emit(state.copyWith(
          reels: [...state.reels, ...response.data],
          reelsPage: nextPage,
          reelsHasMore: response.hasMore,
          isLoadingMoreReels: false,
        ));
      },
    );
  }
}
