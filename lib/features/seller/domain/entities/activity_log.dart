import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Activity type enum for tracking member actions

enum ActivityType {
  listingCreated,
  listingUpdated,
  listingDeleted,
  listingBoosted,
  memberInvited,
  memberRemoved,
  memberRoleChanged,
  memberJoined,
  invitationSent,
  invitationAccepted,
  invitationRejected,
  invitationCancelled,
  settingsUpdated,
  profileUpdated;

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ActivityType.profileUpdated,
    );
  }

  String get value {
    switch (this) {
      case ActivityType.listingCreated:
        return 'listing_created';
      case ActivityType.listingUpdated:
        return 'listing_updated';
      case ActivityType.listingDeleted:
        return 'listing_deleted';
      case ActivityType.listingBoosted:
        return 'listing_boosted';
      case ActivityType.memberInvited:
        return 'member_invited';
      case ActivityType.memberRemoved:
        return 'member_removed';
      case ActivityType.memberRoleChanged:
        return 'member_role_changed';
      case ActivityType.memberJoined:
        return 'member_joined';
      case ActivityType.invitationSent:
        return 'invitation_sent';
      case ActivityType.invitationAccepted:
        return 'invitation_accepted';
      case ActivityType.invitationRejected:
        return 'invitation_rejected';
      case ActivityType.invitationCancelled:
        return 'invitation_cancelled';
      case ActivityType.settingsUpdated:
        return 'settings_updated';
      case ActivityType.profileUpdated:
        return 'profile_updated';
    }
  }

  String get label {
    switch (this) {
      case ActivityType.listingCreated:
        return 'E\'lon yaratildi';
      case ActivityType.listingUpdated:
        return 'E\'lon yangilandi';
      case ActivityType.listingDeleted:
        return 'E\'lon o\'chirildi';
      case ActivityType.listingBoosted:
        return 'E\'lon targ\'ib qilindi';
      case ActivityType.memberInvited:
        return 'Xodim taklif qilindi';
      case ActivityType.memberRemoved:
        return 'Xodim o\'chirildi';
      case ActivityType.memberRoleChanged:
        return 'Xodim roli o\'zgartirildi';
      case ActivityType.memberJoined:
        return 'Xodim qo\'shildi';
      case ActivityType.invitationSent:
        return 'Taklifnoma yuborildi';
      case ActivityType.invitationAccepted:
        return 'Taklifnoma qabul qilindi';
      case ActivityType.invitationRejected:
        return 'Taklifnoma rad etildi';
      case ActivityType.invitationCancelled:
        return 'Taklifnoma bekor qilindi';
      case ActivityType.settingsUpdated:
        return 'Sozlamalar yangilandi';
      case ActivityType.profileUpdated:
        return 'Profil yangilandi';
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityType.listingCreated:
        return Icons.add_circle_outline;
      case ActivityType.listingUpdated:
        return Icons.edit_outlined;
      case ActivityType.listingDeleted:
        return Icons.delete_outline;
      case ActivityType.listingBoosted:
        return Icons.trending_up;
      case ActivityType.memberInvited:
        return Icons.person_add_outlined;
      case ActivityType.memberRemoved:
        return Icons.person_remove_outlined;
      case ActivityType.memberRoleChanged:
        return Icons.swap_horiz;
      case ActivityType.memberJoined:
        return Icons.group_add_outlined;
      case ActivityType.invitationSent:
        return Icons.send_outlined;
      case ActivityType.invitationAccepted:
        return Icons.check_circle_outline;
      case ActivityType.invitationRejected:
        return Icons.cancel_outlined;
      case ActivityType.invitationCancelled:
        return Icons.block_outlined;
      case ActivityType.settingsUpdated:
        return Icons.settings_outlined;
      case ActivityType.profileUpdated:
        return Icons.person_outline;
    }
  }

  /// Category for filtering
  String get category {
    switch (this) {
      case ActivityType.listingCreated:
      case ActivityType.listingUpdated:
      case ActivityType.listingDeleted:
      case ActivityType.listingBoosted:
        return 'listings';
      case ActivityType.memberInvited:
      case ActivityType.memberRemoved:
      case ActivityType.memberRoleChanged:
      case ActivityType.memberJoined:
      case ActivityType.invitationSent:
      case ActivityType.invitationAccepted:
      case ActivityType.invitationRejected:
      case ActivityType.invitationCancelled:
        return 'members';
      case ActivityType.settingsUpdated:
      case ActivityType.profileUpdated:
        return 'settings';
    }
  }
}

/// Activity log entity — represents a single activity record

class ActivityLog extends Equatable {
  final String id;
  final String sellerProfileId;
  final String userId;
  final ActivityType actionType;
  final String description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  /// Denormalized actor info
  final String? actorName;
  final String? actorAvatarUrl;

  const ActivityLog({
    required this.id,
    required this.sellerProfileId,
    required this.userId,
    required this.actionType,
    required this.description,
    this.metadata,
    required this.createdAt,
    this.actorName,
    this.actorAvatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        sellerProfileId,
        userId,
        actionType,
        description,
        metadata,
        createdAt,
        actorName,
        actorAvatarUrl,
      ];
}
