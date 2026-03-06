import 'package:equatable/equatable.dart';

import '../../../../../core/services/permission_service.dart';

/// Team management BLoC events

abstract class TeamEvent extends Equatable {
  const TeamEvent();

  @override
  List<Object?> get props => [];
}

/// Load team members and pending invitations
class TeamLoadRequested extends TeamEvent {
  final String sellerProfileId;

  const TeamLoadRequested(this.sellerProfileId);

  @override
  List<Object?> get props => [sellerProfileId];
}

/// Update a member's role
class TeamMemberRoleUpdated extends TeamEvent {
  final String memberId;
  final MemberRole role;

  const TeamMemberRoleUpdated({
    required this.memberId,
    required this.role,
  });

  @override
  List<Object?> get props => [memberId, role];
}

/// Remove a member from the team
class TeamMemberRemoved extends TeamEvent {
  final String memberId;

  const TeamMemberRemoved(this.memberId);

  @override
  List<Object?> get props => [memberId];
}

/// Send an invitation to join the team
class TeamInvitationSent extends TeamEvent {
  final String sellerProfileId;
  final String email;
  final MemberRole role;

  const TeamInvitationSent({
    required this.sellerProfileId,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [sellerProfileId, email, role];
}

/// Cancel a pending invitation
class TeamInvitationCancelled extends TeamEvent {
  final String invitationId;

  const TeamInvitationCancelled(this.invitationId);

  @override
  List<Object?> get props => [invitationId];
}

/// Accept an invitation (current user)
class TeamInvitationAccepted extends TeamEvent {
  final String invitationId;

  const TeamInvitationAccepted(this.invitationId);

  @override
  List<Object?> get props => [invitationId];
}

/// Reject an invitation (current user)
class TeamInvitationRejected extends TeamEvent {
  final String invitationId;

  const TeamInvitationRejected(this.invitationId);

  @override
  List<Object?> get props => [invitationId];
}

/// Load invitations sent to the current user
class TeamMyInvitationsLoadRequested extends TeamEvent {
  const TeamMyInvitationsLoadRequested();
}
