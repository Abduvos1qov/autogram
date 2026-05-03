import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Search input field

class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool enabled;
  final bool autofocus;
  final bool readOnly;
  final Widget? trailing;

  const SearchField({
    super.key,
    this.controller,
    this.hint,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.enabled = true,
    this.autofocus = false,
    this.readOnly = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.inputHeightMd,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(
              Icons.search,
              color: AppColors.grey500,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              autofocus: autofocus,
              readOnly: readOnly,
              textInputAction: TextInputAction.search,
              style: AppTypography.bodyMedium(context),
              decoration: InputDecoration(
                hintText: hint ?? 'Qidirish...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onTap: onTap,
            ),
          ),
          if (controller?.text.isNotEmpty == true)
            IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColors.grey500,
                size: 20,
              ),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Clickable search field that navigates to search screen

class SearchFieldButton extends StatelessWidget {
  final String? hint;
  final VoidCallback? onTap;

  const SearchFieldButton({
    super.key,
    this.hint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSpacing.inputHeightMd,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppColors.grey500,
              size: 20,
            ),
            AppSpacing.gapHorizontalSm,
            Text(
              hint ?? 'Qidirish...',
              style: AppTypography.bodyMedium(context).copyWith(
                color: AppColors.textHintOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
