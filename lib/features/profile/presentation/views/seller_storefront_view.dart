import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/empty_view.dart';
import '../../../../navigation/route_names.dart';
import '../../../listing/domain/entities/listing.dart';
import '../../../seller/domain/entities/seller_profile.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/listing_grid_tile.dart';
import '../widgets/seller_cover_header.dart';
import '../widgets/seller_storefront_about.dart';
import '../widgets/seller_storefront_actions.dart';
import '../widgets/seller_storefront_stats.dart';
import '../widgets/seller_storefront_tab_bar.dart';

/// Instagram-style seller storefront view. Wires the cover, identity block,
/// stats, action buttons, sticky tab bar, and tab content together using a
/// `CustomScrollView` of slivers.
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
  bool _isCoverInView = true;

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
    // Trigger pagination when within 400px of the bottom — keeps the grid
    // populated as the user scrolls without aggressive refetching.
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<ProfileBloc>().add(const ProfileLoadMoreListings());
    }

    // Toggle status bar icon brightness once we scroll past the cover.
    final coverThreshold = 200 - kToolbarHeight;
    final inView = position.pixels < coverThreshold;
    if (inView != _isCoverInView) {
      setState(() => _isCoverInView = inView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isCoverInView
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (prev, curr) =>
            prev.activeListings != curr.activeListings ||
            prev.soldListings != curr.soldListings ||
            prev.currentTab != curr.currentTab ||
            prev.isLoadingMoreActive != curr.isLoadingMoreActive ||
            prev.isLoadingMoreSold != curr.isLoadingMoreSold ||
            prev.activeHasMore != curr.activeHasMore ||
            prev.soldHasMore != curr.soldHasMore ||
            prev.sellerProfile != curr.sellerProfile,
        builder: (context, state) {
          final seller = state.sellerProfile ?? widget.seller;

          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<ProfileBloc>();
              bloc.add(const ProfileRefreshRequested());
              await bloc.stream.firstWhere(
                (s) => s.status == ProfileStatus.loaded ||
                    s.status == ProfileStatus.error,
              );
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildCoverSliver(context, seller),
                SliverToBoxAdapter(
                  child: _BusinessIdentityBlock(seller: seller),
                ),
                SliverToBoxAdapter(
                  child: SellerStorefrontStats(stats: seller.stats),
                ),
                SliverToBoxAdapter(
                  child: SellerStorefrontActions(
                    onEditProfile: () => context.push(RoutePaths.editProfile),
                    onShareProfile: () => _onShare(seller),
                    onBoost: () => context.push(RoutePaths.boost),
                    onTeam: () => context.push(
                      RoutePaths.teamMembers,
                      extra: seller.id,
                    ),
                    onSubscription: () => context.push(RoutePaths.upgrade),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SellerStorefrontTabBarDelegate(
                    tabBar: SellerStorefrontTabBar(
                      currentTab: state.currentTab,
                      activeCount: state.activeListings.length,
                      soldCount: state.soldListings.length,
                      onTabChanged: (tab) {
                        HapticFeedback.selectionClick();
                        context.read<ProfileBloc>().add(ProfileTabChanged(tab));
                      },
                    ),
                  ),
                ),
                ..._buildTabContent(context, state, seller),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 96),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoverSliver(BuildContext context, SellerProfile seller) {
    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SellerCoverHeader(seller: seller),
          // Settings overflow button — top-right of cover.
          Positioned(
            top: 8 + MediaQuery.of(context).padding.top,
            right: AppSpacing.md + 80,
            child: _CircleIconButton(
              icon: Icons.settings_outlined,
              onTap: () => _showMoreOptions(context, seller),
              tooltip: 'profile.settings'.tr(),
            ),
          ),
        ],
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
          emptyTitle: 'seller.storefront.empty.active_title'.tr(),
          emptyMessage: 'seller.storefront.empty.active_message'.tr(),
          emptyCta: 'seller.storefront.empty.active_cta'.tr(),
          onEmptyCta: () => context.push(RoutePaths.upgrade),
        );
      case SellerStorefrontTab.sold:
        return _buildListingsGrid(
          context,
          listings: state.soldListings,
          isLoadingMore: state.isLoadingMoreSold,
          hasMore: state.soldHasMore,
          emptyTitle: 'seller.storefront.empty.sold_title'.tr(),
          emptyMessage: 'seller.storefront.empty.sold_message'.tr(),
          emptyCta: null,
          onEmptyCta: null,
        );
      case SellerStorefrontTab.about:
        return [
          SliverPadding(
            padding: EdgeInsets.zero,
            sliver: SliverToBoxAdapter(
              child: SellerStorefrontAbout(
                seller: seller,
                onPhoneTap: (phone) => _launch('tel:$phone'),
                onTelegramTap: (handle) => _launch(
                  'https://t.me/${handle.replaceAll('@', '')}',
                ),
                onInstagramTap: (handle) => _launch(
                  'https://instagram.com/${handle.replaceAll('@', '')}',
                ),
                onWebsiteTap: (url) => _launch(
                  url.startsWith('http') ? url : 'https://$url',
                ),
              ),
            ),
          ),
        ];
    }
  }

  List<Widget> _buildListingsGrid(
    BuildContext context, {
    required List<Listing> listings,
    required bool isLoadingMore,
    required bool hasMore,
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
              icon: Icons.directions_car_outlined,
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
                onTap: () =>
                    context.push('/listing/${listing.id}'),
              );
            },
            childCount: listings.length,
          ),
        ),
      ),
      if (isLoadingMore)
        const SliverToBoxAdapter(
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
        )
      else if (!hasMore)
        SliverToBoxAdapter(
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
        ),
    ];
  }

  Future<void> _onShare(SellerProfile seller) async {
    // No native share sheet integration yet (share_plus not in pubspec) — fall
    // back to copy-to-clipboard with feedback so users can paste anywhere.
    final message = 'seller.storefront.share_message'.tr(
      namedArgs: {'name': seller.businessName},
    );
    final payload = '$message\nautogram://seller/${seller.id}';
    await Clipboard.setData(ClipboardData(text: payload));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('seller.storefront.actions.share_profile'.tr()),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showMoreOptions(BuildContext context, SellerProfile seller) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _SheetTile(
                icon: Icons.edit_outlined,
                label: 'profile.edit'.tr(),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push(RoutePaths.editProfile);
                },
              ),
              _SheetTile(
                icon: Icons.event_seat_outlined,
                label: 'profile.seat_management'.tr(),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push(RoutePaths.seatManagement);
                },
              ),
              _SheetTile(
                icon: Icons.notifications_outlined,
                label: 'profile.notification_settings'.tr(),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push(RoutePaths.notificationSettings);
                },
              ),
              _SheetTile(
                icon: Icons.help_outline,
                label: 'profile.help_center'.tr(),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push(RoutePaths.help);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _BusinessIdentityBlock extends StatelessWidget {
  final SellerProfile seller;

  const _BusinessIdentityBlock({required this.seller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  seller.businessName,
                  style: AppTypography.headlineMedium(context).copyWith(
                    fontWeight: AppTypography.bold,
                    height: 1.2,
                  ),
                ),
              ),
              if (seller.isVerified) ...[
                const SizedBox(width: 6),
                Tooltip(
                  message: 'seller.storefront.verified_tooltip'.tr(),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: AppColors.verifiedColor,
                    size: 22,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            seller.businessType.labelKey.tr(),
            style: AppTypography.bodySmall(context).copyWith(
              color: AppColors.textSecondaryOf(context),
              fontWeight: AppTypography.medium,
            ),
          ),
          if (seller.description != null && seller.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ExpandableBio(text: seller.description!),
          ],
          if (seller.city != null || seller.address != null) ...[
            const SizedBox(height: 8),
            _AddressLine(
              address: seller.address,
              city: seller.city,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpandableBio extends StatefulWidget {
  final String text;

  const _ExpandableBio({required this.text});

  @override
  State<_ExpandableBio> createState() => _ExpandableBioState();
}

class _ExpandableBioState extends State<_ExpandableBio> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.bodyMedium(context).copyWith(height: 1.4);
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _expanded = !_expanded),
        child: Text(
          widget.text,
          style: style,
          maxLines: _expanded ? null : 3,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _AddressLine extends StatelessWidget {
  final String? address;
  final String? city;

  const _AddressLine({required this.address, required this.city});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (parts.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 14,
          color: AppColors.textSecondaryOf(context),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            parts.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall(context),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.black.withValues(alpha: 0.32),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: AppColors.white,
            size: 18,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimaryOf(context)),
      title: Text(
        label,
        style: AppTypography.bodyLarge(context),
      ),
      onTap: onTap,
    );
  }
}
