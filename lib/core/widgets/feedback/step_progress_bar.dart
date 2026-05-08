import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Reusable step progress bar for multi-step flows.
///
/// Renders a row of equal-width pills, where steps `[0..currentStep]` are
/// painted with [AppColors.primary] and remaining steps with [AppColors.grey200].
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? AppColors.primary
                  : AppColors.grey200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
