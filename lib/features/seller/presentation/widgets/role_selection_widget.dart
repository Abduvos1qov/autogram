import 'package:flutter/material.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Visual role selection cards following the [TypeCard] pattern.
///
/// Displays selectable cards for each [MemberRole] that is below the
/// [currentUserRole] level. The owner role is never shown — it cannot
/// be assigned through the UI.

class RoleSelectionWidget extends StatelessWidget {
  final MemberRole? selectedRole;
  final ValueChanged<MemberRole> onRoleSelected;
  final MemberRole? currentUserRole;

  const RoleSelectionWidget({
    super.key,
    this.selectedRole,
    required this.onRoleSelected,
    this.currentUserRole,
  });

  /// Returns the roles that the current user is allowed to assign.
  /// Owner is never shown. Only roles below the current user's level
  /// are available for selection.
  List<MemberRole> get _availableRoles {
    return MemberRole.values.where((role) {
      // Never allow assigning the owner role
      if (role == MemberRole.owner) return false;

      // If no currentUserRole provided, show all non-owner roles
      if (currentUserRole == null) return true;

      // Only show roles strictly below the current user's level
      return currentUserRole!.isHigherThan(role);
    }).toList();
  }

  IconData _iconForRole(MemberRole role) {
    switch (role) {
      case MemberRole.owner:
        return Icons.shield_outlined;
      case MemberRole.admin:
        return Icons.admin_panel_settings_outlined;
      case MemberRole.manager:
        return Icons.manage_accounts_outlined;
      case MemberRole.marketing:
        return Icons.campaign_outlined;
      case MemberRole.viewer:
        return Icons.visibility_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roles = _availableRoles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < roles.length; i++) ...[
          _RoleCard(
            role: roles[i],
            icon: _iconForRole(roles[i]),
            isSelected: selectedRole == roles[i],
            onTap: () => onRoleSelected(roles[i]),
          ),
          if (i < roles.length - 1) AppSpacing.gapVerticalSm,
        ],
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final MemberRole role;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

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
                    icon,
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
              role.label,
              style: AppTypography.titleMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.gapVerticalXs,
            Text(
              role.description,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
