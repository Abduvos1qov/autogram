import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Flat IG-style top bar shown at the top of the seller storefront.
/// Designed to live inside `SliverAppBar(pinned: true)`.
///
/// Left zone: `+` icon → opens create-content sheet.
/// Center: business name + verified icon + dropdown chevron (decorative).
/// Right zone: notifications bell, hamburger.
class StorefrontTopBar extends StatelessWidget {
  final String businessName;
  final bool isVerified;
  final bool hasUnreadNotifications;
  final String? createTooltip;
  final String? notificationsTooltip;
  final String? menuTooltip;
  final VoidCallback onCreate;
  final VoidCallback onNotifications;
  final VoidCallback onMenu;

  const StorefrontTopBar({
    super.key,
    required this.businessName,
    required this.isVerified,
    required this.onCreate,
    required this.onNotifications,
    required this.onMenu,
    this.hasUnreadNotifications = false,
    this.createTooltip,
    this.notificationsTooltip,
    this.menuTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          _TopBarIconButton(
            icon: Icons.add_box_outlined,
            onTap: onCreate,
            tooltip: createTooltip,
          ),
          Expanded(
            child: Center(
              child: _CenterTitle(
                businessName: businessName,
                isVerified: isVerified,
              ),
            ),
          ),
          _TopBarIconButton(
            icon: Icons.notifications_outlined,
            onTap: onNotifications,
            tooltip: notificationsTooltip,
            showBadge: hasUnreadNotifications,
          ),
          _TopBarIconButton(
            icon: Icons.menu_rounded,
            onTap: onMenu,
            tooltip: menuTooltip,
          ),
        ],
      ),
    );
  }
}

class _CenterTitle extends StatelessWidget {
  final String businessName;
  final bool isVerified;

  const _CenterTitle({required this.businessName, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 14,
          color: AppColors.textSecondaryOf(context),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            businessName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleMedium(context).copyWith(
              fontWeight: AppTypography.bold,
            ),
          ),
        ),
        if (isVerified) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.verified_rounded,
            color: AppColors.verifiedColor,
            size: 16,
          ),
        ],
        const SizedBox(width: 2),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.textSecondaryOf(context),
        ),
      ],
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool showBadge;

  const _TopBarIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 26,
                color: AppColors.textPrimaryOf(context),
              ),
              if (showBadge)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error,
                      border: Border.all(
                        color: AppColors.surfaceOf(context),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
