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

/// Login screen - email + password sign in

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthSignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/');
        } else if (state is AuthNeedsUsername) {
          context.go('/username');
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    // Logo
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        AppSpacing.gapHorizontalSm,
                        Text(
                          'Autogram',
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Hisobingizga\nkiring',
                      style: AppTypography.displayMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.gapVerticalSm,
                    Text(
                      'Kirish uchun email va parolingizni kiriting',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Email field
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'email@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validateEmailRequired,
                      autofocus: true,
                    ),

                    AppSpacing.gapVerticalLg,

                    // Password field
                    AppTextField(
                      controller: _passwordController,
                      label: 'Parol',
                      hint: 'Parolingizni kiriting',
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.grey500,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Parolni kiriting';
                        }
                        return null;
                      },
                      onEditingComplete: _submit,
                    ),

                    AppSpacing.gapVerticalSm,

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Parolni unutdingizmi?',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login button
                    PrimaryButton(
                      text: 'Kirish',
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                      height: 52,
                    ),

                    // Test mode helper
                    if (TestConfig.isTestMode) ...[
                      AppSpacing.gapVerticalLg,
                      Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
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
                              'Email: ${TestConfig.testEmailList.first}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Parol: Test1234!',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Yoki',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sign up link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hisobingiz yo\'qmi? ',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/register'),
                            child: Text(
                              'Ro\'yxatdan o\'tish',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
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
