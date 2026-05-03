import 'package:flutter/material.dart';

import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/media/avatar.dart';
import '../../../../core/widgets/media/cached_image.dart';
import '../../domain/entities/feed_item.dart';

/// Instagram-style feed card

class FeedCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onComment;
  final VoidCallback? onSellerTap;

  const FeedCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLike,
    this.onSave,
    this.onShare,
    this.onComment,
    this.onSellerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),

          // Media (Video/Image)
          _buildMedia(),

          // Action buttons
          _buildActions(),

          // Likes count
          _buildLikesCount(context),

          // Title and description
          _buildContent(context),

          // Price and specs
          _buildPriceSpecs(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: GestureDetector(
        onTap: onSellerTap,
        child: Row(
          children: [
            AppAvatar(
              imageUrl: item.sellerLogoUrl,
              name: item.sellerName,
              size: AvatarSize.md,
              isVerified: item.isSellerVerified,
            ),
            AppSpacing.gapHorizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.sellerName,
                          style: AppTypography.titleSmall(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.isSellerVerified) ...[
                        AppSpacing.gapHorizontalXs,
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.verifiedColor,
                        ),
                      ],
                    ],
                  ),
                  if (item.location.isNotEmpty)
                    Text(
                      item.location,
                      style: AppTypography.bodySmall(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show options menu
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia() {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onLike,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: AppCachedImage(
              imageUrl: item.thumbnailUrl,
              fit: BoxFit.cover,
            ),
          ),
          if (item.hasVideo)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: AppColors.white,
                      size: 16,
                    ),
                    if (item.videoDuration != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        item.videoDuration!.formatDuration,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              item.isLiked ? Icons.favorite : Icons.favorite_border,
              color: item.isLiked ? AppColors.likeColor : null,
            ),
            onPressed: onLike,
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: onComment,
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: onShare,
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              item.isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: item.isSaved ? AppColors.saveColor : null,
            ),
            onPressed: onSave,
          ),
        ],
      ),
    );
  }

  Widget _buildLikesCount(BuildContext context) {
    if (item.likesCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Text(
        '${item.likesCount.compactFormatted} ta yoqtirish',
        style: AppTypography.labelMedium(context).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: AppTypography.titleMedium(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            AppSpacing.gapVerticalXs,
            Text(
              item.description!,
              style: AppTypography.bodySmall(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSpecs(BuildContext context) {
    final specs = <String>[];

    if (item.autoDetails != null) {
      if (item.autoDetails!.year != null) {
        specs.add('${item.autoDetails!.year}');
      }
      if (item.autoDetails!.mileage != null) {
        specs.add(Formatters.formatMileage(item.autoDetails!.mileage!));
      }
      if (item.autoDetails!.transmission != null) {
        specs.add(item.autoDetails!.transmission == 'automatic'
            ? 'Avtomat'
            : 'Mexanik');
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            Formatters.formatPrice(item.price, currency: item.currency),
            style: AppTypography.price(context),
          ),
          if (item.isNegotiable) ...[
            AppSpacing.gapHorizontalSm,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Kelishiladi',
                style: AppTypography.labelSmall(context),
              ),
            ),
          ],
          const Spacer(),
          if (specs.isNotEmpty)
            Text(
              specs.join(' • '),
              style: AppTypography.bodySmall(context),
            ),
        ],
      ),
    );
  }
}
