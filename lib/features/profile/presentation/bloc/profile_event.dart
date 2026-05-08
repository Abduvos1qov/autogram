import 'dart:io';

import 'package:equatable/equatable.dart';

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
  final String? language;

  const ProfileUpdateRequested({
    this.fullName,
    this.email,
    this.language,
  });

  @override
  List<Object?> get props => [fullName, email, language];
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
