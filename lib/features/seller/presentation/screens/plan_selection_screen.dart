import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../../../navigation/route_names.dart';
import '../../../payment/domain/entities/billing_cycle.dart';
import '../../../payment/domain/entities/payment_request.dart';
import '../../../payment/presentation/bloc/payment_bloc.dart';
import '../../../payment/presentation/bloc/payment_state.dart';
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
  BillingCycle _billingCycle = BillingCycle.monthly;

  @override
  void initState() {
    super.initState();
    context.read<SellerBloc>().add(const SellerPlansLoadRequested());
    // Recommended default for conversion — user can downgrade to Free if desired.
    _selectedPlan = SubscriptionPlan.pro;
  }

  void _completeUpgrade() {
    if (_selectedPlan == null) return;

    // Persist selection in seller bloc — keeps state consistent across the
    // payment round-trip and lets _onUpgradeRequested read it post-payment.
    context.read<SellerBloc>().add(SellerPlanSelected(_selectedPlan!));

    if (_selectedPlan == SubscriptionPlan.free) {
      // Free tier — no payment, upgrade immediately.
      context.read<SellerBloc>().add(const SellerUpgradeRequested());
    } else if (_selectedPlan == SubscriptionPlan.enterprise) {
      // Enterprise — pricing is contract-based, route to contact flow.
      _showEnterpriseContactDialog();
    } else {
      // Paid (Pro / Premium) — route through the payment screen.
      // PaymentBloc state is observed by [_handlePaymentSuccess] via
      // BlocListener<PaymentBloc> so the upgrade request fires automatically
      // after a successful payment.
      final request = PaymentRequest.subscription(
        plan: _selectedPlan!,
        billingCycle: _billingCycle,
      );
      context.push(RoutePaths.payment, extra: request);
    }
  }

  void _handlePaymentSuccess() {
    // Payment finished — promote the user to seller using the plan that was
    // already persisted via SellerPlanSelected before the payment round-trip.
    context.read<SellerBloc>().add(const SellerUpgradeRequested());
  }

  void _showEnterpriseContactDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('seller.plan_selection.enterprise_dialog_title'.tr()),
        content: Text(
          'seller.plan_selection.enterprise_dialog_message'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('seller.plan_selection.enterprise_dialog_close'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO(enterprise): Replace with Telegram bot link or sales email.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'seller.plan_selection.enterprise_contact_placeholder'.tr(),
                  ),
                ),
              );
            },
            child: Text('seller.plan_selection.enterprise_dialog_contact'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SellerBloc, SellerState>(
          listenWhen: (previous, current) =>
              previous.status != current.status,
          listener: (context, state) {
            if (state.isUpgraded) {
              context.go(RoutePaths.upgradeSuccess);
            } else if (state.hasError && state.failure != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ErrorHandler.getUserMessage(state.failure!)),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
        BlocListener<PaymentBloc, PaymentState>(
          listenWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
          listener: (context, state) {
            if (state is PaymentSuccess) {
              _handlePaymentSuccess();
            }
          },
        ),
      ],
      child: BlocBuilder<SellerBloc, SellerState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: Text('seller.plan_selection.app_bar_title'.tr()),
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
                            'seller.plan_selection.title'.tr(),
                            style: AppTypography.headlineSmall(context),
                          ),
                          AppSpacing.gapVerticalSm,
                          Text(
                            'seller.plan_selection.subtitle'.tr(),
                            style: AppTypography.bodyMedium(context).copyWith(
                              color: AppColors.textSecondaryOf(context),
                            ),
                          ),
                          AppSpacing.gapVerticalLg,

                          // Billing cycle toggle
                          Center(
                            child: SegmentedButton<BillingCycle>(
                              segments: [
                                ButtonSegment(
                                  value: BillingCycle.monthly,
                                  label: Text(
                                    'seller.plan_selection.billing_monthly'.tr(),
                                  ),
                                ),
                                ButtonSegment(
                                  value: BillingCycle.yearly,
                                  label: Text(
                                    'seller.plan_selection.billing_yearly'.tr(),
                                  ),
                                ),
                              ],
                              selected: {_billingCycle},
                              onSelectionChanged: (set) {
                                setState(() => _billingCycle = set.first);
                              },
                            ),
                          ),
                          AppSpacing.gapVerticalLg,

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
                                  billingCycle: _billingCycle,
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
                                    'seller.plan_selection.info_text'.tr(),
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
                      color: AppColors.surfaceOf(context),
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
                            _selectedPlan != SubscriptionPlan.free &&
                            _selectedPlan != SubscriptionPlan.enterprise)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'seller.plan_selection.next_payment_notice'.tr(),
                              style: AppTypography.bodySmall(context).copyWith(
                                color: AppColors.textSecondaryOf(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        PrimaryButton(
                          text: _buttonLabel(),
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
      ),
    );
  }

  String _buttonLabel() {
    switch (_selectedPlan) {
      case SubscriptionPlan.free:
        return 'seller.plan_selection.free_button'.tr();
      case SubscriptionPlan.enterprise:
        return 'seller.plan_selection.enterprise_button'.tr();
      case SubscriptionPlan.pro:
      case SubscriptionPlan.premium:
      case null:
        return 'seller.plan_selection.default_button'.tr();
    }
  }
}
