import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable horizontal stepper for selecting an integer seat quantity.
///
/// Renders a `[-]  N  [+]` row with min/max constraints. Buttons are disabled
/// at the bounds. The widget owns no state — the parent passes [value] and
/// receives every change via [onChanged].
class SeatQuantitySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;

  const SeatQuantitySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 100,
  })  : assert(minValue >= 0),
        assert(maxValue >= minValue);

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > minValue;
    final canIncrement = value < maxValue;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerOf(context),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: AppColors.borderOf(context),
          width: AppSpacing.borderWidthThin,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            enabled: canDecrement,
            onPressed: () => onChanged(value - 1),
          ),
          AppSpacing.gapHorizontalMd,
          SizedBox(
            width: 48,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge(context).copyWith(
                fontWeight: AppTypography.semiBold,
              ),
            ),
          ),
          AppSpacing.gapHorizontalMd,
          _StepperButton(
            icon: Icons.add,
            enabled: canIncrement,
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? AppColors.primaryOf(context)
        : AppColors.textDisabledOf(context);

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: AppSpacing.borderWidthThin),
          ),
          child: Icon(icon, size: AppSpacing.iconSm, color: color),
        ),
      ),
    );
  }
}
