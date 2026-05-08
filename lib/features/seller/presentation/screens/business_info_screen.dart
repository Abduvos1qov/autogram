import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../navigation/route_names.dart';
import '../../../payment/domain/entities/payment_request.dart';
import '../../../payment/presentation/bloc/payment_bloc.dart';
import '../../../payment/presentation/bloc/payment_state.dart';
import '../../domain/entities/seller_profile.dart';
import '../bloc/seller_bloc.dart';
import '../bloc/seller_event.dart';
import '../bloc/seller_state.dart';
import '../widgets/business_type_selector.dart';
import '../widgets/step_progress_bar.dart';

/// Business info screen — Step 2 (final step) of the seller upgrade flow.
///
/// Collects business name + business type + optional details, then forks by
/// the plan picked on the previous screen:
///  - Free → fires `SellerUpgradeRequested` directly.
///  - Pro / Premium → pushes [PaymentScreen]; the [PaymentBloc] listener
///    below fires `SellerUpgradeRequested` once payment succeeds.
///  - Enterprise is intercepted on the plan picker and never reaches here.

class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({super.key});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  BusinessType _businessType = BusinessType.individual;

  // Guards the PaymentBloc listener: true only while we are actively waiting
  // for a payment round-trip we initiated from this screen. Prevents stale
  // PaymentSuccess from triggering a phantom upgrade if the user backs out
  // of payment and submits again later.
  bool _paymentLaunched = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phones = _phoneController.text.trim().isNotEmpty
        ? [_phoneController.text.trim()]
        : <String>[];

    final bloc = context.read<SellerBloc>();
    bloc.add(
      SellerBusinessInfoUpdated(
        businessType: _businessType,
        businessName: _businessNameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        contactPhones: phones.isNotEmpty ? phones : null,
      ),
    );

    final plan = bloc.state.selectedPlan;
    final billingCycle = bloc.state.selectedBillingCycle;
    if (plan == null) {
      // No plan picked — shouldn't happen because the picker is the only
      // entry point. Send the user back rather than making an upgrade call
      // that would fail on canCompleteUpgrade.
      context.go(RoutePaths.upgrade);
      return;
    }

    if (plan == SubscriptionPlan.free) {
      bloc.add(const SellerUpgradeRequested());
      return;
    }

    // Pro / Premium → checkout. Listener below fires SellerUpgradeRequested
    // when PaymentBloc emits PaymentSuccess.
    setState(() => _paymentLaunched = true);
    final request = PaymentRequest.subscription(
      plan: plan,
      billingCycle: billingCycle,
    );
    context.push(RoutePaths.payment, extra: request);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SellerBloc, SellerState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
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
          listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
          listener: (context, state) {
            if (state is PaymentSuccess && _paymentLaunched) {
              _paymentLaunched = false;
              context.read<SellerBloc>().add(const SellerUpgradeRequested());
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
              title: Text('seller.business_info_screen.app_bar_title'.tr()),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppSpacing.screenPadding,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const StepProgressBar(
                              currentStep: 1,
                              totalSteps: 2,
                            ),
                            AppSpacing.gapVerticalXl,
                            Text(
                              'seller.business_info_screen.title'.tr(),
                              style: AppTypography.headlineSmall(context),
                            ),
                            AppSpacing.gapVerticalSm,
                            Text(
                              'seller.business_info_screen.subtitle'.tr(),
                              style: AppTypography.bodyMedium(context).copyWith(
                                color: AppColors.textSecondaryOf(context),
                              ),
                            ),
                            AppSpacing.gapVerticalXl,
                            Text(
                              'seller.business_info_screen.business_type_label'
                                  .tr(),
                              style: AppTypography.labelMedium(
                                context,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            AppSpacing.gapVerticalSm,
                            BusinessTypeSelector(
                              selected: _businessType,
                              onChanged: (type) =>
                                  setState(() => _businessType = type),
                            ),
                            AppSpacing.gapVerticalLg,
                            AppTextField(
                              controller: _businessNameController,
                              label:
                                  'seller.business_info_screen.business_name_label'
                                      .tr(),
                              hint:
                                  'seller.business_info_screen.business_name_hint'
                                      .tr(),
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(Icons.business_outlined),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'seller.business_info_screen.business_name_required'
                                      .tr();
                                }
                                if (value.trim().length < 3) {
                                  return 'seller.business_info_screen.business_name_min_length'
                                      .tr();
                                }
                                return null;
                              },
                            ),
                            AppSpacing.gapVerticalLg,
                            AppTextField(
                              controller: _descriptionController,
                              label:
                                  'seller.business_info_screen.description_label'
                                      .tr(),
                              hint:
                                  'seller.business_info_screen.description_hint'
                                      .tr(),
                              maxLines: 3,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(
                                Icons.description_outlined,
                              ),
                            ),
                            AppSpacing.gapVerticalLg,
                            AppTextField(
                              controller: _cityController,
                              label: 'seller.business_info_screen.city_label'
                                  .tr(),
                              hint: 'seller.business_info_screen.city_hint'
                                  .tr(),
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(
                                Icons.location_city_outlined,
                              ),
                            ),
                            AppSpacing.gapVerticalLg,
                            AppTextField(
                              controller: _addressController,
                              label: 'seller.business_info_screen.address_label'
                                  .tr(),
                              hint: 'seller.business_info_screen.address_hint'
                                  .tr(),
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                              ),
                            ),
                            AppSpacing.gapVerticalLg,
                            AppTextField(
                              controller: _phoneController,
                              label: 'seller.business_info_screen.phone_label'
                                  .tr(),
                              hint: 'seller.business_info_screen.phone_hint'
                                  .tr(),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              prefixIcon: const Icon(Icons.phone_outlined),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  return Validators.validatePhone(value);
                                }
                                return null;
                              },
                            ),
                            AppSpacing.gapVerticalXl,
                          ],
                        ),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.selectedPlan != null &&
                            state.selectedPlan != SubscriptionPlan.free)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: Text(
                              'seller.plan_selection.next_payment_notice'.tr(),
                              style: AppTypography.bodySmall(context).copyWith(
                                color: AppColors.textSecondaryOf(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        PrimaryButton(
                          text: 'seller.business_info_screen.submit'.tr(),
                          onPressed: state.isUpgrading ? null : _continue,
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
}
