import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/reel.dart';

/// Reel action buttons - right side vertical buttons

class ReelActions extends StatelessWidget {
  final Reel reel;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const ReelActions({
    super.key,
    required this.reel,
    this.onLike,
    this.onComment,
    this.onSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      bottom: 100,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Like button
            _ActionButton(
              icon: reel.isLiked ? Icons.favorite : Icons.favorite_border,
              label: Formatters.formatNumber(reel.likesCount),
              isActive: reel.isLiked,
              activeColor: AppColors.error,
              onTap: onLike,
            ),
            const SizedBox(height: 20),

            // Comment button
            _ActionButton(
              icon: Icons.chat_bubble_outline,
              label: Formatters.formatNumber(reel.commentsCount),
              onTap: onComment,
            ),
            const SizedBox(height: 20),

            // Save button
            _ActionButton(
              icon: reel.isSaved ? Icons.bookmark : Icons.bookmark_border,
              label: Formatters.formatNumber(reel.savesCount),
              isActive: reel.isSaved,
              activeColor: AppColors.warning,
              onTap: onSave,
            ),
            const SizedBox(height: 20),

            // Share button
            _ActionButton(
              icon: Icons.send,
              label: Formatters.formatNumber(reel.sharesCount),
              onTap: onShare,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : AppColors.white,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
