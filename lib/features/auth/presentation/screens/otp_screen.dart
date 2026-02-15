import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/otp_input.dart';

/// OTP verification screen

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = AppConfig.otpResendDelay.inSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = AppConfig.otpResendDelay.inSeconds;
    _canResend = false;
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

  void _resendOtp() {
    if (_canResend) {
      context.read<AuthBloc>().add(AuthOtpResendRequested(widget.email));
      _startTimer();
    }
  }

  void _verifyOtp(String code) {
    if (code.length == AppConfig.otpLength) {
      context.read<AuthBloc>().add(
            AuthOtpVerified(email: widget.email, code: code),
          );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthNeedsRegistration) {
          context.push('/register', extra: state.email);
        } else if (state is AuthOtpResent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kod qayta yuborildi'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorHandler.getUserMessage(state.failure)),
              backgroundColor: AppColors.error,
            ),
          );
          _otpController.clear();
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
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapVerticalMd,

                  // Header
                  Text(
                    'Kodni kiriting',
                    style: AppTypography.displaySmall,
                  ),
                  AppSpacing.gapVerticalSm,
                  RichText(
                    text: TextSpan(
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'Tasdiqlash kodi '),
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const TextSpan(text: ' manziliga yuborildi'),
                      ],
                    ),
                  ),

                  AppSpacing.gapVerticalXl,
                  AppSpacing.gapVerticalLg,

                  // OTP Input
                  OtpInput(
                    controller: _otpController,
                    length: AppConfig.otpLength,
                    onCompleted: _verifyOtp,
                    enabled: !isLoading,
                  ),

                  AppSpacing.gapVerticalXl,

                  // Verify button
                  PrimaryButton(
                    text: 'Tasdiqlash',
                    onPressed: isLoading
                        ? null
                        : () => _verifyOtp(_otpController.text),
                    isLoading: isLoading,
                  ),

                  AppSpacing.gapVerticalLg,

                  // Resend
                  Center(
                    child: _canResend
                        ? TextButton(
                            onPressed: _resendOtp,
                            child: const Text('Kodni qayta yuborish'),
                          )
                        : Text(
                            'Qayta yuborish: $_formattedTime',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
