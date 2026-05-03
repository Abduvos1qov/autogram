import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/buttons/secondary_button.dart';

/// Success screen shown after completing seller upgrade

class UpgradeSuccessScreen extends StatefulWidget {
  const UpgradeSuccessScreen({super.key});

  @override
  State<UpgradeSuccessScreen> createState() => _UpgradeSuccessScreenState();
}

class _UpgradeSuccessScreenState extends State<UpgradeSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Animated success icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: AppColors.success,
                    ),
                  ),
                ),
                AppSpacing.gapVerticalXl,
                // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Tabriklaymiz!',
                    style: AppTypography.displaySmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                AppSpacing.gapVerticalMd,
                // Subtitle
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Siz endi Autogram sotuvchisisiz.\nE\'lonlaringizni joylashni boshlang!',
                    style: AppTypography.bodyLarge(context).copyWith(
                      color: AppColors.textSecondaryOf(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(flex: 3),
                // Buttons
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      PrimaryButton(
                        text: 'Bosh sahifaga',
                        onPressed: () => context.go('/'),
                      ),
                      AppSpacing.gapVerticalMd,
                      SecondaryButton(
                        text: 'Profilga qaytish',
                        onPressed: () => context.go('/profile'),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapVerticalXl,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
