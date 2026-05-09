import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/empty_view.dart';
import '../../../../navigation/route_names.dart';
import '../../../listing/domain/entities/listing.dart';
import '../../../reels/domain/entities/reel.dart';
import '../../../seller/domain/entities/seller_profile.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/listing_grid_tile.dart';
import '../widgets/seller_storefront_tab_bar.dart';
import '../widgets/storefront/storefront_action_row.dart';
import '../widgets/storefront/storefront_create_sheet.dart';
import '../widgets/storefront/storefront_identity_block.dart';
import '../widgets/storefront/storefront_reels_grid_tile.dart';
import '../widgets/storefront/storefront_top_bar.dart';

/// Instagram-profile-style seller storefront. Wires the top bar, identity
/// block (avatar + 4 stats), action row, sticky 3-icon tab bar, and the per-
/// tab content slivers (active grid | reels grid | sold grid) into a single
/// `CustomScrollView`. The right-side hamburger pushes the
/// `StorefrontMenuScreen` as a full route — we deliberately do NOT use
/// `Scaffold.endDrawer`, because that auto-injects a *second* hamburger into
/// the SliverAppBar's actions area on top of the manual one inside
/// [StorefrontTopBar].
class SellerStorefrontView extends StatefulWidget {
  final UserProfile user;
  final SellerProfile seller;

  const SellerStorefrontView({
    super.key,
    required this.user,
    required this.seller,
  });

  @override
  State<SellerStorefrontView> createState() => _SellerStorefrontViewState();
}

