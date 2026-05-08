import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../listing/domain/entities/listing.dart';
import '../../../seller/domain/entities/seller_profile.dart';
import '../../domain/entities/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, updating, deleted, error }

/// Tabs surfaced on the Instagram-style seller storefront. Buyer profiles
/// render a different layout entirely and ignore this enum.
enum SellerStorefrontTab { active, sold, about }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;

  /// `null` while the profile is loading, when the user is a buyer, or when
  /// the user is a seller-flagged account but the seller_profiles row hasn't
  /// loaded yet (in-flight or failed).
  final SellerProfile? sellerProfile;

  /// Listings owned by the current seller, split by status to match the
  /// storefront tabs. Empty list while the user is a buyer.
  final List<Listing> activeListings;
  final List<Listing> soldListings;

  /// Pagination cursors per tab. `1` means the first page is loaded;
  /// `hasMore` is `false` once the backend signals end-of-list.
  final int activePage;
  final int soldPage;
  final bool activeHasMore;
  final bool soldHasMore;
  final bool isLoadingMoreActive;
  final bool isLoadingMoreSold;

  final SellerStorefrontTab currentTab;
  final Failure? failure;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.sellerProfile,
    this.activeListings = const [],
    this.soldListings = const [],
    this.activePage = 1,
    this.soldPage = 1,
    this.activeHasMore = true,
    this.soldHasMore = true,
    this.isLoadingMoreActive = false,
    this.isLoadingMoreSold = false,
    this.currentTab = SellerStorefrontTab.active,
    this.failure,
  });

  bool get isLoading => status == ProfileStatus.loading;
  bool get isUpdating => status == ProfileStatus.updating;
  bool get hasError => status == ProfileStatus.error;
  bool get isDeleted => status == ProfileStatus.deleted;

  /// True when we should render the Instagram-style seller storefront.
  /// Requires both an `isSeller` UserProfile **and** a populated SellerProfile —
  /// otherwise we fall back to the buyer view (e.g. if the seller_profiles
  /// row 404s, render buyer view rather than a broken storefront).
  bool get isSellerView =>
      profile?.isSeller == true && sellerProfile != null;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    SellerProfile? sellerProfile,
    List<Listing>? activeListings,
    List<Listing>? soldListings,
    int? activePage,
    int? soldPage,
    bool? activeHasMore,
    bool? soldHasMore,
    bool? isLoadingMoreActive,
    bool? isLoadingMoreSold,
    SellerStorefrontTab? currentTab,
    Failure? failure,
    bool clearFailure = false,
    bool clearSellerProfile = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      sellerProfile:
          clearSellerProfile ? null : (sellerProfile ?? this.sellerProfile),
      activeListings: activeListings ?? this.activeListings,
      soldListings: soldListings ?? this.soldListings,
      activePage: activePage ?? this.activePage,
      soldPage: soldPage ?? this.soldPage,
      activeHasMore: activeHasMore ?? this.activeHasMore,
      soldHasMore: soldHasMore ?? this.soldHasMore,
      isLoadingMoreActive:
          isLoadingMoreActive ?? this.isLoadingMoreActive,
      isLoadingMoreSold: isLoadingMoreSold ?? this.isLoadingMoreSold,
      currentTab: currentTab ?? this.currentTab,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        sellerProfile,
        activeListings,
        soldListings,
        activePage,
        soldPage,
        activeHasMore,
        soldHasMore,
        isLoadingMoreActive,
        isLoadingMoreSold,
        currentTab,
        failure,
      ];
}
