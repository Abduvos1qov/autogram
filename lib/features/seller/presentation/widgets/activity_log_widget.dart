import 'package:easy_localization/easy_localization.dart';
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
                color: AppColors.textSecondaryOf(context).withValues(alpha: 0.5),
              ),
              AppSpacing.gapVerticalSm,
              Text(
                'seller.ui.no_activity'.tr(),
                style: AppTypography.bodyMedium(context).copyWith(
                  color: AppColors.textSecondaryOf(context),
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

          return _buildActivityItem(context, activity, isLast);
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
                    child: Text('seller.ui.load_more'.tr()),
                  ),
          ),
      ],
    );
  }

  Widget _buildActivityItem(
      BuildContext context, ActivityLog activity, bool isLast) {
    final color = _getColorForType(context, activity.actionType);

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
                          style: AppTypography.bodySmall(context),
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
                          style: AppTypography.caption(context).copyWith(
                            color: AppColors.textSecondaryOf(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(' · '),
                      ],
                      Text(
                        Formatters.formatRelativeTime(activity.createdAt),
                        style: AppTypography.caption(context).copyWith(
                          color: AppColors.textSecondaryOf(context),
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

  Color _getColorForType(BuildContext context, ActivityType type) {
    switch (type.category) {
      case 'listings':
        return AppColors.primary;
      case 'members':
        return AppColors.success;
      case 'settings':
        return AppColors.textSecondaryOf(context);
      default:
        return AppColors.textSecondaryOf(context);
    }
  }
}
