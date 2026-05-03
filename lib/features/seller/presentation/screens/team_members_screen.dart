import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/empty_view.dart';
import '../../../../core/widgets/feedback/error_view.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../bloc/team/team_bloc.dart';
import '../bloc/team/team_event.dart';
import '../bloc/team/team_state.dart';
import '../widgets/invitation_list_tile.dart';
import '../widgets/member_list_tile.dart';

/// Team members management screen

class TeamMembersScreen extends StatefulWidget {
  final String sellerProfileId;

  const TeamMembersScreen({
    super.key,
    required this.sellerProfileId,
  });

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<TeamBloc>()
        .add(TeamLoadRequested(widget.sellerProfileId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamBloc, TeamState>(
      listener: (context, state) {
        if (state.status == TeamStatus.actionSuccess &&
            state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state.status == TeamStatus.error && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final canManage = _canManageMembers(state);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('Jamoa'),
            actions: [
              if (canManage)
                IconButton(
                  icon: const Icon(Icons.person_add_outlined),
                  onPressed: () =>
                      context.push('/team/add', extra: widget.sellerProfileId),
                ),
            ],
          ),
          body: _buildBody(state, canManage),
        );
      },
    );
  }

  Widget _buildBody(TeamState state, bool canManage) {
    if (state.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (state.hasError && state.members.isEmpty) {
      return ErrorView(
        message: state.failure?.message ?? 'Xatolik yuz berdi',
        onRetry: () => context
            .read<TeamBloc>()
            .add(TeamLoadRequested(widget.sellerProfileId)),
      );
    }

    if (state.members.isEmpty && state.pendingInvitations.isEmpty) {
      return EmptyView(
        icon: Icons.people_outline,
        title: 'Jamoa a\'zolari yo\'q',
        message: 'Xodimlarni taklif qiling va jamoangizni boshqaring',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<TeamBloc>()
            .add(TeamLoadRequested(widget.sellerProfileId));
      },
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // Members section
          if (state.members.isNotEmpty) ...[
            _buildSectionHeader(
              'A\'zolar',
              '${state.memberCount}',
            ),
            AppSpacing.gapVerticalSm,
            ...state.members.map((member) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: MemberListTile(
                  member: member,
                  onTap: () => context.push('/team/member/${member.id}'),
                ),
              );
            }),
          ],

          // Pending invitations section
          if (state.pendingInvitations.isNotEmpty && canManage) ...[
            AppSpacing.gapVerticalLg,
            _buildSectionHeader(
              'Kutilayotgan taklifnomalar',
              '${state.invitationCount}',
            ),
            AppSpacing.gapVerticalSm,
            ...state.pendingInvitations.map((invitation) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InvitationListTile(
                  invitation: invitation,
                  onCancel: () => context
                      .read<TeamBloc>()
                      .add(TeamInvitationCancelled(invitation.id)),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      children: [
        Text(
          title,
          style: AppTypography.titleSmall(context),
        ),
        AppSpacing.gapHorizontalSm,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count,
            style: AppTypography.caption(context).copyWith(
              color: AppColors.textSecondaryOf(context),
            ),
          ),
        ),
      ],
    );
  }

  bool _canManageMembers(TeamState state) {
    final membership = state.currentMembership;
    if (membership == null) return false;
    final permissionService = PermissionService();
    return permissionService.hasPermission(
      membership.role,
      Permission.manageMembers,
    );
  }
}
