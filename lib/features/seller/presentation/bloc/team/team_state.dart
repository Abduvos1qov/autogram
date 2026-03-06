import 'package:equatable/equatable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../domain/entities/seller_invitation.dart';
import '../../../domain/entities/seller_member.dart';

/// Team management BLoC state

enum TeamStatus {
  initial,
  loading,
  loaded,
  error,
  actionInProgress,
  actionSuccess,
}

class TeamState extends Equatable {
  final TeamStatus status;
  final List<SellerMember> members;
  final List<SellerInvitation> pendingInvitations;
  final List<SellerInvitation> myInvitations;
  final SellerMember? currentMembership;
  final String? sellerProfileId;
  final Failure? failure;
  final String? successMessage;

  const TeamState({
    this.status = TeamStatus.initial,
    this.members = const [],
    this.pendingInvitations = const [],
    this.myInvitations = const [],
    this.currentMembership,
    this.sellerProfileId,
    this.failure,
    this.successMessage,
  });

  bool get isLoading => status == TeamStatus.loading;
  bool get hasError => status == TeamStatus.error;
  bool get isActionInProgress => status == TeamStatus.actionInProgress;
  int get memberCount => members.length;
  int get invitationCount => pendingInvitations.length;

  TeamState copyWith({
    TeamStatus? status,
    List<SellerMember>? members,
    List<SellerInvitation>? pendingInvitations,
    List<SellerInvitation>? myInvitations,
    SellerMember? currentMembership,
    String? sellerProfileId,
    Failure? failure,
    String? successMessage,
    bool clearFailure = false,
    bool clearSuccessMessage = false,
  }) {
    return TeamState(
      status: status ?? this.status,
      members: members ?? this.members,
      pendingInvitations: pendingInvitations ?? this.pendingInvitations,
      myInvitations: myInvitations ?? this.myInvitations,
      currentMembership: currentMembership ?? this.currentMembership,
      sellerProfileId: sellerProfileId ?? this.sellerProfileId,
      failure: clearFailure ? null : (failure ?? this.failure),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        members,
        pendingInvitations,
        myInvitations,
        currentMembership,
        sellerProfileId,
        failure,
        successMessage,
      ];
}
