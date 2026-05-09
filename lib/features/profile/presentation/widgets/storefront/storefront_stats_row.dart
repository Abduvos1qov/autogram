import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

/// Inline 4-stat block (Listings | Followers | Sold | Rating) shown to the
/// right of the seller avatar in the storefront identity row.
class StorefrontStatsRow extends StatelessWidget {
  final int listingsCount;
  final int followersCount;
  final int soldCount;
  final double? rating;
  final String listingsLabel;
  final String followersLabel;
  final String soldLabel;
  final String ratingLabel;
  final VoidCallback? onListingsTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onSoldTap;
  final VoidCallback? onRatingTap;

  const StorefrontStatsRow({
    super.key,
    required this.listingsCount,
    required this.followersCount,
    required this.soldCount,
    required this.rating,
    required this.listingsLabel,
    required this.followersLabel,
    required this.soldLabel,
    required this.ratingLabel,
    this.onListingsTap,
    this.onFollowersTap,
    this.onSoldTap,
    this.onRatingTap,
  });

  static String _formatCount(int n) {
    if (n >= 1000000) {
      final m = (n / 1000000).toStringAsFixed(1).replaceAll('.0', '');
      return '${m}M';
    }
    if (n >= 1000) {
      final k = (n / 1000).toStringAsFixed(1).replaceAll('.0', '');
      return '${k}K';
    }
    return '$n';
  }

  static String _formatRating(double? r) {
    if (r == null || r <= 0) return '—';
    return r.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _StatColumn(
          value: _formatCount(listingsCount),
          label: listingsLabel,
          onTap: onListingsTap,
        ),
        _StatColumn(
          value: _formatCount(followersCount),
          label: followersLabel,
          onTap: onFollowersTap,
        ),
        _StatColumn(
          value: _formatCount(soldCount),
          label: soldLabel,
          onTap: onSoldTap,
        ),
        _StatColumn(
          value: _formatRating(rating),
          label: ratingLabel,
          trailingIcon: Icons.star_rounded,
          trailingColor: AppColors.premiumGold,
          onTap: onRatingTap,
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final IconData? trailingIcon;
  final Color? trailingColor;
  final VoidCallback? onTap;

  const _StatColumn({
    required this.value,
    required this.label,
    this.trailingIcon,
    this.trailingColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailingIcon != null) ...[
                    Icon(
                      trailingIcon,
                      size: 16,
                      color: trailingColor ?? AppColors.textPrimaryOf(context),
                    ),
                    const SizedBox(width: 2),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: AppTypography.titleLarge(context).copyWith(
                          fontWeight: AppTypography.bold,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(context).copyWith(
                  color: AppColors.textSecondaryOf(context),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
