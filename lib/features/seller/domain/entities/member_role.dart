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

  /// Translation key for the localized role label.
  /// Use as `role.labelKey.tr()` in UI code.
  String get labelKey => 'team.roles.$name.label';

  /// Translation key for the localized role description.
  /// Use as `role.descriptionKey.tr()` in UI code.
  String get descriptionKey => 'team.roles.$name.description';

  /// Legacy raw label (Uzbek). UI must use [labelKey] + `.tr()`.
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

  /// Legacy raw description (Uzbek). UI must use [descriptionKey] + `.tr()`.
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

  /// Translation key for the localized permission label.
  /// Use as `permission.labelKey.tr()` in UI code.
  String get labelKey => 'seller.permissions.$value';

  /// Legacy raw label (Uzbek). UI must use [labelKey] + `.tr()`.
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
