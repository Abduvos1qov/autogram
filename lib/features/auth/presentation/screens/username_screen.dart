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

/// Username selection screen - shown after email verification

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text.trim();
      final cleanUsername =
          username.startsWith('@') ? username.substring(1) : username;
      context.read<AuthBloc>().add(AuthUsernameSubmitted(cleanUsername));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/');
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    // Title
                    Text(
                      'Username tanlang',
                      style: AppTypography.displayMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    AppSpacing.gapVerticalSm,

                    Text(
                      'Boshqa foydalanuvchilar sizni shu nom bilan topishi mumkin',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Username input
                    AppTextField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'username',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          '@',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      validator: Validators.validateUsernameRequired,
                      onEditingComplete: _submit,
                      autofocus: true,
                    ),

                    AppSpacing.gapVerticalSm,

                    Text(
                      'Faqat harflar, raqamlar va pastki chiziq. Kamida 3 belgi.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const Spacer(),

                    // Continue button
                    PrimaryButton(
                      text: 'Davom etish',
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                      height: 52,
                    ),

                    const SizedBox(height: 32),
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
