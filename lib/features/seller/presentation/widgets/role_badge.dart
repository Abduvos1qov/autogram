import 'package:flutter/material.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Small colored chip widget showing a [MemberRole] label.
///
/// Use [compact] to render a smaller variant suitable for tight spaces.

class RoleBadge extends StatelessWidget {
  final MemberRole role;
  final bool compact;

  const RoleBadge({
    super.key,
    required this.role,
    this.compact = false,
  });

  Color get _color {
    switch (role) {
      case MemberRole.owner:
        return AppColors.primary;
      case MemberRole.admin:
        return AppColors.secondary;
      case MemberRole.manager:
        return AppColors.accent;
      case MemberRole.marketing:
        return Colors.amber;
      case MemberRole.viewer:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _color.withValues(alpha: 0.12);
    final textColor = _color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.label,
        style: (compact ? AppTypography.labelSmall : AppTypography.labelMedium)
            .copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
