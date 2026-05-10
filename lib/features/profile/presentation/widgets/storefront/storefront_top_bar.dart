import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Flat IG-style top bar shown at the top of the seller storefront.
/// Designed to live inside `SliverAppBar(pinned: true)`.
///
/// Left zone: `+` icon → opens create-content sheet.
/// Center: business name + verified icon.
/// Right zone: hamburger.
class StorefrontTopBar extends StatelessWidget {
  final String businessName;
  final bool isVerified;
  final String? createTooltip;
  final String? menuTooltip;
  final VoidCallback onCreate;
  final VoidCallback onMenu;

  const StorefrontTopBar({
    super.key,
    required this.businessName,
    required this.isVerified,
    required this.onCreate,
    required this.onMenu,
    this.createTooltip,
    this.menuTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          _TopBarIconButton(
            icon: Icons.add,
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
      ],
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _TopBarIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
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
          child: Icon(
            icon,
            size: 26,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
