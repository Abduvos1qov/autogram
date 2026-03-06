import 'package:flutter/material.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Grid display of permissions for a given [MemberRole].
///
/// Shows all 8 [Permission] values in a 2-column wrap layout.
/// Each permission shows a green check icon if granted or a grey
/// X icon if denied, alongside the permission label text.
///
/// Uses [PermissionService.getPermissionsForRole] for defaults,
/// but can be overridden with [customPermissions].

class PermissionGrid extends StatelessWidget {
  final MemberRole role;
  final Set<Permission>? customPermissions;

  const PermissionGrid({
    super.key,
    required this.role,
    this.customPermissions,
  });

  @override
  Widget build(BuildContext context) {
    final permissionService = PermissionService();
    final granted =
        customPermissions ?? permissionService.getPermissionsForRole(role);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: Permission.values.map((permission) {
        final isGranted = granted.contains(permission);
        return SizedBox(
          width: (MediaQuery.of(context).size.width - AppSpacing.md * 2 - AppSpacing.sm) / 2,
          child: _PermissionItem(
            permission: permission,
            isGranted: isGranted,
          ),
        );
      }).toList(),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final Permission permission;
  final bool isGranted;

  const _PermissionItem({
    required this.permission,
    required this.isGranted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isGranted ? Icons.check_circle_outline : Icons.cancel_outlined,
          size: AppSpacing.iconSm,
          color: isGranted ? AppColors.success : AppColors.grey400,
        ),
        AppSpacing.gapHorizontalXs,
        Flexible(
          child: Text(
            permission.label,
            style: AppTypography.bodySmall.copyWith(
              color: isGranted ? AppColors.textPrimary : AppColors.grey500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
