import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Two wide neutral buttons (Edit profile / Share profile) plus a small
/// info-icon button on the right that opens the About screen.
class StorefrontActionRow extends StatelessWidget {
  final String editProfileLabel;
  final String shareProfileLabel;
  final String? aboutTooltip;
  final VoidCallback onEditProfile;
  final VoidCallback onShareProfile;
  final VoidCallback onAbout;

  const StorefrontActionRow({
    super.key,
    required this.editProfileLabel,
    required this.shareProfileLabel,
    required this.onEditProfile,
    required this.onShareProfile,
    required this.onAbout,
    this.aboutTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: _NeutralButton(
              label: editProfileLabel,
              onTap: onEditProfile,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _NeutralButton(
              label: shareProfileLabel,
              onTap: onShareProfile,
            ),
          ),
          const SizedBox(width: 8),
          _SquareIconButton(
            icon: Icons.info_outline_rounded,
            onTap: onAbout,
            tooltip: aboutTooltip,
          ),
        ],
      ),
    );
  }
}

class _NeutralButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NeutralButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerOf(context),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium(context).copyWith(
                fontWeight: AppTypography.semiBold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surfaceContainerOf(context),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
