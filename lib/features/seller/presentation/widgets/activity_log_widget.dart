import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/activity_log.dart';

/// Timeline-style activity log display widget

class ActivityLogWidget extends StatelessWidget {
  final List<ActivityLog> activities;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const ActivityLogWidget({
    super.key,
    required this.activities,
    this.isLoading = false,
    this.onLoadMore,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_outlined,
                size: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              AppSpacing.gapVerticalSm,
              Text(
                'Faoliyat tarixi yo\'q',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          final isLast = index == activities.length - 1;

          return _buildActivityItem(activity, isLast);
        }),
        if (hasMore && onLoadMore != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: onLoadMore,
                    child: const Text('Ko\'proq yuklash'),
                  ),
          ),
      ],
    );
  }

  Widget _buildActivityItem(ActivityLog activity, bool isLast) {
    final color = _getColorForType(activity.actionType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.grey200,
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Actor + action
                  Row(
                    children: [
                      Icon(
                        activity.actionType.icon,
                        size: 16,
                        color: color,
                      ),
                      AppSpacing.gapHorizontalXs,
                      Expanded(
                        child: Text(
                          activity.description,
                          style: AppTypography.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapVerticalXs,
                  // Time + actor name
                  Row(
                    children: [
                      if (activity.actorName != null) ...[
                        Text(
                          activity.actorName!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(' · '),
                      ],
                      Text(
                        Formatters.formatRelativeTime(activity.createdAt),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(ActivityType type) {
    switch (type.category) {
      case 'listings':
        return AppColors.primary;
      case 'members':
        return AppColors.success;
      case 'settings':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
}
