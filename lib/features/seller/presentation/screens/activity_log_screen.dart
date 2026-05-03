import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/activity_log.dart';
import '../widgets/activity_log_widget.dart';

/// Full activity log screen with category filters
///
/// Note: This screen currently displays mock data directly.
/// In production, integrate with TeamBloc or a dedicated ActivityBloc.

class ActivityLogScreen extends StatefulWidget {
  final String sellerProfileId;
  final List<ActivityLog> activities;

  const ActivityLogScreen({
    super.key,
    required this.sellerProfileId,
    this.activities = const [],
  });

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filteredActivities = _selectedCategory == null
        ? widget.activities
        : widget.activities
            .where((a) => a.actionType.category == _selectedCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faoliyat tarixi'),
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(null, 'Barchasi'),
                AppSpacing.gapHorizontalSm,
                _buildFilterChip('listings', 'E\'lonlar'),
                AppSpacing.gapHorizontalSm,
                _buildFilterChip('members', 'Xodimlar'),
                AppSpacing.gapHorizontalSm,
                _buildFilterChip('settings', 'Sozlamalar'),
              ],
            ),
          ),

          // Activity list
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: ActivityLogWidget(
                activities: filteredActivities,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String? category, String label) {
    final isSelected = _selectedCategory == category;

    return FilterChip(
      label: Text(
        label,
        style: AppTypography.labelMedium(context).copyWith(
          color: isSelected ? Colors.white : AppColors.textPrimaryOf(context),
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedCategory = category;
        });
      },
      backgroundColor: AppColors.grey100,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
