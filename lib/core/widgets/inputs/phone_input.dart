import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Phone number input with Uzbekistan prefix

class PhoneInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool autofocus;

  const PhoneInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.focusNode,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium(context).copyWith(
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          AppSpacing.gapVerticalSm,
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          autofocus: autofocus,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          style: AppTypography.bodyLarge(context),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
            _PhoneNumberFormatter(),
          ],
          decoration: InputDecoration(
            hintText: hint ?? 'XX XXX XX XX',
            errorText: errorText,
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Uzbekistan flag emoji
                  const Text(
                    '🇺🇿',
                    style: TextStyle(fontSize: 20),
                  ),
                  AppSpacing.gapHorizontalSm,
                  Text(
                    AppConstants.uzbekPhonePrefix,
                    style: AppTypography.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AppSpacing.gapHorizontalSm,
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.grey300,
                  ),
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
          onChanged: (value) {
            final cleanValue = value.replaceAll(' ', '');
            onChanged?.call('${AppConstants.uzbekPhonePrefix}$cleanValue');
          },
          onEditingComplete: onEditingComplete,
          validator: validator,
        ),
      ],
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');

    if (text.isEmpty) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i == 2 || i == 5 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
