import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../reels/domain/entities/reel.dart';

/// Square 1:1 grid tile rendering a single reel (video listing) — IG-style:
/// thumbnail + tiny play overlay top-left + view count bottom-left.
class StorefrontReelsGridTile extends StatelessWidget {
  final Reel reel;
  final VoidCallback? onTap;

  const StorefrontReelsGridTile({
    super.key,
    required this.reel,
    this.onTap,
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

  @override
  Widget build(BuildContext context) {
    final thumbUrl = reel.videoThumbnailUrl;
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
              if (thumbUrl != null && thumbUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: thumbUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: AppColors.shimmerBaseOf(context),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.surfaceContainerHighOf(context),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      size: 32,
                      color: AppColors.textTertiaryOf(context),
                    ),
                  ),
                )
              else
                Container(
                  color: AppColors.surfaceContainerHighOf(context),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    size: 32,
                    color: AppColors.textTertiaryOf(context),
                  ),
                ),
              const Positioned(
                top: 6,
                left: 6,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.white,
                  size: 18,
                  shadows: [
                    Shadow(
                      color: AppColors.overlayHeavy,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 6,
                bottom: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.white,
                      size: 12,
                      shadows: [
                        Shadow(
                          color: AppColors.overlayHeavy,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _formatCount(reel.viewsCount),
                      style: AppTypography.labelSmallStyle.copyWith(
                        color: AppColors.white,
                        fontWeight: AppTypography.semiBold,
                        fontSize: 11,
                        shadows: const [
                          Shadow(
                            color: AppColors.overlayHeavy,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
