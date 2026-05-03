import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/primary_button.dart';

/// Empty state display widget

class EmptyView extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? customIcon;

  const EmptyView({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customIcon ??
                Icon(
                  icon,
                  size: 64,
                  color: AppColors.grey400,
                ),
            AppSpacing.gapVerticalLg,
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.headlineSmall(context),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapVerticalSm,
            ],
            if (message != null)
              Text(
                message!,
                style: AppTypography.bodyMedium(context).copyWith(
                  color: AppColors.textSecondaryOf(context),
                ),
                textAlign: TextAlign.center,
              ),
            if (onAction != null && actionText != null) ...[
              AppSpacing.gapVerticalLg,
              PrimaryButton(
                text: actionText!,
                onPressed: onAction,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty search results view

class EmptySearchView extends StatelessWidget {
  final String query;
  final VoidCallback? onClearSearch;

  const EmptySearchView({
    super.key,
    required this.query,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyView(
      icon: Icons.search_off,
      title: 'Natija topilmadi',
      message: '"$query" bo\'yicha hech narsa topilmadi.\nBoshqa so\'z bilan qidiring.',
      actionText: onClearSearch != null ? 'Tozalash' : null,
      onAction: onClearSearch,
    );
  }
}

/// Empty saved items view

class EmptySavedView extends StatelessWidget {
  final VoidCallback? onBrowse;

  const EmptySavedView({
    super.key,
    this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyView(
      icon: Icons.bookmark_outline,
      title: 'Saqlangan e\'lonlar yo\'q',
      message: 'Yoqtirgan e\'lonlarni keyinroq ko\'rish uchun saqlang.',
      actionText: onBrowse != null ? 'E\'lonlarni ko\'rish' : null,
      onAction: onBrowse,
    );
  }
}

/// Empty messages view

class EmptyMessagesView extends StatelessWidget {
  const EmptyMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyView(
      icon: Icons.chat_bubble_outline,
      title: 'Xabarlar yo\'q',
      message: 'Sotuvchilar bilan suhbatlaringiz shu yerda ko\'rinadi.',
    );
  }
}

/// Empty notifications view

class EmptyNotificationsView extends StatelessWidget {
  const EmptyNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyView(
      icon: Icons.notifications_none,
      title: 'Bildirishnomalar yo\'q',
      message: 'Yangi bildirishnomalar shu yerda ko\'rinadi.',
    );
  }
}
