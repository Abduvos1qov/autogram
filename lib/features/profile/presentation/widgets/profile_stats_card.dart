import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ProfileStatsCard extends StatelessWidget {
  final int activeListings;
  final int savedCount;

  const ProfileStatsCard({
    super.key,
    required this.activeListings,
    required this.savedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.inventory_2_outlined,
                value: activeListings,
                label: 'profile.stats.active'.tr(),
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.dividerOf(context),
            ),
            Expanded(
              child: _StatItem(
                icon: Icons.bookmark_outline,
                value: savedCount,
                label: 'profile.stats.saved'.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 22,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: AppTypography.headlineSmall(context).copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall(context),
        ),
      ],
    );
  }
}
