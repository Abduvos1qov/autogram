import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Two-field contact-person block (name + role). Caller owns the controllers.
class ContactPersonSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController roleController;

  const ContactPersonSection({
    super.key,
    required this.nameController,
    required this.roleController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Row(
          label: 'profile.edit_screen.contact_person_name_label'.tr(),
          controller: nameController,
        ),
        _Row(
          label: 'profile.edit_screen.contact_person_role_label'.tr(),
          controller: roleController,
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
