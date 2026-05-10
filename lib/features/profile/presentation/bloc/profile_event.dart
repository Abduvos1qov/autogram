import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../seller/domain/entities/contact_phone.dart';
import '../../../seller/domain/entities/seller_profile.dart';
import 'profile_state.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

/// Pull-to-refresh — re-fetch profile + storefront data without showing the
/// full-screen loading state. Existing data stays visible during the refresh.
class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String? fullName;
  final String? email;
  final String? username;
  final String? language;

  const ProfileUpdateRequested({
    this.fullName,
    this.email,
    this.username,
    this.language,
  });

  @override
  List<Object?> get props => [fullName, email, username, language];
}

class ProfileAvatarUpdateRequested extends ProfileEvent {
  final File imageFile;

  const ProfileAvatarUpdateRequested(this.imageFile);

  @override
  List<Object?> get props => [imageFile.path];
}

class ProfileDeleteRequested extends ProfileEvent {
  const ProfileDeleteRequested();
}

/// Seller storefront — switch the visible tab (active / sold / about).
class ProfileTabChanged extends ProfileEvent {
  final SellerStorefrontTab tab;

  const ProfileTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

/// Seller storefront — load the next page of the currently visible listings
/// tab. No-op when there's nothing more to load or another page is already
/// in flight.
class ProfileLoadMoreListings extends ProfileEvent {
  const ProfileLoadMoreListings();
}

/// Persist updates to the SellerProfile (storefront-side fields). Dispatched
/// from EditProfileScreen alongside [ProfileUpdateRequested]. Only honored
/// when the user is a seller — for buyers it's a no-op.
///
/// Empty-string sentinels (`''`) are forwarded as-is so the user can clear a
/// scalar field. `null` means "don't touch this field". List/map fields are
/// either non-null (replace) or null (don't touch).
class ProfileSellerInfoUpdateRequested extends ProfileEvent {
  final String? username;
  final String? description;
  final String? website;
  final String? telegram;
  final String? instagram;
  final String? facebook;
  final String? youtube;
  final String? address;
  final String? city;
  final String? district;
  final String? contactPersonName;
  final String? contactPersonRole;
  final List<ContactPhone>? contactPhones;
  final Map<String, WorkingHours>? workingHours;

  const ProfileSellerInfoUpdateRequested({
    this.username,
    this.description,
    this.website,
    this.telegram,
    this.instagram,
    this.facebook,
    this.youtube,
    this.address,
    this.city,
    this.district,
    this.contactPersonName,
    this.contactPersonRole,
    this.contactPhones,
    this.workingHours,
  });

  @override
  List<Object?> get props => [
        username,
        description,
        website,
        telegram,
        instagram,
        facebook,
        youtube,
        address,
        city,
        district,
        contactPersonName,
        contactPersonRole,
        contactPhones,
        workingHours,
      ];

  /// True if at least one field is non-null — i.e. the dispatcher actually
  /// has something to persist. Allows the bloc to skip a no-op call.
  bool get hasChanges =>
      username != null ||
      description != null ||
      website != null ||
      telegram != null ||
      instagram != null ||
      facebook != null ||
      youtube != null ||
      address != null ||
      city != null ||
      district != null ||
      contactPersonName != null ||
      contactPersonRole != null ||
      contactPhones != null ||
      workingHours != null;
}
