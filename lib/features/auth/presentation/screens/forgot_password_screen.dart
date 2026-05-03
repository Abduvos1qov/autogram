import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Forgot password screen - 3-step OTP flow

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // OTP fields
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Step tracking: 0 = email, 1 = OTP, 2 = new password, 3 = success
  int _currentStep = 0;
  String? _email;

  // Resend timer
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _otpFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _submitEmail() {
    if (_emailFormKey.currentState?.validate() ?? false) {
      _email = _emailController.text.trim();
      context.read<AuthBloc>().add(
            AuthForgotPasswordOtpRequested(_email!),
          );
    }
  }

  String get _otpCode {
    return _otpControllers.map((c) => c.text).join();
  }

  void _submitOtp() {
    final otp = _otpCode;
    if (otp.length == 6 && _email != null) {
      context.read<AuthBloc>().add(
            AuthVerifyForgotPasswordOtpRequested(
              email: _email!,
              otp: otp,
            ),
          );
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
    if (_otpCode.length == 6) {
      _submitOtp();
    }
  }

  void _resendOtp() {
    if (_canResend && _email != null) {
      context.read<AuthBloc>().add(AuthForgotPasswordOtpRequested(_email!));
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tasdiqlash kodi qayta yuborildi'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _submitNewPassword() {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthResetPasswordWithNewPassword(
              email: _email!,
              newPassword: _newPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthForgotPasswordOtpSent) {
          setState(() {
            _currentStep = 1;
          });
          _startTimer();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _otpFocusNodes[0].requestFocus();
          });
        } else if (state is AuthForgotPasswordOtpVerified) {
          setState(() {
            _currentStep = 2;
          });
        } else if (state is AuthPasswordResetSuccess) {
          setState(() {
            _currentStep = 3;
          });
        } else if (state is AuthError) {
          if (_currentStep == 1) {
            // Clear OTP on error
            for (final c in _otpControllers) {
              c.clear();
            }
            _otpFocusNodes[0].requestFocus();
          }
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildCurrentStep(isLoading),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStep(bool isLoading) {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep(isLoading);
      case 1:
        return _buildOtpStep(isLoading);
      case 2:
        return _buildNewPasswordStep(isLoading);
      case 3:
        return _buildSuccessStep();
      default:
        return _buildEmailStep(isLoading);
    }
  }

  Widget _buildEmailStep(bool isLoading) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          Text(
            'Parolni tiklash',
            style: AppTypography.displayMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          AppSpacing.gapVerticalSm,

          Text(
            'Email manzilingizni kiriting, biz sizga tasdiqlash kodini yuboramiz',
            style: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondaryOf(context),
            ),
          ),

          const SizedBox(height: 40),

          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'email@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.validateEmailRequired,
            autofocus: true,
            onEditingComplete: _submitEmail,
          ),

          const SizedBox(height: 32),

          PrimaryButton(
            text: 'Kodni yuborish',
            onPressed: isLoading ? null : _submitEmail,
            isLoading: isLoading,
            height: 52,
          ),

          const SizedBox(height: 24),

          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Kirishga qaytish',
                style: AppTypography.bodyMedium(context).copyWith(
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

  Widget _buildOtpStep(bool isLoading) {
    return Column(
      children: [
        const Spacer(flex: 1),

        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.email_outlined,
            size: 40,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'Tasdiqlash kodi',
          style: AppTypography.displaySmall(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        AppSpacing.gapVerticalMd,

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondaryOf(context),
            ),
            children: [
              const TextSpan(text: 'Tasdiqlash kodini '),
              TextSpan(
                text: _email ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              const TextSpan(text: ' manziliga yubordik'),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // OTP input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Container(
              width: 48,
              height: 56,
              margin: EdgeInsets.only(
                right: index < 5 ? 8 : 0,
              ),
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                enabled: !isLoading,
                style: AppTypography.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.grey300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) => _onOtpChanged(index, value),
              ),
            );
          }),
        ),

        const SizedBox(height: 32),

        PrimaryButton(
          text: 'Tasdiqlash',
          onPressed: isLoading || _otpCode.length < 6 ? null : _submitOtp,
          isLoading: isLoading,
          height: 52,
        ),

        AppSpacing.gapVerticalLg,

        _canResend
            ? TextButton(
                onPressed: _resendOtp,
                child: Text(
                  'Kodni qayta yuborish',
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Text(
                'Qayta yuborish: ${_remainingSeconds}s',
                style: AppTypography.bodyMedium(context).copyWith(
                  color: AppColors.textSecondaryOf(context),
                ),
              ),

        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildNewPasswordStep(bool isLoading) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          Text(
            'Yangi parol',
            style: AppTypography.displayMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          AppSpacing.gapVerticalSm,

          Text(
            'Yangi parolingizni kiriting',
            style: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondaryOf(context),
            ),
          ),

          const SizedBox(height: 40),

          AppTextField(
            controller: _newPasswordController,
            label: 'Yangi parol',
            hint: 'Kuchli parol kiriting',
            obscureText: _obscureNewPassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.grey500,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            validator: Validators.validatePassword,
            autofocus: true,
          ),

          AppSpacing.gapVerticalLg,

          AppTextField(
            controller: _confirmPasswordController,
            label: 'Parolni tasdiqlash',
            hint: 'Parolni qayta kiriting',
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
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: Validators.validateConfirmPassword(
              _newPasswordController.text,
            ),
            onEditingComplete: _submitNewPassword,
          ),

          const SizedBox(height: 32),

          PrimaryButton(
            text: 'Parolni saqlash',
            onPressed: isLoading ? null : _submitNewPassword,
            isLoading: isLoading,
            height: 52,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        const Spacer(flex: 1),

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

        Text(
          'Parol yangilandi!',
          style: AppTypography.displaySmall(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        AppSpacing.gapVerticalMd,

        Text(
          'Parolingiz muvaffaqiyatli yangilandi. Endi yangi parol bilan kirishingiz mumkin.',
          style: AppTypography.bodyMedium(context).copyWith(
            color: AppColors.textSecondaryOf(context),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        PrimaryButton(
          text: 'Kirishga o\'tish',
          onPressed: () => context.go('/login'),
          height: 52,
        ),

        const Spacer(flex: 2),
      ],
    );
  }
}
