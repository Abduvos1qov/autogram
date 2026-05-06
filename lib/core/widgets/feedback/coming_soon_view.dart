import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class ComingSoonView extends StatelessWidget {
  final IconData icon;
  final String? message;

  const ComingSoonView({
    super.key,
    this.icon = Icons.construction_outlined,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: AppColors.textSecondaryOf(context),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tez orada',
              style: AppTypography.headlineMedium(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message ?? 'Bu bo\'lim ustida ish olib borilmoqda.',
              style: AppTypography.bodyMedium(context).copyWith(
                color: AppColors.textSecondaryOf(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
