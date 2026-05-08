import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../domain/entities/payment.dart';

/// Multi-variant terminal/processing status view for the payment flow.
///
/// One of: [PaymentStatusView.processing], [PaymentStatusView.success],
/// [PaymentStatusView.failed], [PaymentStatusView.cancelled]. The optional
/// [actionButton] slot lets the caller render plan-specific CTAs (Continue,
/// Retry, Back to plans) without duplicating layout.
class PaymentStatusView extends StatelessWidget {
  final _StatusVariant _variant;
  final Payment? payment;
  final Failure? failure;
  final Widget? actionButton;

  const PaymentStatusView.processing({
    super.key,
    required Payment this.payment,
    this.actionButton,
  })  : _variant = _StatusVariant.processing,
        failure = null;

  const PaymentStatusView.success({
    super.key,
    required Payment this.payment,
    this.actionButton,
  })  : _variant = _StatusVariant.success,
        failure = null;

  const PaymentStatusView.failed({
    super.key,
    required Failure this.failure,
    this.actionButton,
  })  : _variant = _StatusVariant.failed,
        payment = null;

  const PaymentStatusView.cancelled({
    super.key,
    this.actionButton,
  })  : _variant = _StatusVariant.cancelled,
        payment = null,
        failure = null;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final minHeight = size.height * 0.7;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: AppSpacing.paddingLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIcon(context),
          AppSpacing.gapVerticalXl,
          Text(
            _title().tr(),
            style: AppTypography.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.gapVerticalMd,
          Text(
            _subtitle(context),
            style: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondaryOf(context),
            ),
            textAlign: TextAlign.center,
          ),
          if (_extraDetail(context) != null) ...[
            AppSpacing.gapVerticalMd,
            Text(
              _extraDetail(context)!,
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.textTertiaryOf(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionButton != null) ...[
            AppSpacing.gapVerticalXl,
            actionButton!,
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    switch (_variant) {
      case _StatusVariant.processing:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primaryOf(context).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: LoadingIndicator(
              color: AppColors.primaryOf(context),
              size: 56,
              strokeWidth: 4,
            ),
          ),
        );
      case _StatusVariant.success:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.successOf(context).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 80,
            color: AppColors.successOf(context),
          ),
        );
      case _StatusVariant.failed:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.errorOf(context).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cancel_rounded,
            size: 80,
            color: AppColors.errorOf(context),
          ),
        );
      case _StatusVariant.cancelled:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.warningOf(context).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.info_outline_rounded,
            size: 80,
            color: AppColors.warningOf(context),
          ),
        );
    }
  }

  String _title() {
    switch (_variant) {
      case _StatusVariant.processing:
        return 'payment.processing';
      case _StatusVariant.success:
        return 'payment.success_title';
      case _StatusVariant.failed:
        return 'payment.failed_title';
      case _StatusVariant.cancelled:
        return 'payment.cancelled_title';
    }
  }

  String _subtitle(BuildContext context) {
    switch (_variant) {
      case _StatusVariant.processing:
        return 'payment.processing'.tr();
      case _StatusVariant.success:
        return 'payment.success_message'.tr();
      case _StatusVariant.failed:
        if (failure != null) {
          return ErrorHandler.getUserMessage(failure!);
        }
        return 'payment.failed_message'.tr();
      case _StatusVariant.cancelled:
        return 'payment.failed_message'.tr();
    }
  }

  String? _extraDetail(BuildContext context) {
    switch (_variant) {
      case _StatusVariant.processing:
        if (payment == null) return null;
        return 'ID: ${payment!.id}';
      case _StatusVariant.success:
        if (payment == null) return null;
        return _formatUzs(payment!.amount);
      case _StatusVariant.failed:
      case _StatusVariant.cancelled:
        return null;
    }
  }

  String _formatUzs(int amount) {
    final formatted = NumberFormat.decimalPattern().format(amount);
    return '$formatted ${'payment.currency_uzs'.tr()}';
  }
}

enum _StatusVariant { processing, success, failed, cancelled }
