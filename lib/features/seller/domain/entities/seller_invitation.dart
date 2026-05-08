import 'package:equatable/equatable.dart';

import 'member_role.dart';

/// Invitation status enum

enum InvitationStatus {
  pending,
  accepted,
  rejected,
  expired,
  cancelled;

  static InvitationStatus fromString(String value) {
    return InvitationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InvitationStatus.pending,
    );
  }

  String get value => name;

  String get label {
    switch (this) {
      case InvitationStatus.pending:
        return 'Kutilmoqda';
      case InvitationStatus.accepted:
        return 'Qabul qilingan';
      case InvitationStatus.rejected:
        return 'Rad etilgan';
      case InvitationStatus.expired:
        return 'Muddati o\'tgan';
      case InvitationStatus.cancelled:
        return 'Bekor qilingan';
    }
  }
}

/// Seller invitation entity — represents an invitation to join a seller organization

class SellerInvitation extends Equatable {
  final String id;
  final String sellerProfileId;
  final String email;
  final MemberRole role;
  final String invitedBy;
  final InvitationStatus status;
  final String token;
  final DateTime expiresAt;

  /// Denormalized display fields
  final String? inviterName;
  final String? inviterAvatarUrl;
  final String? sellerName;

  final DateTime createdAt;
  final DateTime updatedAt;

  const SellerInvitation({
    required this.id,
    required this.sellerProfileId,
    required this.email,
    required this.role,
    required this.invitedBy,
    required this.status,
    required this.token,
    required this.expiresAt,
    this.inviterName,
    this.inviterAvatarUrl,
    this.sellerName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether the invitation is still pending
  bool get isPending => status == InvitationStatus.pending;

  /// Whether the invitation has expired (by time)
  bool get isExpired =>
      status == InvitationStatus.expired ||
      (status == InvitationStatus.pending &&
          DateTime.now().isAfter(expiresAt));

  /// Whether the invitation was accepted
  bool get isAccepted => status == InvitationStatus.accepted;

  /// Whether the invitation was rejected
  bool get isRejected => status == InvitationStatus.rejected;

  /// Whether the invitation was cancelled
  bool get isCancelled => status == InvitationStatus.cancelled;

  /// Days remaining until expiration (0 if expired)
  int get daysRemaining {
    final remaining = expiresAt.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  SellerInvitation copyWith({
    String? id,
    String? sellerProfileId,
    String? email,
    MemberRole? role,
    String? invitedBy,
    InvitationStatus? status,
    String? token,
    DateTime? expiresAt,
    String? inviterName,
    String? inviterAvatarUrl,
    String? sellerName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerInvitation(
      id: id ?? this.id,
      sellerProfileId: sellerProfileId ?? this.sellerProfileId,
      email: email ?? this.email,
      role: role ?? this.role,
      invitedBy: invitedBy ?? this.invitedBy,
      status: status ?? this.status,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      inviterName: inviterName ?? this.inviterName,
      inviterAvatarUrl: inviterAvatarUrl ?? this.inviterAvatarUrl,
      sellerName: sellerName ?? this.sellerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sellerProfileId,
        email,
        role,
        invitedBy,
        status,
        token,
        expiresAt,
        inviterName,
        inviterAvatarUrl,
        sellerName,
        createdAt,
        updatedAt,
      ];
}
