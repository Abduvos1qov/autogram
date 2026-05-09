import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/feedback/shimmer_loading.dart';

/// Skeleton loading state for the profile tab. Approximates both the buyer
/// and seller storefront visual mass (cover-like top block + a couple of
/// content rows) so the layout shift on first paint is minimal.
class ProfileLoadingView extends StatelessWidget {
  const ProfileLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topInset + AppSpacing.md),
            // Identity-block placeholder.
            Container(
              height: 200,
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                0,
              ),
              decoration: BoxDecoration(
                color: AppColors.shimmerBaseOf(context),
                borderRadius: AppSpacing.borderRadiusLg,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Avatar + business name placeholders.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBaseOf(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ShimmerBox(height: 16, width: 180),
                        AppSpacing.gapVerticalSm,
                        const ShimmerBox(height: 12, width: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Stats row.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          const ShimmerBox(height: 18, width: 40),
                          AppSpacing.gapVerticalXs,
                          const ShimmerBox(height: 10, width: 60),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Action buttons row.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: ShimmerBox(height: 40, borderRadius: 12),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ShimmerBox(height: 40, borderRadius: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Grid placeholder (3 squares row + extra row).
            Padding(
              padding: const EdgeInsets.all(2),
              child: Column(
                children: List.generate(3, (row) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: List.generate(3, (col) {
                        return const Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(1),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ShimmerBox(height: 0),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
