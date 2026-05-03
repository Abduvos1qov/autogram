import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/seller_invitation.dart';
import 'role_badge.dart';

/// List item widget for displaying a pending invitation.
///
/// Shows an email icon avatar, email address, [RoleBadge], remaining
/// days until expiry, and a cancel button when [onCancel] is provided.

class InvitationListTile extends StatelessWidget {
  final SellerInvitation invitation;
  final VoidCallback? onCancel;

  const InvitationListTile({
    super.key,
    required this.invitation,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final daysRemaining = invitation.daysRemaining;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Email icon avatar
          CircleAvatar(
            radius: AppSpacing.avatarMd / 2,
            backgroundColor: AppColors.grey100,
            child: const Icon(
              Icons.email_outlined,
              size: AppSpacing.iconMd,
              color: AppColors.grey600,
            ),
          ),
          AppSpacing.gapHorizontalMd,

          // Email, role badge, and time remaining
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.email,
                  style: AppTypography.titleSmall(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.gapVerticalXs,
                Row(
                  children: [
                    RoleBadge(role: invitation.role, compact: true),
                    AppSpacing.gapHorizontalSm,
                    Text(
                      '$daysRemaining kun qoldi',
                      style: AppTypography.caption(context).copyWith(
                        color: daysRemaining <= 1
                            ? AppColors.error
                            : AppColors.textSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Cancel button
          if (onCancel != null)
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close),
              iconSize: AppSpacing.iconSm,
              color: AppColors.error,
              tooltip: 'Bekor qilish',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
        ],
      ),
    );
  }
}
