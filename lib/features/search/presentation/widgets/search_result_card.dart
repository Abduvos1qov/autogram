import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/media/cached_image.dart';
import '../../domain/entities/search_result.dart';

/// Search result card widget

class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback? onTap;

  const SearchResultCard({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppCachedImage(
                    imageUrl: result.videoThumbnailUrl ?? result.images.firstOrNull,
                    fit: BoxFit.cover,
                  ),
                  // Saved indicator
                  if (result.isSaved)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark,
                          size: 16,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  // Video indicator
                  if (result.videoThumbnailUrl != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              size: 12,
                              color: AppColors.white,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Video',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price
                    Text(
                      Formatters.formatPrice(result.price, currency: result.currency),
                      style: AppTypography.titleMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Title
                    Text(
                      result.title,
                      style: AppTypography.bodySmall(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Specs
                    if (result.autoDetails != null)
                      Text(
                        _buildSpecsText(),
                        style: AppTypography.labelSmall(context).copyWith(
                          color: AppColors.textSecondaryOf(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Location and views
                    Row(
                      children: [
                        if (result.city != null) ...[
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textSecondaryOf(context),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              result.city!,
                              style: AppTypography.labelSmall(context).copyWith(
                                color: AppColors.textSecondaryOf(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        Icon(
                          Icons.visibility_outlined,
                          size: 12,
                          color: AppColors.textSecondaryOf(context),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          Formatters.formatNumber(result.viewsCount),
                          style: AppTypography.labelSmall(context).copyWith(
                            color: AppColors.textSecondaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSpecsText() {
    final specs = <String>[];
    final auto = result.autoDetails;

    if (auto?.year != null) {
      specs.add('${auto!.year}');
    }
    if (auto?.mileage != null) {
      specs.add(Formatters.formatMileage(auto!.mileage!));
    }
    if (auto?.transmission != null) {
      specs.add(auto!.transmission == 'automatic' ? 'Avtomat' : 'Mexanik');
    }

    return specs.join(' • ');
  }
}
