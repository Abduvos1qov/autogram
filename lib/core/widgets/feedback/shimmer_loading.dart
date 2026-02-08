import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Shimmer loading effect widgets

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
      highlightColor:
          isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlight,
      child: child,
    );
  }
}

/// Shimmer box placeholder

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer circle placeholder

class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.grey300,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Shimmer list item for feed cards

class ShimmerFeedCard extends StatelessWidget {
  const ShimmerFeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const ShimmerCircle(size: 40),
                AppSpacing.gapHorizontalSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerBox(width: 120, height: 14),
                      AppSpacing.gapVerticalXs,
                      const ShimmerBox(width: 80, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.gapVerticalMd,
            // Video placeholder
            const ShimmerBox(
              height: 300,
              borderRadius: 12,
            ),
            AppSpacing.gapVerticalMd,
            // Action buttons
            Row(
              children: [
                const ShimmerBox(width: 32, height: 32, borderRadius: 16),
                AppSpacing.gapHorizontalSm,
                const ShimmerBox(width: 32, height: 32, borderRadius: 16),
                AppSpacing.gapHorizontalSm,
                const ShimmerBox(width: 32, height: 32, borderRadius: 16),
                const Spacer(),
                const ShimmerBox(width: 32, height: 32, borderRadius: 16),
              ],
            ),
            AppSpacing.gapVerticalMd,
            // Title and price
            const ShimmerBox(width: 200, height: 18),
            AppSpacing.gapVerticalSm,
            const ShimmerBox(width: 150, height: 14),
          ],
        ),
      ),
    );
  }
}

/// Shimmer list for multiple items

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Axis scrollDirection;
  final EdgeInsets? padding;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: scrollDirection,
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Shimmer conversation list item

class ShimmerConversationItem extends StatelessWidget {
  const ShimmerConversationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            const ShimmerCircle(size: 56),
            AppSpacing.gapHorizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 140, height: 16),
                  AppSpacing.gapVerticalSm,
                  const ShimmerBox(height: 14),
                ],
              ),
            ),
            const ShimmerBox(width: 40, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Shimmer for listing detail

class ShimmerListingDetail extends StatelessWidget {
  const ShimmerListingDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video/Image placeholder
            const ShimmerBox(height: 300),
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapVerticalMd,
                  const ShimmerBox(height: 24),
                  AppSpacing.gapVerticalSm,
                  const ShimmerBox(width: 100, height: 16),
                  AppSpacing.gapVerticalLg,
                  const ShimmerBox(width: 120, height: 28),
                  AppSpacing.gapVerticalLg,
                  // Specs grid
                  Row(
                    children: [
                      const Expanded(child: ShimmerBox(height: 60)),
                      AppSpacing.gapHorizontalSm,
                      const Expanded(child: ShimmerBox(height: 60)),
                      AppSpacing.gapHorizontalSm,
                      const Expanded(child: ShimmerBox(height: 60)),
                    ],
                  ),
                  AppSpacing.gapVerticalMd,
                  Row(
                    children: [
                      const Expanded(child: ShimmerBox(height: 60)),
                      AppSpacing.gapHorizontalSm,
                      const Expanded(child: ShimmerBox(height: 60)),
                      AppSpacing.gapHorizontalSm,
                      const Expanded(child: ShimmerBox(height: 60)),
                    ],
                  ),
                  AppSpacing.gapVerticalLg,
                  const ShimmerBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
