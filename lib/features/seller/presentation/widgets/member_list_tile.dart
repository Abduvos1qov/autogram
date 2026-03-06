import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/seller_member.dart';
import 'role_badge.dart';

/// List item widget for displaying a team member.
///
/// Shows the member's avatar (or initials fallback), name, email,
/// [RoleBadge], and a trailing chevron when [onTap] is provided.

class MemberListTile extends StatelessWidget {
  final SellerMember member;
  final VoidCallback? onTap;

  const MemberListTile({
    super.key,
    required this.member,
    this.onTap,
  });

  /// Extracts up to two initials from the member's name.
  String get _initials {
    final parts = member.memberName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(),
            AppSpacing.gapHorizontalMd,

            // Name, email, and role badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.memberName,
                    style: AppTypography.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (member.memberEmail != null) ...[
                    AppSpacing.gapVerticalXs,
                    Text(
                      member.memberEmail!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  AppSpacing.gapVerticalXs,
                  RoleBadge(role: member.role, compact: true),
                ],
              ),
            ),

            // Trailing chevron
            if (onTap != null) ...[
              AppSpacing.gapHorizontalSm,
              const Icon(
                Icons.chevron_right,
                size: AppSpacing.iconMd,
                color: AppColors.grey400,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (member.memberAvatarUrl != null &&
        member.memberAvatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: AppSpacing.avatarMd / 2,
        backgroundImage: NetworkImage(member.memberAvatarUrl!),
        backgroundColor: AppColors.grey100,
      );
    }

    return CircleAvatar(
      radius: AppSpacing.avatarMd / 2,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: Text(
        _initials,
        style: AppTypography.titleSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
