import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../seller/domain/entities/contact_phone.dart';

/// Editable list of [ContactPhone]s. Each row has a phone field, a label
/// dropdown, and (when the label is `other`) a free-form custom-label field.
/// Caller drives the model via [phones] + [onChanged].
class ContactPhonesEditor extends StatelessWidget {
  final List<ContactPhone> phones;
  final ValueChanged<List<ContactPhone>> onChanged;

  const ContactPhonesEditor({
    super.key,
    required this.phones,
    required this.onChanged,
  });

  void _updateAt(int index, ContactPhone phone) {
    final next = [...phones];
    next[index] = phone;
    onChanged(next);
  }

  void _removeAt(int index) {
    final next = [...phones]..removeAt(index);
    onChanged(next);
  }

  void _addRow() {
    onChanged([
      ...phones,
      const ContactPhone(phone: '', label: ContactPhoneLabel.mobile),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < phones.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _PhoneRow(
              key: ValueKey('phone-row-$i'),
              phone: phones[i],
              onChanged: (p) => _updateAt(i, p),
              onRemove: () => _removeAt(i),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add, size: 18),
            label: Text('profile.edit_screen.add_phone'.tr()),
          ),
        ),
      ],
    );
  }
}

class _PhoneRow extends StatefulWidget {
  final ContactPhone phone;
  final ValueChanged<ContactPhone> onChanged;
  final VoidCallback onRemove;

  const _PhoneRow({
    super.key,
    required this.phone,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_PhoneRow> createState() => _PhoneRowState();
}

class _PhoneRowState extends State<_PhoneRow> {
  late final TextEditingController _phoneController;
  late final TextEditingController _customLabelController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phone.phone);
    _customLabelController =
        TextEditingController(text: widget.phone.customLabel ?? '');
  }

  @override
  void didUpdateWidget(covariant _PhoneRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync external updates without clobbering user typing — only refresh
    // when the new model differs from the rendered text.
    if (widget.phone.phone != _phoneController.text) {
      _phoneController.text = widget.phone.phone;
    }
    final newCustom = widget.phone.customLabel ?? '';
    if (newCustom != _customLabelController.text) {
      _customLabelController.text = newCustom;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _customLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOther = widget.phone.label == ContactPhoneLabel.other;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerOf(context),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: '+998 ...',
                    hintStyle: AppTypography.bodyMedium(context).copyWith(
                      color: AppColors.textTertiaryOf(context),
                    ),
                  ),
                  style: AppTypography.bodyLarge(context),
                  onChanged: (value) {
                    widget.onChanged(widget.phone.copyWith(phone: value));
                  },
                ),
              ),
              IconButton(
                tooltip: 'profile.edit_screen.remove_phone'.tr(),
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.textTertiaryOf(context),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          DropdownButtonFormField<ContactPhoneLabel>(
            initialValue: widget.phone.label,
            isDense: true,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            items: [
              for (final label in ContactPhoneLabel.values)
                DropdownMenuItem(
                  value: label,
                  child: Text(label.labelKey.tr()),
                ),
            ],
            onChanged: (label) {
              if (label == null) return;
              widget.onChanged(widget.phone.copyWith(
                label: label,
                clearCustomLabel: label != ContactPhoneLabel.other,
              ));
            },
          ),
          if (isOther) ...[
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _customLabelController,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'profile.edit_screen.contact_label_custom_hint'.tr(),
                hintStyle: AppTypography.bodySmall(context).copyWith(
                  color: AppColors.textTertiaryOf(context),
                ),
              ),
              style: AppTypography.bodyMedium(context),
              onChanged: (value) {
                widget.onChanged(widget.phone.copyWith(customLabel: value));
              },
            ),
          ],
        ],
      ),
    );
  }
}
