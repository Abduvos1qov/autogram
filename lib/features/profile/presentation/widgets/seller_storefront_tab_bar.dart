import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/profile_state.dart';

/// Sticky tab bar — designed for use inside a `SliverPersistentHeader(pinned: true)`.
/// Renders three icon-only tabs (Active | Reels | Sold) Instagram-style.
/// The active tab gets a 2px primary-color underline.
class SellerStorefrontTabBar extends StatelessWidget {
  final SellerStorefrontTab currentTab;
  final ValueChanged<SellerStorefrontTab> onTabChanged;

  const SellerStorefrontTabBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceOf(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _TabButton(
                  icon: Icons.grid_on_rounded,
                  isActive: currentTab == SellerStorefrontTab.active,
                  onTap: () => onTabChanged(SellerStorefrontTab.active),
                ),
              ),
              Expanded(
                child: _TabButton(
                  icon: Icons.play_circle_outline_rounded,
                  isActive: currentTab == SellerStorefrontTab.reels,
                  onTap: () => onTabChanged(SellerStorefrontTab.reels),
                ),
              ),
              Expanded(
                child: _TabButton(
                  icon: Icons.sell_outlined,
                  isActive: currentTab == SellerStorefrontTab.sold,
                  onTap: () => onTabChanged(SellerStorefrontTab.sold),
                ),
              ),
            ],
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.dividerOf(context),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primaryOf(context);
    final inactiveColor = AppColors.textTertiaryOf(context);
    final color = isActive ? activeColor : inactiveColor;

    return Semantics(
      button: true,
      selected: isActive,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 26, color: color),
                if (isActive)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: activeColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pinned-header delegate that hosts [SellerStorefrontTabBar].
class SellerStorefrontTabBarDelegate extends SliverPersistentHeaderDelegate {
  final SellerStorefrontTabBar tabBar;

  SellerStorefrontTabBarDelegate({required this.tabBar});

  static const double height = 49;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return tabBar;
  }

  @override
  bool shouldRebuild(SellerStorefrontTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}
