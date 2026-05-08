import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/seller_member.dart';
import '../bloc/team/team_bloc.dart';
import '../bloc/team/team_event.dart';
import '../bloc/team/team_state.dart';
import '../widgets/permission_grid.dart';
import '../widgets/role_badge.dart';

/// Member detail screen — view/edit member info

class MemberDetailScreen extends StatelessWidget {
  final String memberId;

  const MemberDetailScreen({
    super.key,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamBloc, TeamState>(
      listener: (context, state) {
        if (state.status == TeamStatus.actionSuccess) {
          final messageKey = state.successMessage ??
              'seller.member_detail_screen.default_success';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(messageKey.tr()),
              backgroundColor: AppColors.success,
            ),
          );
          // Pop if member was removed
          if (state.members.every((m) => m.id != memberId)) {
            context.pop();
          }
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
        final member = _findMember(state);
        if (member == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(child: Text('seller.member_detail_screen.not_found'.tr())),
          );
        }

        final canManage = _canManageThisMember(state, member);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text('seller.member_detail_screen.app_bar_title'.tr()),
          ),
          body: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Member header
                _buildMemberHeader(context, member),
                AppSpacing.gapVerticalXl,

                // Role section
                _buildRoleSection(context, state, member, canManage),
                AppSpacing.gapVerticalXl,

                // Permissions section
                _buildPermissionsSection(context, member),
                AppSpacing.gapVerticalXl,

                // Info section
                _buildInfoSection(context, member),
                AppSpacing.gapVerticalXl,

                // Remove button
                if (canManage && !member.isOwner)
                  _buildRemoveButton(context, member),

                AppSpacing.gapVerticalLg,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberHeader(BuildContext context, SellerMember member) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: member.memberAvatarUrl != null
                ? NetworkImage(member.memberAvatarUrl!)
                : null,
            child: member.memberAvatarUrl == null
                ? Text(
                    _getInitials(member.memberName),
                    style: AppTypography.headlineSmall(context).copyWith(
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          AppSpacing.gapVerticalMd,
          Text(
            member.memberName,
            style: AppTypography.headlineSmall(context),
          ),
          if (member.memberEmail != null) ...[
            AppSpacing.gapVerticalXs,
            Text(
              member.memberEmail!,
              style: AppTypography.bodyMedium(context).copyWith(
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ],
          AppSpacing.gapVerticalSm,
          RoleBadge(role: member.role),
        ],
      ),
    );
  }

  Widget _buildRoleSection(
    BuildContext context,
    TeamState state,
    SellerMember member,
    bool canManage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'seller.member_detail_screen.role_section'.tr(),
          style: AppTypography.titleSmall(context),
        ),
        AppSpacing.gapVerticalSm,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.role.labelKey.tr(),
                      style: AppTypography.titleSmall(context),
                    ),
                    AppSpacing.gapVerticalXs,
                    Text(
                      member.role.descriptionKey.tr(),
                      style: AppTypography.bodySmall(context).copyWith(
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (canManage && !member.isOwner)
                PopupMenuButton<MemberRole>(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onSelected: (role) {
                    context.read<TeamBloc>().add(
                          TeamMemberRoleUpdated(
                            memberId: member.id,
                            role: role,
                          ),
                        );
                  },
                  itemBuilder: (context) {
                    final currentUserRole = state.currentMembership?.role;
                    return MemberRole.values
                        .where((r) =>
                            r != MemberRole.owner &&
                            r != member.role &&
                            (currentUserRole == null ||
                                currentUserRole.isHigherThan(r)))
                        .map((role) {
                      return PopupMenuItem<MemberRole>(
                        value: role,
                        child: Text(role.labelKey.tr()),
                      );
                    }).toList();
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection(BuildContext context, SellerMember member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'seller.member_detail_screen.permissions_section'.tr(),
          style: AppTypography.titleSmall(context),
        ),
        AppSpacing.gapVerticalSm,
        PermissionGrid(
          role: member.role,
          customPermissions: member.customPermissions,
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, SellerMember member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'seller.member_detail_screen.info_section'.tr(),
          style: AppTypography.titleSmall(context),
        ),
        AppSpacing.gapVerticalSm,
        if (member.joinedAt != null)
          _buildInfoRow(
            context,
            Icons.calendar_today_outlined,
            'seller.member_detail_screen.info_joined'.tr(),
            Formatters.formatDate(member.joinedAt!),
          ),
        if (member.invitedAt != null)
          _buildInfoRow(
            context,
            Icons.send_outlined,
            'seller.member_detail_screen.info_invited'.tr(),
            Formatters.formatDate(member.invitedAt!),
          ),
        _buildInfoRow(
          context,
          Icons.access_time_outlined,
          'seller.member_detail_screen.info_updated'.tr(),
          Formatters.formatRelativeTime(member.updatedAt),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondaryOf(context)),
          AppSpacing.gapHorizontalSm,
          Text(
            label,
            style: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.bodyMedium(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context, SellerMember member) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showRemoveConfirmation(context, member),
        icon: const Icon(Icons.person_remove_outlined),
        label: Text('seller.member_detail_screen.remove_button'.tr()),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _showRemoveConfirmation(BuildContext context, SellerMember member) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('seller.member_detail_screen.remove_dialog_title'.tr()),
          content: Text(
            'seller.member_detail_screen.remove_dialog_message'
                .tr(namedArgs: {'name': member.memberName}),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('seller.member_detail_screen.remove_dialog_cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context
                    .read<TeamBloc>()
                    .add(TeamMemberRemoved(member.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text('seller.member_detail_screen.remove_dialog_confirm'.tr()),
            ),
          ],
        );
      },
    );
  }

  SellerMember? _findMember(TeamState state) {
    try {
      return state.members.firstWhere((m) => m.id == memberId);
    } catch (_) {
      return null;
    }
  }

  bool _canManageThisMember(TeamState state, SellerMember member) {
    final currentMembership = state.currentMembership;
    if (currentMembership == null) return false;
    if (currentMembership.id == member.id) return false; // Can't manage self
    final permissionService = sl<PermissionService>();
    if (!permissionService.hasPermission(
        currentMembership.role, Permission.manageMembers)) {
      return false;
    }
    // Can only manage members with lower role
    return currentMembership.role.isHigherThan(member.role);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}
