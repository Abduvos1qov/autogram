import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../seller/domain/entities/seller_profile.dart';

/// 7-day working-hours grid. Each row: weekday label + open Switch + two
/// time pickers. Closed days hide the time pickers and render a "Closed"
/// chip instead. Caller drives the model via [hours] + [onChanged].
class WorkingHoursEditor extends StatelessWidget {
  final Map<String, WorkingHours> hours;
  final ValueChanged<Map<String, WorkingHours>> onChanged;

  const WorkingHoursEditor({
    super.key,
    required this.hours,
    required this.onChanged,
  });

  static const _orderedDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  WorkingHours _hoursOrDefault(String day) {
    return hours[day] ??
        const WorkingHours(open: '09:00', close: '18:00', isClosed: false);
  }

  void _update(String day, WorkingHours value) {
    final next = Map<String, WorkingHours>.from(hours);
    next[day] = value;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final day in _orderedDays)
          _DayRow(
            day: day,
            hours: _hoursOrDefault(day),
            onChanged: (value) => _update(day, value),
          ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final String day;
  final WorkingHours hours;
  final ValueChanged<WorkingHours> onChanged;

  const _DayRow({
    required this.day,
    required this.hours,
    required this.onChanged,
  });

  Future<void> _pickTime(BuildContext context, {required bool isOpen}) async {
    final initial = isOpen ? hours.open : hours.close;
    final parts = initial.split(':');
    final t = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 9,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final picked = await showTimePicker(context: context, initialTime: t);
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    onChanged(WorkingHours(
      open: isOpen ? formatted : hours.open,
      close: isOpen ? hours.close : formatted,
      isClosed: hours.isClosed,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              'profile.edit_screen.working_hours_day_$day'.tr(),
              style: AppTypography.bodyMedium(context).copyWith(
                fontWeight: AppTypography.semiBold,
              ),
            ),
          ),
          Switch(
            value: !hours.isClosed,
            onChanged: (open) => onChanged(WorkingHours(
              open: hours.open,
              close: hours.close,
              isClosed: !open,
            )),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (hours.isClosed)
            Expanded(
              child: Text(
                'profile.edit_screen.working_hours_closed'.tr(),
                style: AppTypography.bodyMedium(context).copyWith(
                  color: AppColors.error,
                ),
              ),
            )
          else
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _TimeChip(
                      time: hours.open,
                      onTap: () => _pickTime(context, isOpen: true),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('—'),
                  ),
                  Expanded(
                    child: _TimeChip(
                      time: hours.close,
                      onTap: () => _pickTime(context, isOpen: false),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final VoidCallback onTap;

  const _TimeChip({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerOf(context),
      borderRadius: AppSpacing.borderRadiusSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Center(
            child: Text(
              time,
              style: AppTypography.bodyMedium(context),
            ),
          ),
        ),
      ),
    );
  }
}
