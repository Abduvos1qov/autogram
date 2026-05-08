import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../payment/domain/entities/billing_cycle.dart';
import '../../domain/entities/seller_profile.dart';
import '../../domain/repositories/seller_repository.dart';

/// Subscription plan card

class PlanCard extends StatelessWidget {
  final SubscriptionPlanDetails plan;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;
  final BillingCycle billingCycle;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
    this.billingCycle = BillingCycle.monthly,
  });

  @override
  Widget build(BuildContext context) {
    final isPopular = plan.isPopular;
    final isFree = plan.plan == SubscriptionPlan.free;
    final isYearly = billingCycle == BillingCycle.yearly;
    final price = isYearly ? plan.yearlyPrice : plan.monthlyPrice;
    final isNegotiable = price == -1;
    final isUnlimited = plan.maxListings == -1;
    final priceSuffix = isYearly
        ? 'seller.ui.price_per_year'.tr()
        : 'seller.ui.price_per_month'.tr();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceOf(context),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isPopular ? AppColors.secondary : AppColors.grey200),
                width: isSelected || isPopular ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.plan.labelKey.tr(),
                          style: AppTypography.titleMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimaryOf(context),
                          ),
                        ),
                        AppSpacing.gapVerticalXs,
                        if (isFree)
                          Text(
                            'seller.ui.free_price'.tr(),
                            style: AppTypography.headlineSmall(context).copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else if (isNegotiable)
                          Text(
                            'seller.ui.negotiable'.tr(),
                            style: AppTypography.headlineSmall(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryOf(context),
                            ),
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.formatPrice(
                                  price.toDouble(),
                                  currency: 'UZS',
                                ),
                                style: AppTypography.headlineSmall(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                priceSuffix,
                                style: AppTypography.bodySmall(context).copyWith(
                                  color: AppColors.textSecondaryOf(context),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 20,
                          color: AppColors.white,
                        ),
                      )
                    else if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'seller.ui.current_badge'.tr(),
                          style: AppTypography.labelSmall(context).copyWith(
                            color: AppColors.textSecondaryOf(context),
                          ),
                        ),
                      ),
                  ],
                ),
                AppSpacing.gapVerticalMd,
                Text(
                  plan.plan.audienceLabelKey.tr(),
                  style: AppTypography.bodySmall(context).copyWith(
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
                AppSpacing.gapVerticalMd,
                const Divider(),
                AppSpacing.gapVerticalMd,
                ...plan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.success,
                          ),
                          AppSpacing.gapHorizontalSm,
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTypography.bodySmall(context),
                            ),
                          ),
                        ],
                      ),
                    )),
                AppSpacing.gapVerticalSm,
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: AppColors.grey600,
                    ),
                    AppSpacing.gapHorizontalSm,
                    Text(
                      isUnlimited
                          ? 'seller.ui.unlimited_listings'.tr()
                          : 'seller.ui.listings_count'
                              .tr(namedArgs: {'count': '${plan.maxListings}'}),
                      style: AppTypography.bodySmall(context).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -10,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'seller.ui.popular_badge'.tr(),
                  style: AppTypography.labelSmall(context).copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
