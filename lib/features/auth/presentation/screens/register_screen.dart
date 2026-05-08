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
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Register screen - sign up with email + password

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _nameController.text.trim(),
              phone: _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
              dateOfBirth: _selectedDate,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSignUpSuccess) {
          context.push('/verification', extra: state.email);
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
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'auth.register_screen.title'.tr(),
                      style: AppTypography.displayMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.gapVerticalSm,
                    Text(
                      'auth.register_screen.subtitle'.tr(),
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Full Name
                    AppTextField(
                      controller: _nameController,
                      label: 'auth.register_screen.full_name_label'.tr(),
                      hint: 'auth.register_screen.full_name_hint'.tr(),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validateName,
                      autofocus: true,
                    ),

                    AppSpacing.gapVerticalLg,

                    // Email
                    AppTextField(
                      controller: _emailController,
                      label: 'auth.register_screen.email_label'.tr(),
                      hint: 'auth.register_screen.email_hint'.tr(),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validateEmailRequired,
                    ),

                    AppSpacing.gapVerticalLg,

                    // Date of Birth (optional)
                    AppTextField(
                      controller: _dobController,
                      label: 'auth.register_screen.dob_label'.tr(),
                      hint: 'auth.register_screen.dob_hint'.tr(),
                      readOnly: true,
                      onTap: _selectDate,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.grey500,
                        ),
                        onPressed: _selectDate,
                      ),
                    ),

                    AppSpacing.gapVerticalLg,

                    // Phone Number (optional)
                    AppTextField(
                      controller: _phoneController,
                      label: 'auth.register_screen.phone_label'.tr(),
                      hint: 'auth.register_screen.phone_hint'.tr(),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      // Static country flag — Phase 1 only supports Uzbekistan,
                      // so we deliberately render no chevron / picker affordance.
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 12, right: 8),
                        child: Text(
                          '🇺🇿',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      validator: Validators.validatePhone,
                    ),

                    AppSpacing.gapVerticalLg,

                    // Password
                    AppTextField(
                      controller: _passwordController,
                      label: 'auth.register_screen.password_label'.tr(),
                      hint: 'auth.register_screen.password_hint'.tr(),
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
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
                      validator: Validators.validatePassword,
                    ),

                    AppSpacing.gapVerticalLg,

                    // Confirm Password
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: 'auth.register_screen.confirm_password_label'.tr(),
                      hint: 'auth.register_screen.confirm_password_hint'.tr(),
                      obscureText: _obscureConfirmPassword,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.grey500,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: Validators.validateConfirmPassword(
                        _passwordController.text,
                      ),
                      onEditingComplete: _submit,
                    ),

                    const SizedBox(height: 32),

                    // Register button
                    PrimaryButton(
                      text: 'auth.register_screen.submit'.tr(),
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                      height: 52,
                    ),

                    const SizedBox(height: 24),

                    // Login link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.register_screen.have_account'.tr(),
                            style: AppTypography.bodyMedium(context).copyWith(
                              color: AppColors.textSecondaryOf(context),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              'auth.register_screen.login_link'.tr(),
                              style: AppTypography.bodyMedium(context).copyWith(
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
        ),
        );
      },
    );
  }
}
