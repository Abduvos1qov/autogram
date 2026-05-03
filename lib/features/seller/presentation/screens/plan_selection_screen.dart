import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../domain/entities/seller_profile.dart';
import '../bloc/seller_bloc.dart';
import '../bloc/seller_event.dart';
import '../bloc/seller_state.dart';
import '../widgets/plan_card.dart';
import '../widgets/step_progress_bar.dart';

/// Plan selection screen - Step 3: Choose subscription plan

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  SubscriptionPlan? _selectedPlan;

  @override
  void initState() {
    super.initState();
    context.read<SellerBloc>().add(const SellerPlansLoadRequested());
    _selectedPlan = SubscriptionPlan.free;
  }

  void _completeUpgrade() {
    if (_selectedPlan != null) {
      context.read<SellerBloc>().add(SellerPlanSelected(_selectedPlan!));
      context.read<SellerBloc>().add(const SellerUpgradeRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerBloc, SellerState>(
      listenWhen: (previous, current) =>
          previous.status != current.status,
      listener: (context, state) {
        if (state.isUpgraded) {
          context.go('/upgrade/success');
        } else if (state.hasError && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorHandler.getUserMessage(state.failure!)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('Tarif tanlash'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress indicator
                        const StepProgressBar(currentStep: 2),
                        AppSpacing.gapVerticalXl,

                        // Header
                        Text(
                          'Tarifni tanlang',
                          style: AppTypography.headlineSmall(context),
                        ),
                        AppSpacing.gapVerticalSm,
                        Text(
                          'Keyinroq tarifni o\'zgartirishingiz mumkin',
                          style: AppTypography.bodyMedium(context).copyWith(
                            color: AppColors.textSecondaryOf(context),
                          ),
                        ),
                        AppSpacing.gapVerticalXl,

                        // Plans
                        if (state.plans.isEmpty)
                          const Center(child: LoadingIndicator())
                        else
                          ...state.plans.map((plan) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: PlanCard(
                                plan: plan,
                                isSelected: _selectedPlan == plan.plan,
                                isCurrent: false,
                                onTap: () {
                                  setState(() {
                                    _selectedPlan = plan.plan;
                                  });
                                },
                              ),
                            );
                          }),
                        AppSpacing.gapVerticalMd,

                        // Info text
                        Container(
                          padding: AppSpacing.paddingMd,
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                                size: 20,
                              ),
                              AppSpacing.gapHorizontalSm,
                              Expanded(
                                child: Text(
                                  'Bepul tarifdan boshlang va kerak bo\'lganda yangilang',
                                  style: AppTypography.bodySmall(context).copyWith(
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.gapVerticalXl,
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: AppSpacing.screenPadding,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_selectedPlan != null &&
                          _selectedPlan != SubscriptionPlan.free)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Keyingi sahifada to\'lovni amalga oshirasiz',
                            style: AppTypography.bodySmall(context).copyWith(
                              color: AppColors.textSecondaryOf(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      PrimaryButton(
                        text: _selectedPlan == SubscriptionPlan.free
                            ? 'Bepul boshlash'
                            : 'Davom etish',
                        onPressed: state.isUpgrading ? null : _completeUpgrade,
                        isLoading: state.isUpgrading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
