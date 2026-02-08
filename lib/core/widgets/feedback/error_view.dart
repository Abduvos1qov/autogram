import 'package:flutter/material.dart';

import '../../errors/failures.dart';
import '../../errors/error_handler.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/primary_button.dart';

/// Error display widget

class ErrorView extends StatelessWidget {
  final Failure? failure;
  final String? message;
  final String? title;
  final VoidCallback? onRetry;
  final String retryText;
  final IconData icon;

  const ErrorView({
    super.key,
    this.failure,
    this.message,
    this.title,
    this.onRetry,
    this.retryText = 'Qaytadan urinish',
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = message ??
        (failure != null
            ? ErrorHandler.getUserMessage(failure!)
            : 'Xatolik yuz berdi');

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.error,
            ),
            AppSpacing.gapVerticalLg,
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.headlineSmall,
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapVerticalSm,
            ],
            Text(
              errorMessage,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.gapVerticalLg,
              PrimaryButton(
                text: retryText,
                onPressed: onRetry,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact error widget for inline use

class CompactErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const CompactErrorView({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          AppSpacing.gapHorizontalSm,
          Expanded(
            child: Text(
              message ?? 'Xatolik yuz berdi',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Qaytadan'),
            ),
        ],
      ),
    );
  }
}

/// Network error view

class NetworkErrorView extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorView({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      icon: Icons.wifi_off,
      title: 'Internet aloqasi yo\'q',
      message: 'Iltimos, internet ulanishingizni tekshiring va qaytadan urinib ko\'ring.',
      onRetry: onRetry,
    );
  }
}
