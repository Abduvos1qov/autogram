import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Three-field address block (street + city + district). Caller owns the
/// controllers — this widget is purely presentational.
class AddressSection extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController districtController;

  const AddressSection({
    super.key,
    required this.addressController,
    required this.cityController,
    required this.districtController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Row(
          label: 'profile.edit_screen.address_label'.tr(),
          controller: addressController,
        ),
        _Row(
          label: 'profile.edit_screen.city_label'.tr(),
          controller: cityController,
        ),
        _Row(
          label: 'profile.edit_screen.district_label'.tr(),
          controller: districtController,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _Row({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                label,
                style: AppTypography.bodyLarge(context).copyWith(
                  fontWeight: AppTypography.medium,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              style: AppTypography.bodyLarge(context),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                hintStyle: AppTypography.bodyLarge(context).copyWith(
                  color: AppColors.textTertiaryOf(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
