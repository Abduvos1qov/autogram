import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Cached network image with loading and error states

class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const AppCachedImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ?? _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.grey200,
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.grey400,
        size: 32,
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.grey200,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.grey400),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.grey200,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.grey400,
        size: 32,
      ),
    );
  }
}

/// Car listing thumbnail

class ListingThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ListingThumbnail({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AppCachedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: borderRadius ?? AppSpacing.borderRadiusMd,
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: borderRadius ?? AppSpacing.borderRadiusMd,
        ),
        child: const Icon(
          Icons.directions_car_outlined,
          color: AppColors.grey400,
          size: 48,
        ),
      ),
    );
  }
}

/// Video thumbnail with play icon

class VideoThumbnail extends StatelessWidget {
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final String? duration;

  const VideoThumbnail({
    super.key,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AppCachedImage(
            imageUrl: thumbnailUrl,
            width: width,
            height: height,
            borderRadius: borderRadius ?? AppSpacing.borderRadiusMd,
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: borderRadius ?? AppSpacing.borderRadiusMd,
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: AppColors.white,
                  size: 48,
                ),
              ),
            ),
          ),
          if (duration != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  duration!,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
