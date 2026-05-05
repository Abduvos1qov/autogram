import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            title,
            style: AppTypography.labelSmallStyle.copyWith(
              color: AppColors.textTertiaryOf(context),
              fontWeight: AppTypography.semiBold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Column(children: _interleaveDividers(context, tiles)),
        const SizedBox(height: AppSpacing.xs),
        Divider(
          height: 1,
          thickness: 0.5,
          color: AppColors.dividerOf(context),
        ),
      ],
    );
  }

  List<Widget> _interleaveDividers(BuildContext context, List<Widget> items) {
    if (items.length <= 1) return items;
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i != items.length - 1) {
        result.add(
          Padding(
            padding: const EdgeInsets.only(left: 72, right: AppSpacing.lg),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.dividerOf(context),
            ),
          ),
        );
      }
    }
    return result;
  }
}
