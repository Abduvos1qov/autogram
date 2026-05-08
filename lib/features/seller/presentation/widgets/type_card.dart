import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/seller_profile.dart';

/// Business type selection card

class TypeCard extends StatelessWidget {
  final BusinessType type;
  final bool isSelected;
  final VoidCallback onTap;

  const TypeCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (type) {
      case BusinessType.individual:
        return Icons.person_outline;
      case BusinessType.dealer:
        return Icons.store_outlined;
      case BusinessType.showroom:
        return Icons.business_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.grey100,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Icon(
                    _icon,
                    size: 28,
                    color: isSelected ? AppColors.primary : AppColors.grey600,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
              ],
            ),
            AppSpacing.gapVerticalMd,
            Text(
              type.labelKey.tr(),
              style: AppTypography.titleMedium(context).copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimaryOf(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.gapVerticalXs,
            Text(
              type.descriptionKey.tr(),
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
