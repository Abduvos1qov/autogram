import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../navigation/route_names.dart';
import '../bloc/seller_bloc.dart';
import '../bloc/seller_event.dart';
import '../bloc/seller_state.dart';
import '../widgets/step_progress_bar.dart';

/// Business info screen - Step 2: Enter business details

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
    if (_formKey.currentState?.validate() ?? false) {
      final phones = _phoneController.text.trim().isNotEmpty
          ? [_phoneController.text.trim()]
          : <String>[];

      context.read<SellerBloc>().add(
            SellerBusinessInfoUpdated(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerBloc, SellerState>(
      listenWhen: (previous, current) =>
          previous.currentStep != current.currentStep,
      listener: (context, state) {
        if (state.currentStep == 2) {
          context.push(RoutePaths.upgradePlanSelection);
        }
      },
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
                          // Progress indicator
                          const StepProgressBar(currentStep: 1),
                          AppSpacing.gapVerticalXl,

                          // Header
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

                          // Business name
                          AppTextField(
                            controller: _businessNameController,
                            label: 'seller.business_info_screen.business_name_label'.tr(),
                            hint: 'seller.business_info_screen.business_name_hint'.tr(),
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.business_outlined),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'seller.business_info_screen.business_name_required'.tr();
                              }
                              if (value.trim().length < 3) {
                                return 'seller.business_info_screen.business_name_min_length'.tr();
                              }
                              return null;
                            },
                            autofocus: true,
                          ),
                          AppSpacing.gapVerticalLg,

                          // Description
                          AppTextField(
                            controller: _descriptionController,
                            label: 'seller.business_info_screen.description_label'.tr(),
                            hint: 'seller.business_info_screen.description_hint'.tr(),
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.description_outlined),
                          ),
                          AppSpacing.gapVerticalLg,

                          // City
                          AppTextField(
                            controller: _cityController,
                            label: 'seller.business_info_screen.city_label'.tr(),
                            hint: 'seller.business_info_screen.city_hint'.tr(),
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.location_city_outlined),
                          ),
                          AppSpacing.gapVerticalLg,

                          // Address
                          AppTextField(
                            controller: _addressController,
                            label: 'seller.business_info_screen.address_label'.tr(),
                            hint: 'seller.business_info_screen.address_hint'.tr(),
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.location_on_outlined),
                          ),
                          AppSpacing.gapVerticalLg,

                          // Phone
                          AppTextField(
                            controller: _phoneController,
                            label: 'seller.business_info_screen.phone_label'.tr(),
                            hint: 'seller.business_info_screen.phone_hint'.tr(),
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
                  child: PrimaryButton(
                    text: 'seller.business_info_screen.submit'.tr(),
                    onPressed: _continue,
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
