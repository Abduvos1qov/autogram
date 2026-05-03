import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/media/avatar.dart';
import '../../domain/entities/reel.dart';

/// Reel overlay - shows info at the bottom of the reel

class ReelOverlay extends StatelessWidget {
  final Reel reel;
  final VoidCallback? onSellerTap;

  const ReelOverlay({
    super.key,
    required this.reel,
    this.onSellerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 60, // Leave space for action buttons
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seller info
              _buildSellerInfo(context),
              AppSpacing.gapVerticalMd,

              // Title
              Text(
                reel.title,
                style: AppTypography.titleMedium(context).copyWith(
                  color: AppColors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.gapVerticalSm,

              // Price and specs
              _buildPriceSpecs(context),

              // Description (if any)
              if (reel.description != null &&
                  reel.description!.isNotEmpty) ...[
                AppSpacing.gapVerticalSm,
                Text(
                  reel.description!,
                  style: AppTypography.bodySmall(context).copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              AppSpacing.gapVerticalSm,

              // View details button
              _buildDetailsButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerInfo(BuildContext context) {
    return GestureDetector(
      onTap: onSellerTap ?? () => context.push('/seller/${reel.sellerId}'),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: reel.sellerLogoUrl,
            name: reel.sellerName,
            size: AvatarSize.md,
            isVerified: reel.isSellerVerified,
          ),
          AppSpacing.gapHorizontalSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        reel.sellerName,
                        style: AppTypography.titleSmall(context).copyWith(
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (reel.isSellerVerified) ...[
                      AppSpacing.gapHorizontalXs,
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.verifiedColor,
                      ),
                    ],
                  ],
                ),
                if (reel.city != null)
                  Text(
                    reel.city!,
                    style: AppTypography.bodySmall(context).copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          // Follow button
          if (!reel.isFollowing)
            OutlinedButton(
              onPressed: () {
                // TODO: Follow seller
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.white),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
              ),
              child: const Text('Follow'),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSpecs(BuildContext context) {
    final specs = <String>[];

    if (reel.autoDetails != null) {
      if (reel.autoDetails!.year != null) {
        specs.add('${reel.autoDetails!.year}');
      }
      if (reel.autoDetails!.mileage != null) {
        specs.add(Formatters.formatMileage(reel.autoDetails!.mileage!));
      }
      if (reel.autoDetails!.transmission != null) {
        specs.add(reel.autoDetails!.transmission == 'automatic'
            ? 'Avtomat'
            : 'Mexanik');
      }
    }

    return Row(
      children: [
        Text(
          Formatters.formatPrice(reel.price, currency: reel.currency),
          style: AppTypography.headlineSmall(context).copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (reel.isNegotiable) ...[
          AppSpacing.gapHorizontalSm,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Kelishiladi',
              style: AppTypography.labelSmall(context).copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
        if (specs.isNotEmpty) ...[
          AppSpacing.gapHorizontalMd,
          Text(
            specs.join(' • '),
            style: AppTypography.bodySmall(context).copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.push('/listing/${reel.id}'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('Batafsil ko\'rish'),
      ),
    );
  }
}