class _SellerStorefrontViewState extends State<SellerStorefrontView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<ProfileBloc>().add(const ProfileLoadMoreListings());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
      child: Scaffold(
        backgroundColor: AppColors.surfaceOf(context),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          buildWhen: (prev, curr) =>
              prev.activeListings != curr.activeListings ||
              prev.soldListings != curr.soldListings ||
              prev.reels != curr.reels ||
              prev.currentTab != curr.currentTab ||
              prev.isLoadingMoreActive != curr.isLoadingMoreActive ||
              prev.isLoadingMoreSold != curr.isLoadingMoreSold ||
              prev.isLoadingMoreReels != curr.isLoadingMoreReels ||
              prev.activeHasMore != curr.activeHasMore ||
              prev.soldHasMore != curr.soldHasMore ||
              prev.reelsHasMore != curr.reelsHasMore ||
              prev.sellerProfile != curr.sellerProfile,
          builder: (context, state) {
            final seller = state.sellerProfile ?? widget.seller;

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<ProfileBloc>();
                bloc.add(const ProfileRefreshRequested());
                await bloc.stream.firstWhere(
                  (s) =>
                      s.status == ProfileStatus.loaded ||
                      s.status == ProfileStatus.error,
                );
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    snap: false,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    backgroundColor: AppColors.surfaceOf(context),
                    surfaceTintColor: AppColors.surfaceOf(context),
                    automaticallyImplyLeading: false,
                    titleSpacing: 0,
                    centerTitle: false,
                    title: StorefrontTopBar(
                      businessName: seller.businessName,
                      isVerified: seller.isVerified,
                      createTooltip:
                          'profile.storefront.top_bar.create_tooltip'.tr(),
                      notificationsTooltip:
                          'profile.storefront.top_bar.notifications_tooltip'
                              .tr(),
                      menuTooltip:
                          'profile.storefront.top_bar.menu_tooltip'.tr(),
                      onCreate: () => _showCreateSheet(context, seller),
                      onNotifications: () =>
                          context.push(RoutePaths.notifications),
                      onMenu: () => context.push(
                        RoutePaths.storefrontMenu,
                        extra: <String, Object?>{
                          'profile': widget.user,
                          'seller': seller,
                        },
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(0.5),
                      child: Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: AppColors.dividerOf(context),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: StorefrontIdentityBlock(
                      seller: seller,
                      displayName: widget.user.fullName,
                      listingsCount: seller.stats.activeListings,
                      followersCount: seller.stats.followersCount,
                      soldCount: seller.stats.totalSold,
                      rating: seller.stats.avgRating,
                      listingsLabel:
                          'seller.storefront.stats.listings'.tr(),
                      followersLabel:
                          'seller.storefront.stats.followers'.tr(),
                      soldLabel: 'seller.storefront.stats.sold'.tr(),
                      ratingLabel:
                          'seller.storefront.stats.rating'.tr(),
                      verifiedTooltip:
                          'seller.storefront.verified_tooltip'.tr(),
                      onListingsTap: () => _switchTab(
                        context,
                        SellerStorefrontTab.active,
                      ),
                      onFollowersTap: () => _toast(
                        context,
                        'profile.storefront.followers_coming_soon'.tr(),
                      ),
                      onSoldTap: () => _switchTab(
                        context,
                        SellerStorefrontTab.sold,
                      ),
                      onRatingTap: () => _toast(
                        context,
                        'profile.storefront.drawer.reviews_coming_soon'.tr(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: StorefrontActionRow(
                      editProfileLabel: 'profile.edit'.tr(),
                      shareProfileLabel:
                          'seller.storefront.actions.share_profile'.tr(),
                      aboutTooltip:
                          'profile.storefront.action_row.about_tooltip'.tr(),
                      onEditProfile: () => context.push(RoutePaths.editProfile),
                      onShareProfile: () => _onShare(context, seller),
                      onAbout: () => context.push(RoutePaths.aboutSeller),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SellerStorefrontTabBarDelegate(
                      tabBar: SellerStorefrontTabBar(
                        currentTab: state.currentTab,
                        onTabChanged: (tab) {
                          HapticFeedback.selectionClick();
                          context
                              .read<ProfileBloc>()
                              .add(ProfileTabChanged(tab));
                        },
                      ),
                    ),
                  ),
                  ..._buildTabContent(context, state, seller),
                  const SliverToBoxAdapter(child: SizedBox(height: 96)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _switchTab(BuildContext context, SellerStorefrontTab tab) {
    HapticFeedback.selectionClick();
    context.read<ProfileBloc>().add(ProfileTabChanged(tab));
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Widget> _buildTabContent(
    BuildContext context,
    ProfileState state,
    SellerProfile seller,
  ) {
    switch (state.currentTab) {
      case SellerStorefrontTab.active:
        return _buildListingsGrid(
          context,
          listings: state.activeListings,
          isLoadingMore: state.isLoadingMoreActive,
          hasMore: state.activeHasMore,
          emptyIcon: Icons.directions_car_outlined,
          emptyTitle: 'seller.storefront.empty.active_title'.tr(),
          emptyMessage: 'seller.storefront.empty.active_message'.tr(),
          emptyCta: seller.canPostListings
              ? 'seller.storefront.empty.active_cta'.tr()
              : null,
          onEmptyCta: seller.canPostListings
              ? () => _showCreateSheet(context, seller)
              : null,
        );
      case SellerStorefrontTab.reels:
        return _buildReelsGrid(
          context,
          reels: state.reels,
          isLoadingMore: state.isLoadingMoreReels,
          hasMore: state.reelsHasMore,
        );
      case SellerStorefrontTab.sold:
        return _buildListingsGrid(
          context,
          listings: state.soldListings,
          isLoadingMore: state.isLoadingMoreSold,
          hasMore: state.soldHasMore,
          emptyIcon: Icons.local_offer_outlined,
          emptyTitle: 'seller.storefront.empty.sold_title'.tr(),
          emptyMessage: 'seller.storefront.empty.sold_message'.tr(),
          emptyCta: null,
          onEmptyCta: null,
        );
    }
  }

  List<Widget> _buildListingsGrid(
    BuildContext context, {
    required List<Listing> listings,
    required bool isLoadingMore,
    required bool hasMore,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptyMessage,
    String? emptyCta,
    VoidCallback? onEmptyCta,
  }) {
    if (listings.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: EmptyView(
              icon: emptyIcon,
              title: emptyTitle,
              message: emptyMessage,
              actionText: emptyCta,
              onAction: onEmptyCta,
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(2),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final listing = listings[index];
              return ListingGridTile(
                listing: listing,
                onTap: () => context.push('/listing/${listing.id}'),
              );
            },
            childCount: listings.length,
          ),
        ),
      ),
      _buildPaginationFooter(context, isLoadingMore, hasMore),
    ];
  }

  List<Widget> _buildReelsGrid(
    BuildContext context, {
    required List<Reel> reels,
    required bool isLoadingMore,
    required bool hasMore,
  }) {
    if (reels.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: EmptyView(
              icon: Icons.play_circle_outline_rounded,
              title: 'profile.storefront.empty.reels_title'.tr(),
              message: 'profile.storefront.empty.reels_message'.tr(),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(2),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final reel = reels[index];
              return StorefrontReelsGridTile(
                reel: reel,
                onTap: () => context.push('/listing/${reel.id}'),
              );
            },
            childCount: reels.length,
          ),
        ),
      ),
      _buildPaginationFooter(context, isLoadingMore, hasMore),
    ];
  }

  Widget _buildPaginationFooter(
    BuildContext context,
    bool isLoadingMore,
    bool hasMore,
  ) {
    if (isLoadingMore) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }
    if (!hasMore) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Container(
              width: 32,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.dividerOf(context),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  void _showCreateSheet(BuildContext context, SellerProfile seller) {
    StorefrontCreateSheet.show(
      context,
      onNewListingDisabled: () {
        if (!seller.canPostListings) {
          _toast(
            context,
            'profile.storefront.plan_limit_reached'.tr(),
          );
        } else {
          _toast(
            context,
            'profile.storefront.create_sheet.new_listing_coming_soon'.tr(),
          );
        }
      },
      onBoost: () => context.push(RoutePaths.boost),
      onShareProfile: () => _onShare(context, seller),
      onEditProfile: () => context.push(RoutePaths.editProfile),
    );
  }

  Future<void> _onShare(
    BuildContext context,
    SellerProfile seller,
  ) async {
    // No native share sheet integration yet (share_plus not in pubspec) —
    // copy to clipboard with a confirmation snackbar so users can paste.
    final message = 'seller.storefront.share_message'.tr(
      namedArgs: {'name': seller.businessName},
    );
    final payload = '$message\nautogram://seller/${seller.id}';
    await Clipboard.setData(ClipboardData(text: payload));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'profile.storefront.share_clipboard_toast'.tr(),
          style: AppTypography.bodyMedium(context),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
