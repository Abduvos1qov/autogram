import '../../features/seller/domain/entities/member_role.dart';
import '../../features/seller/domain/entities/seller_member.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/seller/domain/entities/seller_profile.dart';

export '../../features/seller/domain/entities/member_role.dart'
    show MemberRole, Permission;

/// Centralized permission checking service for RBAC

class PermissionService {
  /// Default permission mapping for each role
  static const Map<MemberRole, Set<Permission>> _rolePermissions = {
    MemberRole.owner: {
      Permission.createListing,
      Permission.manageListings,
      Permission.boostListing,
      Permission.viewAnalytics,
      Permission.manageMembers,
      Permission.manageSettings,
      Permission.manageKpi,
      Permission.chatWithBuyers,
    },
    MemberRole.admin: {
      Permission.createListing,
      Permission.manageListings,
      Permission.boostListing,
      Permission.viewAnalytics,
      Permission.manageMembers,
      Permission.manageKpi,
      Permission.chatWithBuyers,
    },
    MemberRole.manager: {
      Permission.createListing,
      Permission.manageListings,
      Permission.viewAnalytics,
      Permission.chatWithBuyers,
    },
    MemberRole.marketing: {
      Permission.boostListing,
      Permission.viewAnalytics,
    },
    MemberRole.viewer: {
      Permission.viewAnalytics,
    },
  };

  /// Get default permissions for a role
  Set<Permission> getPermissionsForRole(MemberRole role) {
    return _rolePermissions[role] ?? {};
  }

  /// Check if a role has a specific permission (default mapping)
  bool hasPermission(MemberRole role, Permission permission) {
    return _rolePermissions[role]?.contains(permission) ?? false;
  }

  /// Whether this role can only manage their own resources
  /// (e.g., manager can only edit/view their own listings)
  bool canManageOwnListingsOnly(MemberRole role) {
    return role == MemberRole.manager;
  }

  // ── Convenience check methods ──────────────────────────────────────

  bool canCreateListing(
    User user, {
    SellerMember? member,
    BusinessType? businessType,
  }) {
    return _checkPermission(
      user,
      Permission.createListing,
      member: member,
      businessType: businessType,
    );
  }

  bool canManageListings(
    User user, {
    SellerMember? member,
    BusinessType? businessType,
  }) {
    return _checkPermission(
      user,
      Permission.manageListings,
      member: member,
      businessType: businessType,
    );
  }

  bool canBoostListing(
    User user, {
    SellerMember? member,
    BusinessType? businessType,
  }) {
    return _checkPermission(
      user,
      Permission.boostListing,
      member: member,
      businessType: businessType,
    );
  }

  bool canViewAnalytics(
    User user, {
    SellerMember? member,
    BusinessType? businessType,
  }) {
    return _checkPermission(
      user,
      Permission.viewAnalytics,
      member: member,
      businessType: businessType,
    );
  }

  bool canManageMembers(
    User user, {
    SellerMember? member,
    BusinessType? businessType,
  }) {
    return _checkPermission(
      user,
      Permission.manageMembers,
      member: member,
      businessType: businessType,
    );
  }

  bool canManageSettings(
    User user, {
    SellerMember? member,
    BusinessType? businessType,
  }) {
    return _checkPermission(
      user,
      Permission.manageSettings,
      member: member,
      businessType: businessType,
    );
  }

  bool canManageKpi(
    User user, {
    SellerMember? member,
    BusinessType? businessType,
  }) {
    return _checkPermission(
      user,
      Permission.manageKpi,
      member: member,
      businessType: businessType,
    );
  }

  bool canChatWithBuyers(
    User user, {
    SellerMember? member,
    BusinessType? businessType,
  }) {
    return _checkPermission(
      user,
      Permission.chatWithBuyers,
      member: member,
      businessType: businessType,
    );
  }

  // ── Private implementation ─────────────────────────────────────────

  bool _checkPermission(
    User user,
    Permission permission, {
    SellerMember? member,
    BusinessType? businessType,
  }) {
    // Buyers have no seller permissions
    if (user.isBuyer) return false;

    // Individual sellers are treated as owners — full access
    if (businessType == BusinessType.individual) {
      return hasPermission(MemberRole.owner, permission);
    }

    // For dealer/showroom: require a member record
    if (businessType == BusinessType.dealer ||
        businessType == BusinessType.showroom) {
      if (member == null) return false;
      if (!member.isActive) return false;

      // Check custom permission overrides first
      if (member.customPermissions != null) {
        return member.customPermissions!.contains(permission);
      }

      // Fall back to role-based defaults
      return hasPermission(member.role, permission);
    }

    // If no businessType provided but member exists, use member's role
    if (member != null) {
      if (!member.isActive) return false;

      if (member.customPermissions != null) {
        return member.customPermissions!.contains(permission);
      }

      return hasPermission(member.role, permission);
    }

    // Seller without businessType and without member — treat as individual
    return hasPermission(MemberRole.owner, permission);
  }
}
