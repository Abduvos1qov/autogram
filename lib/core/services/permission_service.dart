import '../../features/seller/domain/entities/seller_member.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/seller/domain/entities/seller_profile.dart';

/// Member roles within a seller organization (dealer/showroom)

enum MemberRole {
  owner,
  admin,
  manager,
  marketing,
  viewer;

  static MemberRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'owner':
        return MemberRole.owner;
      case 'admin':
        return MemberRole.admin;
      case 'manager':
        return MemberRole.manager;
      case 'marketing':
        return MemberRole.marketing;
      case 'viewer':
      default:
        return MemberRole.viewer;
    }
  }

  String get value {
    switch (this) {
      case MemberRole.owner:
        return 'owner';
      case MemberRole.admin:
        return 'admin';
      case MemberRole.manager:
        return 'manager';
      case MemberRole.marketing:
        return 'marketing';
      case MemberRole.viewer:
        return 'viewer';
    }
  }

  String get label {
    switch (this) {
      case MemberRole.owner:
        return 'Egasi';
      case MemberRole.admin:
        return 'Administrator';
      case MemberRole.manager:
        return 'Sotuv menejeri';
      case MemberRole.marketing:
        return 'Marketing';
      case MemberRole.viewer:
        return 'Ko\'ruvchi';
    }
  }

  String get description {
    switch (this) {
      case MemberRole.owner:
        return 'Barcha huquqlarga ega, tizimni to\'liq boshqaradi';
      case MemberRole.admin:
        return 'Xodimlar va e\'lonlarni boshqaradi';
      case MemberRole.manager:
        return 'E\'lonlar yaratadi va xaridorlar bilan muloqot qiladi';
      case MemberRole.marketing:
        return 'E\'lonlarni targ\'ib qiladi va analitikani ko\'radi';
      case MemberRole.viewer:
        return 'Faqat analitika va statistikani ko\'radi';
    }
  }

  /// Hierarchical level for role comparisons (higher = more privileges)
  int get level {
    switch (this) {
      case MemberRole.owner:
        return 5;
      case MemberRole.admin:
        return 4;
      case MemberRole.manager:
        return 3;
      case MemberRole.marketing:
        return 2;
      case MemberRole.viewer:
        return 1;
    }
  }

  /// Check if this role is higher than another
  bool isHigherThan(MemberRole other) => level > other.level;

  /// Check if this role is at least as high as another
  bool isAtLeast(MemberRole other) => level >= other.level;
}

/// Permissions that can be granted to seller members

enum Permission {
  createListing,
  manageListings,
  boostListing,
  viewAnalytics,
  manageMembers,
  manageSettings,
  manageKpi,
  chatWithBuyers;

  static Permission fromString(String value) {
    switch (value.toLowerCase()) {
      case 'create_listing':
        return Permission.createListing;
      case 'manage_listings':
        return Permission.manageListings;
      case 'boost_listing':
        return Permission.boostListing;
      case 'view_analytics':
        return Permission.viewAnalytics;
      case 'manage_members':
        return Permission.manageMembers;
      case 'manage_settings':
        return Permission.manageSettings;
      case 'manage_kpi':
        return Permission.manageKpi;
      case 'chat_with_buyers':
        return Permission.chatWithBuyers;
      default:
        throw ArgumentError('Unknown permission: $value');
    }
  }

  String get value {
    switch (this) {
      case Permission.createListing:
        return 'create_listing';
      case Permission.manageListings:
        return 'manage_listings';
      case Permission.boostListing:
        return 'boost_listing';
      case Permission.viewAnalytics:
        return 'view_analytics';
      case Permission.manageMembers:
        return 'manage_members';
      case Permission.manageSettings:
        return 'manage_settings';
      case Permission.manageKpi:
        return 'manage_kpi';
      case Permission.chatWithBuyers:
        return 'chat_with_buyers';
    }
  }

  String get label {
    switch (this) {
      case Permission.createListing:
        return 'E\'lon yaratish';
      case Permission.manageListings:
        return 'E\'lonlarni boshqarish';
      case Permission.boostListing:
        return 'E\'lonlarni targ\'ib qilish';
      case Permission.viewAnalytics:
        return 'Analitikani ko\'rish';
      case Permission.manageMembers:
        return 'Xodimlarni boshqarish';
      case Permission.manageSettings:
        return 'Sozlamalarni boshqarish';
      case Permission.manageKpi:
        return 'KPI boshqarish';
      case Permission.chatWithBuyers:
        return 'Xaridorlar bilan chat';
    }
  }
}

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
