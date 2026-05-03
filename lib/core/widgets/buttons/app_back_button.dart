import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';

/// Circular back button with subtle border for screens that don't use AppBar.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: CircleBorder(
        side: BorderSide(color: AppColors.grey200, width: 1),
      ),
      child: InkWell(
        onTap: onPressed ?? () => context.pop(),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
      ),
    );
  }
}
