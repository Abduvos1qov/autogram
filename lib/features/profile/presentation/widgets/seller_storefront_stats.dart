import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../seller/domain/entities/seller_profile.dart';

/// 4-column stat row rendered below the seller's bio. Mirrors Instagram's
/// `posts | followers | following` triplet but expanded to four counts
/// relevant to a marketplace seller: listings, sold, followers, rating.
class SellerStorefrontStats extends StatelessWidget {
  final SellerStats stats;

  const SellerStorefrontStats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _StatColumn(
            value: _formatCount(stats.activeListings),
            label: 'seller.storefront.stats.listings'.tr(),
          ),
          _Divider(),
          _StatColumn(
            value: _formatCount(stats.totalSold),
            label: 'seller.storefront.stats.sold'.tr(),
          ),
          _Divider(),
          _StatColumn(
            value: _formatCount(stats.followersCount),
            label: 'seller.storefront.stats.followers'.tr(),
          ),
          _Divider(),
          _StatColumn(
            value: stats.totalReviews == 0
                ? '—'
                : stats.avgRating.toStringAsFixed(1),
            label: 'seller.storefront.stats.rating'.tr(),
            secondaryLabel:
                stats.totalReviews == 0 ? null : '(${stats.totalReviews})',
            valueIcon: stats.totalReviews == 0
                ? null
                : Icons.star_rounded,
          ),
        ],
      ),
    );
  }

  static String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    }
    return '$count';
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final String? secondaryLabel;
  final IconData? valueIcon;

  const _StatColumn({
    required this.value,
    required this.label,
    this.secondaryLabel,
    this.valueIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (valueIcon != null) ...[
                Icon(
                  valueIcon,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 2),
              ],
              Text(
                value,
                style: AppTypography.headlineSmall(context).copyWith(
                  fontWeight: AppTypography.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmallStyle.copyWith(
              color: AppColors.textSecondaryOf(context),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          if (secondaryLabel != null)
            Text(
              secondaryLabel!,
              style: AppTypography.labelSmallStyle.copyWith(
                color: AppColors.textTertiaryOf(context),
                fontSize: 9,
              ),
            ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.dividerOf(context),
    );
  }
}
