import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../listing/domain/entities/listing.dart';
import '../../../reels/domain/entities/reel.dart';
import '../../../seller/domain/entities/seller_profile.dart';
import '../../domain/entities/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, updating, deleted, error }

/// Tabs surfaced on the Instagram-style seller storefront. Buyer profiles
/// render a different layout entirely and ignore this enum.
enum SellerStorefrontTab { active, reels, sold }

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

  /// Reels (video listings) owned by the current seller, populated only for
  /// sellers. Empty list for buyers.
  final List<Reel> reels;

  /// Pagination cursors per tab. `1` means the first page is loaded;
  /// `hasMore` is `false` once the backend signals end-of-list.
  final int activePage;
  final int soldPage;
  final int reelsPage;
  final bool activeHasMore;
  final bool soldHasMore;
  final bool reelsHasMore;
  final bool isLoadingMoreActive;
  final bool isLoadingMoreSold;
  final bool isLoadingMoreReels;

  final SellerStorefrontTab currentTab;
  final Failure? failure;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.sellerProfile,
    this.activeListings = const [],
    this.soldListings = const [],
    this.reels = const [],
    this.activePage = 1,
    this.soldPage = 1,
    this.reelsPage = 1,
    this.activeHasMore = true,
    this.soldHasMore = true,
    this.reelsHasMore = true,
    this.isLoadingMoreActive = false,
    this.isLoadingMoreSold = false,
    this.isLoadingMoreReels = false,
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
    List<Reel>? reels,
    int? activePage,
    int? soldPage,
    int? reelsPage,
    bool? activeHasMore,
    bool? soldHasMore,
    bool? reelsHasMore,
    bool? isLoadingMoreActive,
    bool? isLoadingMoreSold,
    bool? isLoadingMoreReels,
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
      reels: reels ?? this.reels,
      activePage: activePage ?? this.activePage,
      soldPage: soldPage ?? this.soldPage,
      reelsPage: reelsPage ?? this.reelsPage,
      activeHasMore: activeHasMore ?? this.activeHasMore,
      soldHasMore: soldHasMore ?? this.soldHasMore,
      reelsHasMore: reelsHasMore ?? this.reelsHasMore,
      isLoadingMoreActive:
          isLoadingMoreActive ?? this.isLoadingMoreActive,
      isLoadingMoreSold: isLoadingMoreSold ?? this.isLoadingMoreSold,
      isLoadingMoreReels: isLoadingMoreReels ?? this.isLoadingMoreReels,
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
        reels,
        activePage,
        soldPage,
        reelsPage,
        activeHasMore,
        soldHasMore,
        reelsHasMore,
        isLoadingMoreActive,
        isLoadingMoreSold,
        isLoadingMoreReels,
        currentTab,
        failure,
      ];
}
