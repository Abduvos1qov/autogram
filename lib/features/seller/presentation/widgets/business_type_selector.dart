import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/seller_profile.dart';

/// Chip-style selector for [BusinessType], rendered inline in the
/// business-info form (replaces the dedicated business-type step).
class BusinessTypeSelector extends StatelessWidget {
  final BusinessType? selected;
  final ValueChanged<BusinessType> onChanged;

  const BusinessTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: BusinessType.values.map((type) {
        final isActive = selected == type;
        return _BusinessTypeChip(
          type: type,
          isActive: isActive,
          onTap: () => onChanged(type),
        );
      }).toList(),
    );
  }
}

class _BusinessTypeChip extends StatelessWidget {
  final BusinessType type;
  final bool isActive;
  final VoidCallback onTap;

  const _BusinessTypeChip({
    required this.type,
    required this.isActive,
    required this.onTap,
  });

  IconData get _icon {
    switch (type) {
      case BusinessType.individual:
        return Icons.person_outline;
      case BusinessType.dealer:
        return Icons.car_rental;
      case BusinessType.showroom:
        return Icons.storefront_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.surfaceContainerOf(context),
            borderRadius: AppSpacing.borderRadiusLg,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.borderOf(context),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _icon,
                size: 18,
                color: isActive
                    ? AppColors.white
                    : AppColors.textSecondaryOf(context),
              ),
              AppSpacing.gapHorizontalXs,
              Text(
                type.labelKey.tr(),
                style: AppTypography.labelMedium(context).copyWith(
                  color: isActive
                      ? AppColors.white
                      : AppColors.textPrimaryOf(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
