import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../listing/domain/entities/listing.dart';

/// Instagram-style square tile rendering a single listing in a 3-column grid.
///
/// Visual hierarchy (bottom-up):
///   1. Cover image (square crop, fills tile)
///   2. Top-right corner badges: video play icon (if video), featured star
///   3. Bottom gradient + price + brand/year overlay
///   4. Sold-overlay diagonal stripe when status is `sold`
class ListingGridTile extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;

  const ListingGridTile({
    super.key,
    required this.listing,
    this.onTap,
  });

  String? get _coverUrl {
    if (listing.videoThumbnailUrl != null &&
        listing.videoThumbnailUrl!.isNotEmpty) {
      return listing.videoThumbnailUrl;
    }
    if (listing.images.isNotEmpty) return listing.images.first;
    return null;
  }

  String _formattedPrice() {
    final price = listing.price;
    if (price >= 1000) {
      final k = (price / 1000).toStringAsFixed(price >= 10000 ? 0 : 1);
      return '\$${k.replaceAll('.0', '')}k';
    }
    return '\$${price.toStringAsFixed(0)}';
  }

  String? _brandYearLabel() {
    final auto = listing.autoDetails;
    if (auto == null) return null;
    final parts = <String>[];
    if (auto.brand != null) parts.add(auto.brand!);
    if (auto.year != null) parts.add('${auto.year}');
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final cover = _coverUrl;
    final brandYear = _brandYearLabel();
    final isSold = listing.status == ListingStatus.sold;
    final hasVideo =
        listing.videoUrl != null && listing.videoUrl!.isNotEmpty;

    return Material(
      color: AppColors.surfaceContainerOf(context),
      borderRadius: BorderRadius.circular(2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (cover != null)
                CachedNetworkImage(
                  imageUrl: cover,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: AppColors.shimmerBaseOf(context),
                  ),
                  errorWidget: (_, _, _) => _Placeholder(
                    listing: listing,
                  ),
                )
              else
                _Placeholder(listing: listing),

              // Bottom gradient + price/brand overlay. The black end stop is
              // intentionally heavier than 50% so price text stays legible
              // over busy car photography.
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppColors.overlayHeavy],
                      stops: [0.55, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formattedPrice(),
                      style: AppTypography.titleSmallStyle.copyWith(
                        color: AppColors.white,
                        fontWeight: AppTypography.bold,
                        height: 1.1,
                      ),
                    ),
                    if (brandYear != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        brandYear,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSmallStyle.copyWith(
                          color: AppColors.white.withValues(alpha: 0.85),
                          fontSize: 10,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Top-right badges row.
              Positioned(
                top: 6,
                right: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (listing.isFeatured)
                      _CornerBadge(
                        icon: Icons.local_fire_department_rounded,
                        background: AppColors.accent.withValues(alpha: 0.95),
                      ),
                    if (hasVideo) ...[
                      const SizedBox(width: 4),
                      const _CornerBadge(
                        icon: Icons.play_arrow_rounded,
                        background: AppColors.overlayHeavy,
                      ),
                    ],
                  ],
                ),
              ),

              if (isSold) const _SoldOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Listing listing;

  const _Placeholder({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHighOf(context),
      alignment: Alignment.center,
      child: Icon(
        Icons.directions_car_filled_outlined,
        size: 32,
        color: AppColors.textTertiaryOf(context),
      ),
    );
  }
}

class _CornerBadge extends StatelessWidget {
  final IconData icon;
  final Color background;

  const _CornerBadge({
    required this.icon,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppSpacing.borderRadiusXs,
      ),
      child: Icon(
        icon,
        size: 14,
        color: AppColors.white,
      ),
    );
  }
}

class _SoldOverlay extends StatelessWidget {
  const _SoldOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'SOLD',
              style: AppTypography.labelSmallStyle.copyWith(
                color: AppColors.white,
                fontWeight: AppTypography.bold,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
