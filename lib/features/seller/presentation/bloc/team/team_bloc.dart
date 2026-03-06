import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/logger.dart';
import '../../../domain/entities/activity_log.dart';
import '../../../domain/usecases/get_team_members_usecase.dart';
import '../../../domain/usecases/update_member_role_usecase.dart';
import '../../../domain/usecases/remove_member_usecase.dart';
import '../../../domain/usecases/get_current_membership_usecase.dart';
import '../../../domain/usecases/send_invitation_usecase.dart';
import '../../../domain/usecases/get_pending_invitations_usecase.dart';
import '../../../domain/usecases/accept_invitation_usecase.dart';
import '../../../domain/usecases/reject_invitation_usecase.dart';
import '../../../domain/usecases/cancel_invitation_usecase.dart';
import '../../../domain/usecases/get_my_invitations_usecase.dart';
import '../../../domain/usecases/log_activity_usecase.dart';
import 'team_event.dart';
import 'team_state.dart';

/// Team management BLoC

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final GetTeamMembersUseCase _getTeamMembersUseCase;
  final UpdateMemberRoleUseCase _updateMemberRoleUseCase;
  final RemoveMemberUseCase _removeMemberUseCase;
  final GetCurrentMembershipUseCase _getCurrentMembershipUseCase;
  final SendInvitationUseCase _sendInvitationUseCase;
  final GetPendingInvitationsUseCase _getPendingInvitationsUseCase;
  final AcceptInvitationUseCase _acceptInvitationUseCase;
  final RejectInvitationUseCase _rejectInvitationUseCase;
  final CancelInvitationUseCase _cancelInvitationUseCase;
  final GetMyInvitationsUseCase _getMyInvitationsUseCase;
  final LogActivityUseCase _logActivityUseCase;

  TeamBloc({
    required GetTeamMembersUseCase getTeamMembersUseCase,
    required UpdateMemberRoleUseCase updateMemberRoleUseCase,
    required RemoveMemberUseCase removeMemberUseCase,
    required GetCurrentMembershipUseCase getCurrentMembershipUseCase,
    required SendInvitationUseCase sendInvitationUseCase,
    required GetPendingInvitationsUseCase getPendingInvitationsUseCase,
    required AcceptInvitationUseCase acceptInvitationUseCase,
    required RejectInvitationUseCase rejectInvitationUseCase,
    required CancelInvitationUseCase cancelInvitationUseCase,
    required GetMyInvitationsUseCase getMyInvitationsUseCase,
    required LogActivityUseCase logActivityUseCase,
  })  : _getTeamMembersUseCase = getTeamMembersUseCase,
        _updateMemberRoleUseCase = updateMemberRoleUseCase,
        _removeMemberUseCase = removeMemberUseCase,
        _getCurrentMembershipUseCase = getCurrentMembershipUseCase,
        _sendInvitationUseCase = sendInvitationUseCase,
        _getPendingInvitationsUseCase = getPendingInvitationsUseCase,
        _acceptInvitationUseCase = acceptInvitationUseCase,
        _rejectInvitationUseCase = rejectInvitationUseCase,
        _cancelInvitationUseCase = cancelInvitationUseCase,
        _getMyInvitationsUseCase = getMyInvitationsUseCase,
        _logActivityUseCase = logActivityUseCase,
        super(const TeamState()) {
    on<TeamLoadRequested>(_onLoadRequested);
    on<TeamMemberRoleUpdated>(_onMemberRoleUpdated);
    on<TeamMemberRemoved>(_onMemberRemoved);
    on<TeamInvitationSent>(_onInvitationSent);
    on<TeamInvitationCancelled>(_onInvitationCancelled);
    on<TeamInvitationAccepted>(_onInvitationAccepted);
    on<TeamInvitationRejected>(_onInvitationRejected);
    on<TeamMyInvitationsLoadRequested>(_onMyInvitationsLoadRequested);
  }

  Future<void> _onLoadRequested(
    TeamLoadRequested event,
    Emitter<TeamState> emit,
  ) async {
    emit(state.copyWith(
      status: TeamStatus.loading,
      sellerProfileId: event.sellerProfileId,
      clearFailure: true,
    ));

    // Load members, invitations, and current membership in parallel
    final membersResult =
        await _getTeamMembersUseCase(IdParams(event.sellerProfileId));
    final invitationsResult =
        await _getPendingInvitationsUseCase(IdParams(event.sellerProfileId));
    final membershipResult = await _getCurrentMembershipUseCase();

    membersResult.fold(
      (failure) {
        AppLogger.error('Failed to load team members: ${failure.message}');
        emit(state.copyWith(
          status: TeamStatus.error,
          failure: failure,
        ));
      },
      (members) {
        invitationsResult.fold(
          (failure) {
            // Members loaded but invitations failed — show members with warning
            AppLogger.warning(
                'Failed to load invitations: ${failure.message}');
            emit(state.copyWith(
              status: TeamStatus.loaded,
              members: members,
            ));
          },
          (invitations) {
            membershipResult.fold(
              (failure) {
                emit(state.copyWith(
                  status: TeamStatus.loaded,
                  members: members,
                  pendingInvitations: invitations,
                ));
              },
              (membership) {
                emit(state.copyWith(
                  status: TeamStatus.loaded,
                  members: members,
                  pendingInvitations: invitations,
                  currentMembership: membership,
                ));
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onMemberRoleUpdated(
    TeamMemberRoleUpdated event,
    Emitter<TeamState> emit,
  ) async {
    emit(state.copyWith(
        status: TeamStatus.actionInProgress, clearFailure: true));

    final result = await _updateMemberRoleUseCase(
      UpdateMemberRoleParams(memberId: event.memberId, role: event.role),
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to update member role: ${failure.message}');
        emit(state.copyWith(
          status: TeamStatus.error,
          failure: failure,
        ));
      },
      (updatedMember) {
        AppLogger.info(
            'Member role updated: ${updatedMember.memberName} → ${event.role.label}');
        final updatedMembers = state.members.map((m) {
          return m.id == event.memberId ? updatedMember : m;
        }).toList();

        emit(state.copyWith(
          status: TeamStatus.actionSuccess,
          members: updatedMembers,
          successMessage: 'Rol yangilandi',
        ));

        // Auto-log activity
        _logActivity(
          ActivityType.memberRoleChanged,
          '${updatedMember.memberName} roli ${event.role.label} ga o\'zgartirildi',
          metadata: {'member_id': event.memberId, 'new_role': event.role.value},
        );
      },
    );
  }

  Future<void> _onMemberRemoved(
    TeamMemberRemoved event,
    Emitter<TeamState> emit,
  ) async {
    emit(state.copyWith(
        status: TeamStatus.actionInProgress, clearFailure: true));

    final result = await _removeMemberUseCase(IdParams(event.memberId));

    result.fold(
      (failure) {
        AppLogger.error('Failed to remove member: ${failure.message}');
        emit(state.copyWith(
          status: TeamStatus.error,
          failure: failure,
        ));
      },
      (_) {
        // Find member name before removing from list
        final removedMember = state.members.where((m) => m.id == event.memberId).firstOrNull;
        AppLogger.info('Member removed: ${event.memberId}');
        final updatedMembers =
            state.members.where((m) => m.id != event.memberId).toList();

        emit(state.copyWith(
          status: TeamStatus.actionSuccess,
          members: updatedMembers,
          successMessage: 'Xodim o\'chirildi',
        ));

        // Auto-log activity
        _logActivity(
          ActivityType.memberRemoved,
          '${removedMember?.memberName ?? 'Xodim'} jamoadan o\'chirildi',
          metadata: {'member_id': event.memberId},
        );
      },
    );
  }

  Future<void> _onInvitationSent(
    TeamInvitationSent event,
    Emitter<TeamState> emit,
  ) async {
    emit(state.copyWith(
        status: TeamStatus.actionInProgress, clearFailure: true));

    final result = await _sendInvitationUseCase(
      SendInvitationParams(
        sellerProfileId: event.sellerProfileId,
        email: event.email,
        role: event.role,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to send invitation: ${failure.message}');
        emit(state.copyWith(
          status: TeamStatus.error,
          failure: failure,
        ));
      },
      (invitation) {
        AppLogger.info('Invitation sent to: ${event.email}');
        final updatedInvitations = [
          invitation,
          ...state.pendingInvitations,
        ];

        emit(state.copyWith(
          status: TeamStatus.actionSuccess,
          pendingInvitations: updatedInvitations,
          successMessage: 'Taklifnoma yuborildi',
        ));

        // Auto-log activity
        _logActivity(
          ActivityType.memberInvited,
          '${event.email} ga taklifnoma yuborildi (${event.role.label})',
          metadata: {'email': event.email, 'role': event.role.value},
        );
      },
    );
  }

  Future<void> _onInvitationCancelled(
    TeamInvitationCancelled event,
    Emitter<TeamState> emit,
  ) async {
    emit(state.copyWith(
        status: TeamStatus.actionInProgress, clearFailure: true));

    final result =
        await _cancelInvitationUseCase(IdParams(event.invitationId));

    result.fold(
      (failure) {
        AppLogger.error('Failed to cancel invitation: ${failure.message}');
        emit(state.copyWith(
          status: TeamStatus.error,
          failure: failure,
        ));
      },
      (_) {
        final cancelledInvitation = state.pendingInvitations
            .where((i) => i.id == event.invitationId)
            .firstOrNull;
        AppLogger.info('Invitation cancelled: ${event.invitationId}');
        final updatedInvitations = state.pendingInvitations
            .where((i) => i.id != event.invitationId)
            .toList();

        emit(state.copyWith(
          status: TeamStatus.actionSuccess,
          pendingInvitations: updatedInvitations,
          successMessage: 'Taklifnoma bekor qilindi',
        ));

        // Auto-log activity
        _logActivity(
          ActivityType.invitationCancelled,
          '${cancelledInvitation?.email ?? ''} ga taklifnoma bekor qilindi',
          metadata: {'invitation_id': event.invitationId},
        );
      },
    );
  }

  Future<void> _onInvitationAccepted(
    TeamInvitationAccepted event,
    Emitter<TeamState> emit,
  ) async {
    emit(state.copyWith(
        status: TeamStatus.actionInProgress, clearFailure: true));

    final result =
        await _acceptInvitationUseCase(IdParams(event.invitationId));

    result.fold(
      (failure) {
        AppLogger.error('Failed to accept invitation: ${failure.message}');
        emit(state.copyWith(
          status: TeamStatus.error,
          failure: failure,
        ));
      },
      (invitation) {
        AppLogger.info('Invitation accepted: ${event.invitationId}');
        final updatedMyInvitations = state.myInvitations
            .where((i) => i.id != event.invitationId)
            .toList();

        emit(state.copyWith(
          status: TeamStatus.actionSuccess,
          myInvitations: updatedMyInvitations,
          successMessage: 'Taklifnoma qabul qilindi',
        ));
      },
    );
  }

  Future<void> _onInvitationRejected(
    TeamInvitationRejected event,
    Emitter<TeamState> emit,
  ) async {
    emit(state.copyWith(
        status: TeamStatus.actionInProgress, clearFailure: true));

    final result =
        await _rejectInvitationUseCase(IdParams(event.invitationId));

    result.fold(
      (failure) {
        AppLogger.error('Failed to reject invitation: ${failure.message}');
        emit(state.copyWith(
          status: TeamStatus.error,
          failure: failure,
        ));
      },
      (invitation) {
        AppLogger.info('Invitation rejected: ${event.invitationId}');
        final updatedMyInvitations = state.myInvitations
            .where((i) => i.id != event.invitationId)
            .toList();

        emit(state.copyWith(
          status: TeamStatus.actionSuccess,
          myInvitations: updatedMyInvitations,
          successMessage: 'Taklifnoma rad etildi',
        ));
      },
    );
  }

  Future<void> _onMyInvitationsLoadRequested(
    TeamMyInvitationsLoadRequested event,
    Emitter<TeamState> emit,
  ) async {
    final result = await _getMyInvitationsUseCase();

    result.fold(
      (failure) {
        AppLogger.warning(
            'Failed to load my invitations: ${failure.message}');
      },
      (invitations) {
        emit(state.copyWith(myInvitations: invitations));
      },
    );
  }

  /// Auto-log activity after successful team operations
  void _logActivity(
    ActivityType actionType,
    String description, {
    Map<String, dynamic>? metadata,
  }) {
    final sellerProfileId = state.sellerProfileId;
    if (sellerProfileId == null) return;

    _logActivityUseCase(LogActivityParams(
      sellerProfileId: sellerProfileId,
      actionType: actionType,
      description: description,
      metadata: metadata,
    )).then((result) {
      result.fold(
        (failure) => AppLogger.warning(
            'Failed to log activity: ${failure.message}'),
        (_) => AppLogger.debug('Activity logged: $description'),
      );
    });
  }
}
