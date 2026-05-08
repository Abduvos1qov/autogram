import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../../../navigation/route_names.dart';
import '../../../seller/seller.dart';
import '../../domain/entities/payment_request.dart';
import '../widgets/seat_quantity_selector.dart';

/// Seat management screen.
///
/// Displays the seller's current seat usage (used / total) and lets the user
/// purchase additional seats — routing to the payment flow with a
/// [PaymentRequest.seats] intent. Free / Enterprise / unlimited tiers each
/// render a tailored prompt instead of the buy form.
class SeatManagementScreen extends StatefulWidget {
  const SeatManagementScreen({super.key});

  @override
  State<SeatManagementScreen> createState() => _SeatManagementScreenState();
}

class _SeatManagementScreenState extends State<SeatManagementScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: Text('seats.title'.tr()),
      ),
      body: BlocBuilder<SellerBloc, SellerState>(
        builder: (context, state) {
          final profile = state.profile;
          if (state.isLoading || profile == null) {
            return const Center(child: LoadingIndicator());
          }

          final plan = profile.subscriptionPlan;
          final used = profile.seatsUsed;
          final baseLimit = plan.seatsLimit;
          final additional = profile.additionalSeats;
          final isUnlimited = baseLimit == -1;
          final totalLimit = isUnlimited ? -1 : baseLimit + additional;
          final unitPrice = plan.additionalSeatPrice;

          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CurrentSeatsCard(
                  used: used,
                  totalLimit: totalLimit,
                  isUnlimited: isUnlimited,
                ),
                AppSpacing.gapVerticalLg,
                _BuyMoreSection(
                  plan: plan,
                  unitPrice: unitPrice,
                  isUnlimited: isUnlimited,
                  quantity: _quantity,
                  onQuantityChanged: (next) => setState(() => _quantity = next),
                  onPurchase: _initiateSeatPurchase,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _initiateSeatPurchase() {
    final state = context.read<SellerBloc>().state;
    final profile = state.profile;
    if (profile == null) return;

    final plan = profile.subscriptionPlan;
    final unitPrice = plan.additionalSeatPrice;
    if (unitPrice <= 0) return;

    final request = PaymentRequest.seats(
      plan: plan,
      seatCount: _quantity,
      unitSeatPrice: unitPrice,
    );
    context.push(RoutePaths.payment, extra: request);
  }
}

// ============================================================================
// Current seats card
// ============================================================================

class _CurrentSeatsCard extends StatelessWidget {
  final int used;
  final int totalLimit;
  final bool isUnlimited;

  const _CurrentSeatsCard({
    required this.used,
    required this.totalLimit,
    required this.isUnlimited,
  });

  @override
  Widget build(BuildContext context) {
    final available = isUnlimited ? -1 : (totalLimit - used).clamp(0, totalLimit);
    final progress = isUnlimited
        ? 0.0
        : (totalLimit == 0 ? 0.0 : (used / totalLimit).clamp(0.0, 1.0));

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: AppColors.borderOf(context),
          width: AppSpacing.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'seats.current_seats'.tr(),
            style: AppTypography.titleMedium(context),
          ),
          AppSpacing.gapVerticalSm,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$used',
                style: AppTypography.displaySmall(context).copyWith(
                  color: AppColors.primaryOf(context),
                  fontWeight: AppTypography.bold,
                ),
              ),
              AppSpacing.gapHorizontalXs,
              Text(
                isUnlimited ? '/ ∞' : '/ $totalLimit',
                style: AppTypography.titleLarge(context).copyWith(
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalSm,
          if (!isUnlimited) ...[
            ClipRRect(
              borderRadius: AppSpacing.borderRadiusSm,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerOf(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryOf(context),
                ),
              ),
            ),
            AppSpacing.gapVerticalSm,
            Text(
              '$available ${'seats.available'.tr()}',
              style: AppTypography.bodyMedium(context).copyWith(
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ] else
            Text(
              'seats.unlimited'.tr(),
              style: AppTypography.bodyMedium(context).copyWith(
                color: AppColors.successOf(context),
                fontWeight: AppTypography.semiBold,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// Buy-more section (or upgrade / contact prompt)
// ============================================================================

class _BuyMoreSection extends StatelessWidget {
  final SubscriptionPlan plan;
  final int unitPrice;
  final bool isUnlimited;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onPurchase;

  const _BuyMoreSection({
    required this.plan,
    required this.unitPrice,
    required this.isUnlimited,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    if (isUnlimited && plan != SubscriptionPlan.enterprise) {
      // Premium-style unlimited (currently only Enterprise has -1 seats; keep
      // for future-proofing if Premium ever becomes unlimited).
      return _NoticeCard(
        icon: Icons.all_inclusive_rounded,
        title: 'seats.unlimited_title'.tr(),
        message: 'seats.unlimited_message'.tr(),
      );
    }

    if (plan == SubscriptionPlan.enterprise) {
      return _NoticeCard(
        icon: Icons.support_agent_rounded,
        title: 'seats.enterprise_title'.tr(),
        message: 'seats.enterprise_message'.tr(),
        actionLabel: 'seats.contact_manager'.tr(),
        // Placeholder action — wire to Telegram / email link once available.
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('seats.contact_placeholder'.tr())),
          );
        },
      );
    }

    if (plan == SubscriptionPlan.free || unitPrice <= 0) {
      return _NoticeCard(
        icon: Icons.lock_outline_rounded,
        title: 'seats.free_locked_title'.tr(),
        message: 'seats.free_locked_message'.tr(),
        actionLabel: 'seats.upgrade_to_pro'.tr(),
        onAction: () => context.go(RoutePaths.upgrade),
      );
    }

    final monthlyTotal = unitPrice * quantity;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: AppColors.borderOf(context),
          width: AppSpacing.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'seats.buy_more'.tr(),
            style: AppTypography.titleMedium(context),
          ),
          AppSpacing.gapVerticalLg,

          // Quantity row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'seats.quantity'.tr(),
                style: AppTypography.bodyLarge(context),
              ),
              SeatQuantitySelector(
                value: quantity,
                onChanged: onQuantityChanged,
              ),
            ],
          ),
          AppSpacing.gapVerticalLg,

          // Per-seat price
          _PriceRow(
            label: 'seats.price_per_seat'.tr(),
            value: _formatUzs(unitPrice),
            isEmphasized: false,
          ),
          AppSpacing.gapVerticalSm,
          Divider(
            height: 1,
            thickness: AppSpacing.borderWidthThin,
            color: AppColors.dividerOf(context),
          ),
          AppSpacing.gapVerticalSm,

          // Monthly total
          _PriceRow(
            label: 'seats.monthly_total'.tr(),
            value: _formatUzs(monthlyTotal),
            isEmphasized: true,
            breakdown: '${_formatUzs(unitPrice)} × $quantity',
          ),
          AppSpacing.gapVerticalLg,

          PrimaryButton(
            text: 'seats.purchase_button'.tr(),
            onPressed: onPurchase,
          ),
        ],
      ),
    );
  }

  String _formatUzs(int amount) =>
      Formatters.formatPrice(amount.toDouble(), currency: 'UZS');
}

// ============================================================================
// Building blocks
// ============================================================================

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEmphasized;
  final String? breakdown;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.isEmphasized,
    this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = isEmphasized
        ? AppTypography.titleMedium(context).copyWith(
            fontWeight: AppTypography.semiBold,
          )
        : AppTypography.bodyMedium(context).copyWith(
            color: AppColors.textSecondaryOf(context),
          );

    final valueStyle = isEmphasized
        ? AppTypography.titleLarge(context).copyWith(
            color: AppColors.primaryOf(context),
            fontWeight: AppTypography.bold,
          )
        : AppTypography.bodyMedium(context);

    final breakdownText = breakdown;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              if (breakdownText != null) ...[
                AppSpacing.gapVerticalXs,
                Text(
                  breakdownText,
                  style: AppTypography.caption(context).copyWith(
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: AppColors.borderOf(context),
          width: AppSpacing.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSpacing.iconLg, color: AppColors.primaryOf(context)),
              AppSpacing.gapHorizontalMd,
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium(context),
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalSm,
          Text(
            message,
            style: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            AppSpacing.gapVerticalLg,
            PrimaryButton(
              text: actionLabel ?? '',
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
