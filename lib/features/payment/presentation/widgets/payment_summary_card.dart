import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/billing_cycle.dart';
import '../../domain/entities/payment_product.dart';
import '../../domain/entities/payment_request.dart';

/// Order-summary card rendered above the pay CTA on [PaymentScreen].
///
/// Reads the [PaymentRequest] product type and renders the relevant fields:
/// subscription → plan + cycle; seats → count + unit price; boost → package +
/// duration. Always shows a subtotal + total row at the bottom (UZS,
/// decimal-grouped).
class PaymentSummaryCard extends StatelessWidget {
  final PaymentRequest request;

  const PaymentSummaryCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment.summary_title'.tr(),
            style: AppTypography.titleMedium(context),
          ),
          AppSpacing.gapVerticalMd,
          Divider(
            color: AppColors.dividerOf(context),
            height: 1,
            thickness: 1,
          ),
          AppSpacing.gapVerticalMd,
          ..._buildContentRows(context),
          AppSpacing.gapVerticalMd,
          Divider(
            color: AppColors.dividerOf(context),
            height: 1,
            thickness: 1,
          ),
          AppSpacing.gapVerticalMd,
          _SummaryRow(
            label: 'payment.subtotal'.tr(),
            value: _formatUzs(_subtotalAmount()),
            muted: true,
          ),
          AppSpacing.gapVerticalSm,
          _SummaryRow(
            label: 'payment.total'.tr(),
            value: _formatUzs(_totalAmount()),
            emphasize: true,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContentRows(BuildContext context) {
    switch (request.productType) {
      case PaymentProduct.subscription:
        return _subscriptionRows(context);
      case PaymentProduct.additionalSeat:
        return _seatRows(context);
      case PaymentProduct.boost:
        return _boostRows(context);
    }
  }

  List<Widget> _subscriptionRows(BuildContext context) {
    final plan = request.plan;
    final cycle = request.billingCycle;
    return [
      _SummaryRow(
        label: 'payment.plan_label'.tr(),
        value: plan?.label ?? '-',
      ),
      AppSpacing.gapVerticalSm,
      _SummaryRow(
        label: 'payment.billing_cycle'.tr(),
        value: cycle?.label ?? '-',
      ),
    ];
  }

  List<Widget> _seatRows(BuildContext context) {
    final count = request.seatCount ?? 0;
    final unit = request.unitSeatPrice ?? 0;
    return [
      _SummaryRow(
        label: 'payment.additional_seats'.tr(),
        value: count.toString(),
      ),
      AppSpacing.gapVerticalSm,
      _SummaryRow(
        label: 'seats.price_per_seat'.tr(),
        value: _formatUzs(unit),
      ),
    ];
  }

  List<Widget> _boostRows(BuildContext context) {
    final pkg = request.boostPackage;
    return [
      _SummaryRow(
        label: 'payment.plan_label'.tr(),
        value: pkg?.name ?? '-',
      ),
      AppSpacing.gapVerticalSm,
      _SummaryRow(
        label: 'payment.billing_cycle'.tr(),
        value: pkg == null ? '-' : '${pkg.durationDays} kun',
      ),
    ];
  }

  int _subtotalAmount() {
    switch (request.productType) {
      case PaymentProduct.subscription:
        final plan = request.plan;
        final cycle = request.billingCycle;
        if (plan == null || cycle == null) return 0;
        final base = cycle == BillingCycle.yearly
            ? plan.yearlyPrice
            : plan.monthlyPrice;
        return base < 0 ? 0 : base;
      case PaymentProduct.additionalSeat:
        final count = request.seatCount ?? 0;
        final unit = request.unitSeatPrice ?? 0;
        return count * unit;
      case PaymentProduct.boost:
        return request.boostPackage?.priceUzs ?? 0;
    }
  }

  int _totalAmount() => _subtotalAmount();

  String _formatUzs(int amount) {
    final formatted = NumberFormat.decimalPattern().format(amount);
    return '$formatted ${'payment.currency_uzs'.tr()}';
  }
}

/// Single label/value row inside the summary card.
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  final bool muted;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = emphasize
        ? AppTypography.titleMedium(context)
        : AppTypography.bodyMedium(context).copyWith(
            color: muted
                ? AppColors.textSecondaryOf(context)
                : AppColors.textPrimaryOf(context),
          );
    final valueStyle = emphasize
        ? AppTypography.titleMedium(context).copyWith(
            color: AppColors.primaryOf(context),
            fontWeight: FontWeight.w700,
          )
        : AppTypography.bodyMedium(context).copyWith(
            color: muted
                ? AppColors.textSecondaryOf(context)
                : AppColors.textPrimaryOf(context),
            fontWeight: FontWeight.w500,
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        AppSpacing.gapHorizontalMd,
        Text(value, style: valueStyle),
      ],
    );
  }
}
