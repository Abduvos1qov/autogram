import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/profile_state.dart';

/// Sticky tab bar — designed for use inside a `SliverPersistentHeader(pinned: true)`.
/// Renders three icon-only tabs (Active | Sold | About) Instagram-style, with
/// an optional numeric count next to the active/sold icons. The active tab
/// gets a 2px underline.
class SellerStorefrontTabBar extends StatelessWidget {
  final SellerStorefrontTab currentTab;
  final ValueChanged<SellerStorefrontTab> onTabChanged;
  final int? activeCount;
  final int? soldCount;

  const SellerStorefrontTabBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    this.activeCount,
    this.soldCount,
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
                  count: activeCount,
                  onTap: () => onTabChanged(SellerStorefrontTab.active),
                ),
              ),
              Expanded(
                child: _TabButton(
                  icon: Icons.sell_outlined,
                  isActive: currentTab == SellerStorefrontTab.sold,
                  count: soldCount,
                  onTap: () => onTabChanged(SellerStorefrontTab.sold),
                ),
              ),
              Expanded(
                child: _TabButton(
                  icon: Icons.info_outline_rounded,
                  isActive: currentTab == SellerStorefrontTab.about,
                  count: null,
                  onTap: () => onTabChanged(SellerStorefrontTab.about),
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
  final int? count;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.isActive,
    required this.count,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: color),
                    if (count != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '$count',
                        style: AppTypography.labelMediumStyle.copyWith(
                          color: color,
                          fontWeight: isActive
                              ? AppTypography.bold
                              : AppTypography.medium,
                        ),
                      ),
                    ],
                  ],
                ),
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
