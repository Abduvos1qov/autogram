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
import '../../../../core/widgets/inputs/otp_boxes.dart';
import '../bloc/account_settings_bloc.dart';
import '../bloc/account_settings_event.dart';
import '../bloc/account_settings_state.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    context.read<AccountSettingsBloc>().add(const AccountSettingsReset());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitStep1() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AccountSettingsBloc>().add(
          AccountPhoneChangeRequested(
            newPhone: _phoneController.text.trim(),
            currentPassword: _passwordController.text,
          ),
        );
  }

  void _submitOtp(String otp) {
    context.read<AccountSettingsBloc>().add(AccountPhoneOtpVerified(otp: otp));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceOf(context),
        title: Text(
          'change_phone.title'.tr(),
          style: AppTypography.titleMedium(context).copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AccountSettingsBloc, AccountSettingsState>(
          listener: (context, state) {
            if (state.status == AccountSettingsStatus.phoneChanged) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('change_phone.success_message'.tr()),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.pop();
            } else if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.failure?.message ?? 'common.error'.tr(),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final onOtpStep =
                state.status == AccountSettingsStatus.phoneChangeOtpSent ||
                    state.status == AccountSettingsStatus.phoneChangeVerifying;
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: onOtpStep ? _buildOtpStep(state) : _buildPhoneStep(state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhoneStep(AccountSettingsState state) {
    final isLoading =
        state.status == AccountSettingsStatus.phoneChangeRequesting;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'change_phone.step_phone_title'.tr(),
            style: AppTypography.titleSmall(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _phoneController,
            label: 'change_phone.new_phone_label'.tr(),
            hint: 'change_phone.new_phone_hint'.tr(),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'change_phone.phone_invalid'.tr();
              }
              return Validators.validatePhone(v.trim()) == null
                  ? null
                  : 'change_phone.phone_invalid'.tr();
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _passwordController,
            label: 'change_phone.current_password_label'.tr(),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'change_password.password_too_short'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            text: 'common.continue'.tr(),
            onPressed: isLoading ? null : _submitStep1,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(AccountSettingsState state) {
    final isLoading =
        state.status == AccountSettingsStatus.phoneChangeVerifying;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'change_phone.step_otp_title'.tr(),
          style: AppTypography.titleSmall(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          state.pendingPhone ?? '',
          style: AppTypography.bodyMedium(context).copyWith(
            color: AppColors.textSecondaryOf(context),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        OtpBoxes(
          onCompleted: _submitOtp,
          enabled: !isLoading,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
