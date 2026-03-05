import 'package:equatable/equatable.dart';

import '../../../../core/services/permission_service.dart';

/// Seller team member entity — represents an employee/member within a seller organization

class SellerMember extends Equatable {
  final String id;
  final String sellerProfileId;
  final String userId;
  final MemberRole role;
  final Set<Permission>? customPermissions;
  final String? invitedBy;
  final DateTime? invitedAt;
  final DateTime? joinedAt;
  final bool isActive;

  /// Denormalized user info for display purposes
  final String memberName;
  final String? memberEmail;
  final String? memberAvatarUrl;

  final DateTime createdAt;
  final DateTime updatedAt;

  const SellerMember({
    required this.id,
    required this.sellerProfileId,
    required this.userId,
    required this.role,
    this.customPermissions,
    this.invitedBy,
    this.invitedAt,
    this.joinedAt,
    required this.isActive,
    required this.memberName,
    this.memberEmail,
    this.memberAvatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOwner => role == MemberRole.owner;
  bool get isAdmin => role == MemberRole.admin;
  bool get isManager => role == MemberRole.manager;
  bool get isMarketing => role == MemberRole.marketing;
  bool get isViewer => role == MemberRole.viewer;

  /// Whether the member has joined (accepted the invitation)
  bool get hasJoined => joinedAt != null;

  /// Whether the member is pending invitation acceptance
  bool get isPending => joinedAt == null && isActive;

  SellerMember copyWith({
    String? id,
    String? sellerProfileId,
    String? userId,
    MemberRole? role,
    Set<Permission>? customPermissions,
    String? invitedBy,
    DateTime? invitedAt,
    DateTime? joinedAt,
    bool? isActive,
    String? memberName,
    String? memberEmail,
    String? memberAvatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerMember(
      id: id ?? this.id,
      sellerProfileId: sellerProfileId ?? this.sellerProfileId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      customPermissions: customPermissions ?? this.customPermissions,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedAt: invitedAt ?? this.invitedAt,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      memberName: memberName ?? this.memberName,
      memberEmail: memberEmail ?? this.memberEmail,
      memberAvatarUrl: memberAvatarUrl ?? this.memberAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sellerProfileId,
        userId,
        role,
        customPermissions,
        invitedBy,
        invitedAt,
        joinedAt,
        isActive,
        memberName,
        memberEmail,
        memberAvatarUrl,
        createdAt,
        updatedAt,
      ];
}
