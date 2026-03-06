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

/// Forgot password screen - send reset email

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetSent = false;
  String? _sentEmail;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthResetPasswordRequested(_emailController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          setState(() {
            _resetSent = true;
            _sentEmail = state.email;
          });
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
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _resetSent
                  ? _buildSuccessContent()
                  : _buildFormContent(isLoading),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormContent(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Title
          Text(
            'Parolni tiklash',
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          AppSpacing.gapVerticalSm,

          Text(
            'Email manzilingizni kiriting, biz sizga parolni tiklash havolasini yuboramiz',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 40),

          // Email input
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'email@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.validateEmailRequired,
            autofocus: true,
            onEditingComplete: _submit,
          ),

          const SizedBox(height: 32),

          // Submit button
          PrimaryButton(
            text: 'Havolani yuborish',
            onPressed: isLoading ? null : _submit,
            isLoading: isLoading,
            height: 52,
          ),

          const SizedBox(height: 24),

          // Back to login
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Kirishga qaytish',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        const Spacer(flex: 1),

        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 40,
            color: AppColors.success,
          ),
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          'Email yuborildi!',
          style: AppTypography.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        AppSpacing.gapVerticalMd,

        // Subtitle
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Parolni tiklash havolasi '),
              TextSpan(
                text: _sentEmail ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(text: ' manziliga yuborildi'),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Back to login
        PrimaryButton(
          text: 'Kirishga qaytish',
          onPressed: () => context.go('/login'),
          height: 52,
        ),

        const Spacer(flex: 2),
      ],
    );
  }
}
