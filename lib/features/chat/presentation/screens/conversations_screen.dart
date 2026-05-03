import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/feedback/empty_view.dart';
import '../../../../core/widgets/feedback/error_view.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../../../core/widgets/media/avatar.dart';
import '../../../../core/widgets/media/cached_image.dart';
import '../../domain/entities/conversation.dart';
import '../bloc/conversations_bloc.dart';

/// Conversations list screen

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConversationsBloc>().add(const ConversationsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xabarlar'),
      ),
      body: BlocBuilder<ConversationsBloc, ConversationsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state.hasError) {
            return ErrorView(
              failure: state.failure,
              onRetry: () {
                context.read<ConversationsBloc>().add(
                      const ConversationsLoadRequested(),
                    );
              },
            );
          }

          if (state.isEmpty) {
            return const EmptyView(
              icon: Icons.chat_bubble_outline,
              title: 'Xabarlar yo\'q',
              message: 'Sotuvchilar bilan suhbat boshlang',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ConversationsBloc>().add(
                    const ConversationsLoadRequested(),
                  );
            },
            child: ListView.builder(
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                return _buildConversationTile(context, conversation);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(BuildContext context, Conversation conversation) {
    return ListTile(
      onTap: () => context.push('/chat/${conversation.id}'),
      leading: AppAvatar(
        imageUrl: conversation.otherUserAvatarUrl,
        name: conversation.otherUserName,
        size: AvatarSize.md,
        isVerified: conversation.isOtherUserVerified,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.otherUserName,
              style: AppTypography.titleSmall(context).copyWith(
                fontWeight:
                    conversation.hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.lastMessageAt != null)
            Text(
              Formatters.formatRelativeTime(conversation.lastMessageAt!),
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.textSecondaryOf(context),
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          // Listing thumbnail if available
          if (conversation.listingThumbnailUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 32,
                height: 32,
                child: AppCachedImage(
                  imageUrl: conversation.listingThumbnailUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            AppSpacing.gapHorizontalSm,
          ],
          Expanded(
            child: Text(
              conversation.lastMessageText ?? 'Yangi suhbat',
              style: AppTypography.bodySmall(context).copyWith(
                color: conversation.hasUnread
                    ? AppColors.textPrimaryOf(context)
                    : AppColors.textSecondaryOf(context),
                fontWeight:
                    conversation.hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: conversation.hasUnread
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: AppTypography.labelSmall(context).copyWith(
                  color: AppColors.white,
                ),
              ),
            )
          : null,
    );
  }
}
