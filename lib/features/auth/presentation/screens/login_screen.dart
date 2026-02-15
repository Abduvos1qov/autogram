import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/test_config.dart';
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

/// Login screen - email input

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthOtpRequested(_emailController.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          context.push('/otp', extra: state.email);
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
          body: SafeArea(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.gapVerticalXl,

                    // Header
                    Text(
                      'Xush kelibsiz!',
                      style: AppTypography.displaySmall,
                    ),
                    AppSpacing.gapVerticalSm,
                    Text(
                      'Davom etish uchun email manzilingizni kiriting',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    AppSpacing.gapVerticalXl,
                    AppSpacing.gapVerticalLg,

                    // Email input
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'email@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: Validators.validateEmailRequired,
                      autofocus: true,
                      onEditingComplete: _submitEmail,
                    ),

                    AppSpacing.gapVerticalXl,

                    // Submit button
                    PrimaryButton(
                      text: 'Davom etish',
                      onPressed: isLoading ? null : _submitEmail,
                      isLoading: isLoading,
                    ),

                    // Test mode helper
                    if (TestConfig.isTestMode) ...[
                      AppSpacing.gapVerticalLg,
                      Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppColors.warning,
                                ),
                                AppSpacing.gapHorizontalSm,
                                Text(
                                  'Test rejimi',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.gapVerticalSm,
                            Text(
                              'Sinov uchun email: ${TestConfig.testEmailList.first}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'OTP kodi: 123456',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Terms
                    Center(
                      child: Padding(
                        padding: AppSpacing.paddingMd,
                        child: Text(
                          'Davom etish orqali siz Foydalanish shartlari va Maxfiylik siyosatiga rozilik bildirasiz',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
