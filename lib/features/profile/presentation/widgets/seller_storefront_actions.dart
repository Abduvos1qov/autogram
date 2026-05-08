import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Action button row for the seller's own storefront — Edit profile + Share +
/// quick links to subscription/team/seats. The visiting-other-seller variant
/// (Follow + Message) lives in a separate file once that route ships.
class SellerStorefrontActions extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onShareProfile;
  final VoidCallback onBoost;
  final VoidCallback onTeam;
  final VoidCallback onSubscription;

  const SellerStorefrontActions({
    super.key,
    required this.onEditProfile,
    required this.onShareProfile,
    required this.onBoost,
    required this.onTeam,
    required this.onSubscription,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          // Primary actions row.
          Row(
            children: [
              Expanded(
                child: _PrimaryActionButton(
                  icon: Icons.edit_outlined,
                  label: 'seller.storefront.actions.edit_profile'.tr(),
                  onTap: onEditProfile,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PrimaryActionButton(
                  icon: Icons.ios_share_rounded,
                  label: 'seller.storefront.actions.share_profile'.tr(),
                  onTap: onShareProfile,
                  isPrimary: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Quick action chips (horizontal, scrollable on small screens).
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _QuickChip(
                  icon: Icons.local_fire_department_outlined,
                  label: 'seller.storefront.actions.boost'.tr(),
                  onTap: onBoost,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                _QuickChip(
                  icon: Icons.groups_outlined,
                  label: 'seller.storefront.actions.team'.tr(),
                  onTap: onTeam,
                ),
                const SizedBox(width: 8),
                _QuickChip(
                  icon: Icons.workspace_premium_outlined,
                  label: 'seller.storefront.actions.subscription'.tr(),
                  onTap: onSubscription,
                  color: AppColors.premiumGold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary
        ? AppColors.primaryOf(context)
        : AppColors.surfaceContainerOf(context);
    final fg = isPrimary
        ? AppColors.white
        : AppColors.textPrimaryOf(context);
    final border = isPrimary
        ? null
        : Border.all(color: AppColors.borderOf(context), width: 1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Ink(
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppSpacing.borderRadiusMd,
            border: border,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLargeStyle.copyWith(
                    color: fg,
                    fontWeight: AppTypography.semiBold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primaryOf(context);
    return Material(
      color: AppColors.surfaceContainerOf(context),
      borderRadius: AppSpacing.borderRadiusSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelMediumStyle.copyWith(
                  color: AppColors.textPrimaryOf(context),
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
