import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Username input with format validation (`^[a-z0-9_]{3,30}$`) and an
/// optional async availability check that runs 500ms after the user stops
/// typing. The trailing icon shows status: spinner / check / x.
///
/// Pass [checkAvailability] returning `true` if the username is free, `false`
/// if taken, or `null` to skip the check.
class UsernameField extends StatefulWidget {
  final TextEditingController controller;

  /// The username currently saved on the user — skips the availability check
  /// if the field still matches it (so re-saving without changes doesn't
  /// flag the user's own handle as "taken").
  final String? currentUsername;
  final Future<bool> Function(String username)? checkAvailability;
  final ValueChanged<bool>? onAvailabilityChange;

  const UsernameField({
    super.key,
    required this.controller,
    this.currentUsername,
    this.checkAvailability,
    this.onAvailabilityChange,
  });

  @override
  State<UsernameField> createState() => _UsernameFieldState();
}

enum _Availability { idle, checking, available, taken, invalid }

class _UsernameFieldState extends State<UsernameField> {
  static final RegExp _format = RegExp(r'^[a-z0-9_]{3,30}$');
  Timer? _debounce;
  _Availability _state = _Availability.idle;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final value = widget.controller.text.trim();
    _debounce?.cancel();
    if (value.isEmpty) {
      setState(() => _state = _Availability.idle);
      widget.onAvailabilityChange?.call(false);
      return;
    }
    if (!_format.hasMatch(value)) {
      setState(() => _state = _Availability.invalid);
      widget.onAvailabilityChange?.call(false);
      return;
    }
    if (value == widget.currentUsername) {
      setState(() => _state = _Availability.available);
      widget.onAvailabilityChange?.call(true);
      return;
    }
    if (widget.checkAvailability == null) {
      setState(() => _state = _Availability.available);
      widget.onAvailabilityChange?.call(true);
      return;
    }
    setState(() => _state = _Availability.checking);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final isAvailable = await widget.checkAvailability!(value);
      if (!mounted) return;
      setState(() {
        _state =
            isAvailable ? _Availability.available : _Availability.taken;
      });
      widget.onAvailabilityChange?.call(isAvailable);
    });
  }

  Widget? _buildSuffix() {
    switch (_state) {
      case _Availability.idle:
        return null;
      case _Availability.checking:
        return const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case _Availability.available:
        return const Icon(Icons.check_circle_outline, color: AppColors.success);
      case _Availability.taken:
      case _Availability.invalid:
        return const Icon(Icons.error_outline, color: AppColors.error);
    }
  }

  String? _helperText() {
    switch (_state) {
      case _Availability.taken:
        return 'profile.edit_screen.username_taken'.tr();
      case _Availability.invalid:
        return 'profile.edit_screen.username_invalid'.tr();
      case _Availability.available:
        return widget.controller.text.trim() == widget.currentUsername
            ? null
            : 'profile.edit_screen.username_available'.tr();
      case _Availability.idle:
      case _Availability.checking:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                'profile.edit_screen.username_label'.tr(),
                style: AppTypography.bodyLarge(context).copyWith(
                  fontWeight: AppTypography.medium,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_]')),
                LengthLimitingTextInputFormatter(30),
              ],
              autofillHints: const [AutofillHints.username],
              keyboardType: TextInputType.text,
              style: AppTypography.bodyLarge(context),
              decoration: InputDecoration(
                prefixText: '@',
                hintText: 'profile.edit_screen.username_hint'.tr(),
                hintStyle: AppTypography.bodyLarge(context).copyWith(
                  color: AppColors.textTertiaryOf(context),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                helperText: _helperText(),
                helperStyle: AppTypography.bodySmall(context).copyWith(
                  color: _state == _Availability.available
                      ? AppColors.success
                      : AppColors.error,
                ),
                suffixIcon: _buildSuffix(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
