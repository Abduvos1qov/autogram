import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../bloc/seller_bloc.dart';
import '../bloc/seller_event.dart';
import '../bloc/seller_state.dart';

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
      listener: (context, state) {
        if (state.currentStep == 2) {
          context.push('/upgrade/plan-selection');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('Biznes ma\'lumotlari'),
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
                          _buildProgressIndicator(1),
                          AppSpacing.gapVerticalXl,

                          // Header
                          Text(
                            'Biznes haqida',
                            style: AppTypography.headlineSmall,
                          ),
                          AppSpacing.gapVerticalSm,
                          Text(
                            'Biznesingiz haqida ma\'lumot kiriting',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          AppSpacing.gapVerticalXl,

                          // Business name
                          AppTextField(
                            controller: _businessNameController,
                            label: 'Biznes nomi',
                            hint: 'Masalan: Avtosalon Premium',
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.business_outlined),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Biznes nomini kiriting';
                              }
                              if (value.trim().length < 3) {
                                return 'Nom kamida 3 ta belgidan iborat bo\'lishi kerak';
                              }
                              return null;
                            },
                            autofocus: true,
                          ),
                          AppSpacing.gapVerticalLg,

                          // Description
                          AppTextField(
                            controller: _descriptionController,
                            label: 'Tavsif (ixtiyoriy)',
                            hint: 'Biznesingiz haqida qisqacha',
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.description_outlined),
                          ),
                          AppSpacing.gapVerticalLg,

                          // City
                          AppTextField(
                            controller: _cityController,
                            label: 'Shahar (ixtiyoriy)',
                            hint: 'Masalan: Toshkent',
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.location_city_outlined),
                          ),
                          AppSpacing.gapVerticalLg,

                          // Address
                          AppTextField(
                            controller: _addressController,
                            label: 'Manzil (ixtiyoriy)',
                            hint: 'Aniq manzil',
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.location_on_outlined),
                          ),
                          AppSpacing.gapVerticalLg,

                          // Phone
                          AppTextField(
                            controller: _phoneController,
                            label: 'Telefon raqami (ixtiyoriy)',
                            hint: '+998 90 123 45 67',
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
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: PrimaryButton(
                    text: 'Davom etish',
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

  Widget _buildProgressIndicator(int step) {
    return Row(
      children: List.generate(3, (index) {
        final isCompleted = index < step;
        final isCurrent = index == step;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
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
