import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Quick-actions bottom sheet shown by the `+` icon in the storefront top
/// bar. Mirrors Instagram's compose menu — once the create-listing feature
/// lands, the disabled "New listing" tile becomes a direct route.
class StorefrontCreateSheet extends StatelessWidget {
  final VoidCallback onNewListingDisabled;
  final VoidCallback onBoost;
  final VoidCallback onShareProfile;
  final VoidCallback onEditProfile;

  const StorefrontCreateSheet({
    super.key,
    required this.onNewListingDisabled,
    required this.onBoost,
    required this.onShareProfile,
    required this.onEditProfile,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onNewListingDisabled,
    required VoidCallback onBoost,
    required VoidCallback onShareProfile,
    required VoidCallback onEditProfile,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StorefrontCreateSheet(
        onNewListingDisabled: onNewListingDisabled,
        onBoost: onBoost,
        onShareProfile: onShareProfile,
        onEditProfile: onEditProfile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Handle(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'profile.storefront.create_sheet.title'.tr(),
                  style: AppTypography.titleMedium(context).copyWith(
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SheetTile(
              icon: Icons.add_road_rounded,
              label: 'profile.storefront.create_sheet.new_listing'.tr(),
              comingSoonLabel:
                  'profile.storefront.create_sheet.new_listing_coming_soon'.tr(),
              onTap: () {
                Navigator.pop(context);
                onNewListingDisabled();
              },
            ),
            _SheetTile(
              icon: Icons.rocket_launch_outlined,
              label: 'profile.storefront.create_sheet.boost'.tr(),
              onTap: () {
                Navigator.pop(context);
                onBoost();
              },
            ),
            _SheetTile(
              icon: Icons.share_outlined,
              label: 'profile.storefront.create_sheet.share'.tr(),
              onTap: () {
                Navigator.pop(context);
                onShareProfile();
              },
            ),
            _SheetTile(
              icon: Icons.edit_outlined,
              label: 'profile.storefront.create_sheet.edit'.tr(),
              onTap: () {
                Navigator.pop(context);
                onEditProfile();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.dividerOf(context),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? comingSoonLabel;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.comingSoonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerOf(context),
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              AppSpacing.gapHorizontalMd,
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyLarge(context).copyWith(
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
              if (comingSoonLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    comingSoonLabel!,
                    style: AppTypography.labelSmallStyle.copyWith(
                      color: AppColors.warning,
                      fontWeight: AppTypography.semiBold,
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
