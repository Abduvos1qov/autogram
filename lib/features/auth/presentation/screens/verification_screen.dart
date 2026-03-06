import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';

/// Email verification screen - shown after sign up

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = 60;
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

  void _resendEmail() {
    if (_canResend) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tasdiqlash emaili qayta yuborildi'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Email icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Emailingizni tekshiring',
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
                    const TextSpan(
                        text: 'Tasdiqlash havolasini '),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(text: ' manziliga yubordik'),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Continue to login button
              PrimaryButton(
                text: 'Kirishga o\'tish',
                onPressed: () => context.go('/login'),
                height: 52,
              ),

              AppSpacing.gapVerticalLg,

              // Resend
              _canResend
                  ? TextButton(
                      onPressed: _resendEmail,
                      child: Text(
                        'Emailni qayta yuborish',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Text(
                      'Qayta yuborish: ${_remainingSeconds}s',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
