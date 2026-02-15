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
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Register screen - new user profile completion

class RegisterScreen extends StatefulWidget {
  final String email;

  const RegisterScreen({
    super.key,
    required this.email,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthCompleteProfileRequested(
              email: widget.email,
              fullName: _nameController.text.trim(),
              phone: _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorHandler.getUserMessage(state.failure)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.gapVerticalMd,

                    // Header
                    Text(
                      'Ro\'yxatdan o\'tish',
                      style: AppTypography.displaySmall,
                    ),
                    AppSpacing.gapVerticalSm,
                    Text(
                      'Ma\'lumotlaringizni kiriting',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    AppSpacing.gapVerticalXl,
                    AppSpacing.gapVerticalLg,

                    // Name input
                    AppTextField(
                      controller: _nameController,
                      label: 'To\'liq ism',
                      hint: 'Ismingizni kiriting',
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: Validators.validateName,
                      autofocus: true,
                    ),

                    AppSpacing.gapVerticalLg,

                    // Phone input (optional)
                    AppTextField(
                      controller: _phoneController,
                      label: 'Telefon raqami (ixtiyoriy)',
                      hint: '+998 XX XXX XX XX',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: Validators.validatePhone,
                      onEditingComplete: _submit,
                    ),

                    AppSpacing.gapVerticalXl,
                    AppSpacing.gapVerticalLg,

                    // Email display (verified)
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            color: AppColors.textSecondary,
                          ),
                          AppSpacing.gapHorizontalMd,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                widget.email,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.gapVerticalXl,

                    // Submit button
                    PrimaryButton(
                      text: 'Ro\'yxatdan o\'tish',
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
