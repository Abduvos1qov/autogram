import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/media/avatar.dart';
import '../../domain/entities/listing.dart';

/// Seller card widget

class SellerCard extends StatelessWidget {
  final Seller seller;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;

  const SellerCard({
    super.key,
    required this.seller,
    this.onTap,
    this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                AppAvatar(
                  imageUrl: seller.logoUrl,
                  name: seller.businessName,
                  size: AvatarSize.lg,
                  isVerified: seller.isVerified,
                ),
                AppSpacing.gapHorizontalMd,

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              seller.businessName,
                              style: AppTypography.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (seller.isVerified) ...[
                            AppSpacing.gapHorizontalXs,
                            const Icon(
                              Icons.verified,
                              size: 18,
                              color: AppColors.verifiedColor,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${seller.avgRating.toStringAsFixed(1)} (${seller.totalReviews})',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          AppSpacing.gapHorizontalMd,
                          Text(
                            '${seller.totalSold} ta sotilgan',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (seller.city != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              seller.city!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Follow button
                if (onFollow != null)
                  OutlinedButton(
                    onPressed: onFollow,
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          seller.isFollowing ? AppColors.textSecondary : AppColors.primary,
                      side: BorderSide(
                        color: seller.isFollowing ? AppColors.textSecondary : AppColors.primary,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(seller.isFollowing ? 'Kuzatilmoqda' : 'Kuzatish'),
                  ),
              ],
            ),

            // Stats
            AppSpacing.gapVerticalMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('E\'lonlar', '${seller.activeListings}'),
                _buildStat('Ko\'rishlar', _formatCount(seller.totalViews)),
                _buildStat('Sotilgan', '${seller.totalSold}'),
              ],
            ),

            // View profile button
            AppSpacing.gapVerticalMd,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTap,
                child: const Text('Profilni ko\'rish'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }
}
